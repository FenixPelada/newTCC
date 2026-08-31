import 'package:flutter_test_project/components/timetable_grid.dart';
import 'package:flutter_test_project/model/aula/aula.dart';
import 'package:flutter_test_project/model/course/course.dart';
import 'package:flutter_test_project/model/course/course_period_preference.dart';
import 'package:flutter_test_project/model/course/course_subject_load.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/professor/professor_subject.dart';
import 'package:flutter_test_project/model/professor/professor_unavailability.dart';

class TimetableGenerateResult {
  const TimetableGenerateResult({
    required this.newAulas,
    required this.placedTotal,
    required this.requiredTotal,
    required this.failures,
  });

  final List<Aula> newAulas;
  final int placedTotal;
  final int requiredTotal;
  final List<String> failures;

  bool get complete => failures.isEmpty && placedTotal >= requiredTotal;
}

class TimetableGenerateAllResult {
  const TimetableGenerateAllResult({
    required this.newAulas,
    required this.failures,
  });

  final List<Aula> newAulas;
  final List<String> failures;

  bool get complete => failures.isEmpty;
}

/// Coloca aulas em blocos de 1 ou 2, respeitando turno, sala e indisponibilidade.
class TimetableGenerator {
  const TimetableGenerator();

  TimetableGenerateAllResult generateAll({
    required List<Course> courses,
    required List<CourseSubjectLoad> loads,
    required List<Professor> professors,
    required List<ProfessorSubject> links,
    required List<ProfessorUnavailability> unavailability,
    Map<String, String> subjectNames = const {},
    Map<String, String> courseNames = const {},
  }) {
    final working = <Aula>[];
    final newAulas = <Aula>[];
    final failures = <String>[];

    final sorted = List<Course>.from(courses)
      ..sort((a, b) {
        final aLoad = _totalRequired(loads, a.id);
        final bLoad = _totalRequired(loads, b.id);
        return bLoad.compareTo(aLoad);
      });

    for (final course in sorted) {
      final result = generate(
        course: course,
        loads: loads,
        professors: professors,
        links: links,
        unavailability: unavailability,
        existingAulas: working,
        subjectNames: subjectNames,
      );
      working.addAll(result.newAulas);
      newAulas.addAll(result.newAulas);
      final courseLabel = courseNames[course.id] ?? course.name;
      failures.addAll(
        result.failures.map((f) => '$courseLabel: $f'),
      );
    }

    return TimetableGenerateAllResult(
      newAulas: newAulas,
      failures: failures,
    );
  }

  TimetableGenerateResult generate({
    required Course course,
    required List<CourseSubjectLoad> loads,
    required List<Professor> professors,
    required List<ProfessorSubject> links,
    required List<ProfessorUnavailability> unavailability,
    required List<Aula> existingAulas,
    Map<String, String> subjectNames = const {},
  }) {
    final courseId = course.id;
    final courseLoads =
        loads.where((l) => l.courseId == courseId).toList();
    final requiredTotal =
        courseLoads.fold<int>(0, (sum, l) => sum + l.classCount);

    if (courseLoads.isEmpty) {
      return const TimetableGenerateResult(
        newAulas: [],
        placedTotal: 0,
        requiredTotal: 0,
        failures: ['Curso sem carga de matérias definida.'],
      );
    }

    final working = List<Aula>.from(existingAulas);
    final newAulas = <Aula>[];
    final failures = <String>[];

    courseLoads.sort((a, b) {
      final aCount = links.where((l) => l.subjectId == a.subjectId).length;
      final bCount = links.where((l) => l.subjectId == b.subjectId).length;
      return aCount.compareTo(bCount);
    });

    String label(String subjectId) =>
        subjectNames[subjectId] ?? 'matéria $subjectId';

    for (final load in courseLoads) {
      final already = working
          .where(
            (a) => a.courseId == courseId && a.subjectId == load.subjectId,
          )
          .length;
      var remaining = load.classCount - already;
      if (remaining <= 0) continue;

      final subjectProfessors = professors
          .where(
            (p) => links.any(
              (l) => l.professorId == p.id && l.subjectId == load.subjectId,
            ),
          )
          .toList();

      if (subjectProfessors.isEmpty) {
        failures.add(
          '${label(load.subjectId)}: nenhum professor vinculado '
          '($remaining aula(s) faltando).',
        );
        continue;
      }

      final blocks = _blocksFor(remaining, load.blockSize);
      final periodPhases = _periodPhases(course.periodPreference);

      for (final blockSize in blocks) {
        var placed = false;

        for (final periodRange in periodPhases) {
          if (placed) break;

          for (var day = 0;
              day < TimetableGrid.days.length && !placed;
              day++) {
            for (final startPeriod in _startPeriods(periodRange, blockSize)) {
              if (_tryPlaceBlock(
                courseId: courseId,
                subjectId: load.subjectId,
                day: day,
                startPeriod: startPeriod,
                blockSize: blockSize,
                roomId: course.roomId,
                subjectProfessors: subjectProfessors,
                unavailability: unavailability,
                working: working,
                newAulas: newAulas,
              )) {
                placed = true;
                remaining -= blockSize;
                break;
              }
            }
          }
        }

        if (!placed) {
          failures.add(
            'Não coube bloco de $blockSize aula(s) de ${label(load.subjectId)}.',
          );
        }
      }

      if (remaining > 0) {
        failures.add(
          'Faltam $remaining aula(s) de ${label(load.subjectId)}.',
        );
      }
    }

    final placedTotal =
        existingAulas.where((a) => a.courseId == courseId).length +
            newAulas.length;

    return TimetableGenerateResult(
      newAulas: newAulas,
      placedTotal: placedTotal,
      requiredTotal: requiredTotal,
      failures: failures,
    );
  }

  int _totalRequired(List<CourseSubjectLoad> loads, String courseId) {
    return loads
        .where((l) => l.courseId == courseId)
        .fold<int>(0, (sum, l) => sum + l.classCount);
  }

  List<int> _blocksFor(int total, int preferredBlock) {
    final size = preferredBlock == 2 ? 2 : 1;
    final blocks = <int>[];
    var remaining = total;
    while (remaining > 0) {
      if (size == 2 && remaining >= 2) {
        blocks.add(2);
        remaining -= 2;
      } else {
        blocks.add(1);
        remaining -= 1;
      }
    }
    return blocks;
  }

  List<List<int>> _periodPhases(CoursePeriodPreference preference) {
    const morning = [0, 1, 2, 3, 4, 5];
    const afternoon = [6, 7, 8, 9, 10, 11];
    return switch (preference) {
      CoursePeriodPreference.manha => [morning],
      CoursePeriodPreference.tarde => [afternoon],
      CoursePeriodPreference.contraturno => [morning, afternoon],
    };
  }

  Iterable<int> _startPeriods(List<int> periodRange, int blockSize) sync* {
    for (var i = 0; i <= periodRange.length - blockSize; i++) {
      yield periodRange[i];
    }
  }

  bool _tryPlaceBlock({
    required String courseId,
    required String subjectId,
    required int day,
    required int startPeriod,
    required int blockSize,
    required String? roomId,
    required List<Professor> subjectProfessors,
    required List<ProfessorUnavailability> unavailability,
    required List<Aula> working,
    required List<Aula> newAulas,
  }) {
    Professor? chosen;
    for (final professor in subjectProfessors) {
      if (_blockFits(
        courseId: courseId,
        professorId: professor.id,
        subjectId: subjectId,
        day: day,
        startPeriod: startPeriod,
        blockSize: blockSize,
        roomId: roomId,
        unavailability: unavailability,
        working: working,
      )) {
        chosen = professor;
        break;
      }
    }
    if (chosen == null) return false;

    for (var offset = 0; offset < blockSize; offset++) {
      final aula = Aula(
        id: 'pending',
        courseId: courseId,
        dayIndex: day,
        periodIndex: startPeriod + offset,
        subjectId: subjectId,
        professorId: chosen.id,
        roomId: roomId,
      );
      working.add(aula);
      newAulas.add(aula);
    }
    return true;
  }

  bool _blockFits({
    required String courseId,
    required String professorId,
    required String subjectId,
    required int day,
    required int startPeriod,
    required int blockSize,
    required String? roomId,
    required List<ProfessorUnavailability> unavailability,
    required List<Aula> working,
  }) {
    // Gerador: no máximo um bloco da mesma matéria por dia (manual pode repetir).
    if (working.any(
      (a) =>
          a.courseId == courseId &&
          a.subjectId == subjectId &&
          a.dayIndex == day,
    )) {
      return false;
    }

    final isMorning = startPeriod < TimetableGrid.morningPeriodCount;
    for (var offset = 0; offset < blockSize; offset++) {
      final period = startPeriod + offset;
      final periodIsMorning = period < TimetableGrid.morningPeriodCount;
      if (periodIsMorning != isMorning) return false;

      final slot = TimetableSlot(dayIndex: day, periodIndex: period);

      if (working.any(
        (a) =>
            a.courseId == courseId &&
            a.dayIndex == day &&
            a.periodIndex == period,
      )) {
        return false;
      }

      if (working.any(
        (a) =>
            a.professorId == professorId &&
            a.dayIndex == day &&
            a.periodIndex == period,
      )) {
        return false;
      }

      if (roomId != null &&
          working.any(
            (a) =>
                a.roomId == roomId &&
                a.dayIndex == day &&
                a.periodIndex == period,
          )) {
        return false;
      }

      if (_isUnavailable(unavailability, professorId, slot)) {
        return false;
      }
    }
    return true;
  }

  bool _isUnavailable(
    List<ProfessorUnavailability> rows,
    String professorId,
    TimetableSlot slot,
  ) {
    return rows.any(
      (u) =>
          u.professorId == professorId &&
          u.dayIndex == slot.dayIndex &&
          u.periodIndex == slot.periodIndex,
    );
  }
}
