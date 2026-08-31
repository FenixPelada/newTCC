import 'package:flutter_test_project/components/timetable_grid.dart';
import 'package:flutter_test_project/model/aula/aula.dart';
import 'package:flutter_test_project/model/course/course.dart';
import 'package:flutter_test_project/model/course/course_period_preference.dart';
import 'package:flutter_test_project/model/course/course_subject_load.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/professor/professor_unavailability.dart';
import 'package:flutter_test_project/model/room/room.dart';
import 'package:flutter_test_project/model/subject/subject.dart';

class TimetableValidation {
  const TimetableValidation({required this.issues});

  final List<String> issues;

  bool get ok => issues.isEmpty;
}

/// Valida o horário de uma turma e conflitos globais que a envolvem.
class TimetableValidator {
  const TimetableValidator();

  TimetableValidation validateCourse({
    required String courseId,
    required List<Aula> allAulas,
    required List<Course> courses,
    required List<CourseSubjectLoad> loads,
    required List<Professor> professors,
    required List<Subject> subjects,
    required List<Room> rooms,
    required List<ProfessorUnavailability> unavailability,
  }) {
    final issues = <String>[];
    final course = courses.where((c) => c.id == courseId).firstOrNull;
    if (course == null) return const TimetableValidation(issues: []);

    final courseById = {for (final c in courses) c.id: c};
    final professorById = {for (final p in professors) p.id: p.name};
    final subjectById = {for (final s in subjects) s.id: s.name};
    final roomById = {for (final r in rooms) r.id: r};

    final courseAulas = allAulas.where((a) => a.courseId == courseId).toList();

    for (final load in loads.where((l) => l.courseId == courseId)) {
      final subjectName = subjectById[load.subjectId] ?? 'Matéria';
      final scheduled = courseAulas
          .where((a) => a.subjectId == load.subjectId)
          .length;
      if (scheduled > load.classCount) {
        issues.add('Aulas de $subjectName demais');
      } else if (scheduled < load.classCount) {
        final missing = load.classCount - scheduled;
        issues.add(
          'Faltam $missing aula(s) de $subjectName '
          '($scheduled/${load.classCount})',
        );
      }
    }

    for (final aula in courseAulas) {
      final slot = aula.slot;
      final professorName =
          professorById[aula.professorId] ?? 'Professor ${aula.professorId}';

      if (_isUnavailable(unavailability, aula.professorId, slot)) {
        issues.add(
          '$professorName no horário errado '
          '(${_slotLabel(slot)})',
        );
      }

      if (course.periodPreference != CoursePeriodPreference.contraturno) {
        final isMorning = slot.periodIndex < TimetableGrid.morningPeriodCount;
        final wrongPeriod = switch (course.periodPreference) {
          CoursePeriodPreference.manha => !isMorning,
          CoursePeriodPreference.tarde => isMorning,
          CoursePeriodPreference.contraturno => false,
        };
        if (wrongPeriod) {
          issues.add(
            'Aula fora do período da turma (${_slotLabel(slot)})',
          );
        }
      }

      for (final other in allAulas) {
        if (other.id == aula.id) continue;
        if (other.dayIndex != aula.dayIndex ||
            other.periodIndex != aula.periodIndex) {
          continue;
        }

        if (other.professorId == aula.professorId &&
            other.courseId != aula.courseId) {
          final otherCourse =
              courseById[other.courseId]?.name ?? 'outro curso';
          issues.add(
            '$professorName já está dando aula no curso $otherCourse '
            '(${_slotLabel(slot)})',
          );
        }

        final roomId = aula.roomId;
        if (roomId != null &&
            other.roomId == roomId &&
            other.courseId != aula.courseId) {
          final room = roomById[roomId];
          final roomLabel =
              room == null ? 'Sala' : 'Sala ${room.number}';
          final otherCourse =
              courseById[other.courseId]?.name ?? 'outra turma';
          issues.add(
            '$roomLabel ocupada por $otherCourse (${_slotLabel(slot)})',
          );
        }
      }
    }

    return TimetableValidation(issues: _dedupe(issues));
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

  String _slotLabel(TimetableSlot slot) {
    final day = TimetableGrid.days[slot.dayIndex];
    final period = TimetableGrid.periods[slot.periodIndex];
    return '$day $period';
  }

  List<String> _dedupe(List<String> items) {
    final seen = <String>{};
    final out = <String>[];
    for (final item in items) {
      if (seen.add(item)) out.add(item);
    }
    return out;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
