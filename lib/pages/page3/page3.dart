import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/board_column.dart';
import 'package:flutter_test_project/components/dialogs/aula_form_dialog.dart';
import 'package:flutter_test_project/components/dialogs/confirm_delete_dialog.dart';
import 'package:flutter_test_project/components/item_card.dart';
import 'package:flutter_test_project/components/timetable_grid.dart';
import 'package:flutter_test_project/model/aula/aula.dart';
import 'package:flutter_test_project/model/course/course.dart';
import 'package:flutter_test_project/model/course/course_subject_load.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/professor/professor_subject.dart';
import 'package:flutter_test_project/model/professor/professor_unavailability.dart';
import 'package:flutter_test_project/model/room/room.dart';
import 'package:flutter_test_project/model/subject/subject.dart';
import 'package:flutter_test_project/pages/baseLayout.dart';
import 'package:flutter_test_project/providers/providers.dart';
import 'package:flutter_test_project/services/timetable_generator.dart';
import 'package:flutter_test_project/services/timetable_validator.dart';
import 'package:flutter_test_project/theme/app_theme.dart';

class Page3 extends ConsumerStatefulWidget {
  const Page3({super.key});

  @override
  ConsumerState<Page3> createState() => _Page3State();
}

class _Page3State extends ConsumerState<Page3> {
  Course? _selectedCourse;
  bool _busy = false;

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showError(Object e) => _showMessage('Erro: $e');

  Map<String, Subject> _subjectById(List<Subject> subjects) => {
        for (final s in subjects) s.id: s,
      };

  Map<String, Professor> _professorById(List<Professor> professors) => {
        for (final p in professors) p.id: p,
      };

  Map<String, Room> _roomById(List<Room> rooms) => {
        for (final r in rooms) r.id: r,
      };

  List<Subject> _subjectsForCourse(
    String courseId,
    List<CourseSubjectLoad> loads,
    List<Subject> subjects,
  ) {
    final ids = loads
        .where((l) => l.courseId == courseId)
        .map((l) => l.subjectId)
        .toSet();
    return subjects.where((s) => ids.contains(s.id)).toList();
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

  List<Professor> _professorsForSubjectAtSlot({
    required String subjectId,
    required TimetableSlot slot,
    required List<Professor> professors,
    required List<ProfessorSubject> links,
    required List<ProfessorUnavailability> unavailability,
    required List<Aula> allAulas,
    String? excludingAulaId,
  }) {
    final linkedIds = links
        .where((l) => l.subjectId == subjectId)
        .map((l) => l.professorId)
        .toSet();

    return professors.where((p) {
      if (!linkedIds.contains(p.id)) return false;
      if (_isUnavailable(unavailability, p.id, slot)) return false;
      final busy = allAulas.any(
        (a) =>
            a.id != excludingAulaId &&
            a.professorId == p.id &&
            a.dayIndex == slot.dayIndex &&
            a.periodIndex == slot.periodIndex,
      );
      return !busy;
    }).toList();
  }

  int _scheduledCount(
    List<Aula> aulas,
    String courseId,
    String subjectId, {
    String? excludingAulaId,
  }) {
    return aulas
        .where(
          (a) =>
              a.courseId == courseId &&
              a.subjectId == subjectId &&
              a.id != excludingAulaId,
        )
        .length;
  }

  int? _maxLoad(
    List<CourseSubjectLoad> loads,
    String courseId,
    String subjectId,
  ) {
    for (final load in loads) {
      if (load.courseId == courseId && load.subjectId == subjectId) {
        return load.classCount;
      }
    }
    return null;
  }

  Future<void> _clearCourse(Course course) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'Limpar grade',
      message:
          'Remover todas as aulas de "${course.name}"? Esta ação não desfaz.',
    );
    if (!confirmed) return;

    setState(() => _busy = true);
    try {
      await ref.read(aulaRepositoryProvider).deleteByCourse(course.id);
      ref.invalidate(aulasProvider);
      _showMessage('Grade de "${course.name}" limpa.');
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _generateAll({
    required List<Course> courses,
    required List<CourseSubjectLoad> loads,
    required List<Professor> professors,
    required List<ProfessorSubject> links,
    required List<ProfessorUnavailability> unavailability,
    required List<Subject> subjects,
  }) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'Gerar horários',
      message:
          'Regenerar os horários de todas as turmas? '
          'Isso apaga os horários atuais e recria com base nas '
          'configurações da Página 1.',
      confirmLabel: 'Gerar',
    );
    if (!confirmed) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(aulaRepositoryProvider);
      await repo.deleteAll();

      final result = const TimetableGenerator().generateAll(
        courses: courses,
        loads: loads,
        professors: professors,
        links: links,
        unavailability: unavailability,
        subjectNames: {for (final s in subjects) s.id: s.name},
        courseNames: {for (final c in courses) c.id: c.name},
      );

      for (final aula in result.newAulas) {
        await repo.add(aula);
      }
      ref.invalidate(aulasProvider);

      if (result.complete) {
        _showMessage(
          'Horários gerados: ${result.newAulas.length} aula(s) alocadas.',
        );
      } else if (result.newAulas.isEmpty && result.failures.isNotEmpty) {
        _showMessage(
          'Não foi possível gerar: ${result.failures.first}',
        );
      } else {
        _showMessage(
          'Parcial: ${result.newAulas.length} aula(s). '
          '${result.failures.take(3).join(' ')}',
        );
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _validationPanel({
    required TimetableValidation validation,
  }) {
    final ok = validation.ok;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ok ? Colors.green.shade50 : Colors.red.shade50,
        border: Border(
          top: BorderSide(
            color: ok ? Colors.green.shade200 : Colors.red.shade200,
          ),
        ),
      ),
      child: ok
          ? Text(
              'Sem problemas',
              style: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.w600,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: validation.issues
                  .map(
                    (issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        issue,
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Future<void> _onSlotTap({
    required TimetableSlot slot,
    required Course course,
    required Aula? existing,
    required List<Subject> courseSubjects,
    required List<Professor> professors,
    required List<ProfessorSubject> links,
    required List<Aula> allAulas,
    required List<CourseSubjectLoad> loads,
    required List<ProfessorUnavailability> unavailability,
    required List<Room> rooms,
  }) async {
    if (_busy) return;

    final dayLabel = TimetableGrid.days[slot.dayIndex];
    final periodLabel = TimetableGrid.periods[slot.periodIndex];
    final title = existing == null
        ? 'Nova aula — $dayLabel $periodLabel'
        : 'Editar aula — $dayLabel $periodLabel';

    final result = await showAulaFormDialogWithDelete(
      context,
      title: title,
      subjects: courseSubjects,
      rooms: rooms,
      professorsForSubject: (subjectId) => _professorsForSubjectAtSlot(
        subjectId: subjectId,
        slot: slot,
        professors: professors,
        links: links,
        unavailability: unavailability,
        allAulas: allAulas,
        excludingAulaId: existing?.id,
      ),
      initialSubjectId: existing?.subjectId,
      initialProfessorId: existing?.professorId,
      initialRoomId: existing?.roomId ?? course.roomId,
    );

    if (result == null) return;

    if (result is AulaFormDelete) {
      if (existing == null) return;
      try {
        await ref.read(aulaRepositoryProvider).delete(existing.id);
        ref.invalidate(aulasProvider);
      } catch (e) {
        _showError(e);
      }
      return;
    }

    if (result is! AulaFormResult) return;

    final max = _maxLoad(loads, course.id, result.subjectId);
    if (max == null) {
      _showError('Matéria não pertence à carga deste curso.');
      return;
    }

    final already = _scheduledCount(
      allAulas,
      course.id,
      result.subjectId,
      excludingAulaId: existing?.id,
    );
    if (already >= max) {
      _showError('Carga completa para esta matéria ($max aula(s)).');
      return;
    }

    if (_isUnavailable(unavailability, result.professorId, slot)) {
      _showError('Professor indisponível neste horário (Página 2).');
      return;
    }

    final professorBusy = allAulas.any(
      (a) =>
          a.id != existing?.id &&
          a.professorId == result.professorId &&
          a.dayIndex == slot.dayIndex &&
          a.periodIndex == slot.periodIndex,
    );
    if (professorBusy) {
      _showError('Este professor já está alocado neste horário.');
      return;
    }

    if (result.roomId != null) {
      final roomBusy = allAulas.any(
        (a) =>
            a.id != existing?.id &&
            a.roomId == result.roomId &&
            a.dayIndex == slot.dayIndex &&
            a.periodIndex == slot.periodIndex,
      );
      if (roomBusy) {
        _showError('Esta sala já está ocupada neste horário.');
        return;
      }
    }

    try {
      if (existing == null) {
        await ref.read(aulaRepositoryProvider).add(
              Aula(
                id: '0',
                courseId: course.id,
                dayIndex: slot.dayIndex,
                periodIndex: slot.periodIndex,
                subjectId: result.subjectId,
                professorId: result.professorId,
                roomId: result.roomId,
              ),
            );
      } else {
        await ref.read(aulaRepositoryProvider).update(
              Aula(
                id: existing.id,
                courseId: course.id,
                dayIndex: slot.dayIndex,
                periodIndex: slot.periodIndex,
                subjectId: result.subjectId,
                professorId: result.professorId,
                roomId: result.roomId,
              ),
            );
      }
      ref.invalidate(aulasProvider);
    } catch (e) {
      _showError(e);
    }
  }

  Widget _scheduleCell({
    required TimetableSlot slot,
    required Course course,
    required Map<TimetableSlot, Aula> bySlot,
    required Map<String, Subject> subjects,
    required Map<String, Professor> professors,
    required Map<String, Room> roomsById,
    required List<Subject> courseSubjects,
    required List<Professor> allProfessors,
    required List<ProfessorSubject> links,
    required List<Aula> allAulas,
    required List<CourseSubjectLoad> loads,
    required List<ProfessorUnavailability> unavailability,
    required List<Room> rooms,
  }) {
    final aula = bySlot[slot];
    final subjectName = aula == null ? null : subjects[aula.subjectId]?.name;
    final professorName =
        aula == null ? null : professors[aula.professorId]?.name;
    final room = aula?.roomId == null ? null : roomsById[aula!.roomId!];

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: aula == null ? Colors.grey.shade100 : IfprColors.verdeFundo,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: _busy
              ? null
              : () => _onSlotTap(
                    slot: slot,
                    course: course,
                    existing: aula,
                    courseSubjects: courseSubjects,
                    professors: allProfessors,
                    links: links,
                    allAulas: allAulas,
                    loads: loads,
                    unavailability: unavailability,
                    rooms: rooms,
                  ),
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 68,
            child: aula == null
                ? const Center(
                    child: Icon(Icons.add, color: IfprColors.cinzaClaro),
                  )
                : Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          subjectName ?? 'Matéria',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: IfprColors.verdeEscuro,
                          ),
                        ),
                        Text(
                          professorName ?? 'Professor',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            color: IfprColors.cinzaClaro,
                          ),
                        ),
                        if (room != null)
                          Text(
                            'Sala ${room.number}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: IfprColors.verde,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String _progressSubtitle(
    Course course,
    List<CourseSubjectLoad> loads,
    List<Aula> aulas,
  ) {
    final courseLoads = loads.where((l) => l.courseId == course.id).toList();
    if (courseLoads.isEmpty) return 'Sem carga definida';

    final required = courseLoads.fold<int>(0, (s, l) => s + l.classCount);
    final placed = aulas.where((a) => a.courseId == course.id).length;
    return '$placed/$required aulas alocadas';
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    final aulasAsync = ref.watch(aulasProvider);
    final loadsAsync = ref.watch(courseLoadsProvider);
    final subjectsAsync = ref.watch(subjectsProvider);
    final professorsAsync = ref.watch(professorsProvider);
    final linksAsync = ref.watch(professorSubjectsProvider);
    final unavailabilityAsync = ref.watch(professorUnavailabilityProvider);
    final roomsAsync = ref.watch(roomsProvider);

    final selected = _selectedCourse;
    final aulas = aulasAsync.value ?? const <Aula>[];
    final loads = loadsAsync.value ?? const <CourseSubjectLoad>[];
    final subjects = subjectsAsync.value ?? const <Subject>[];
    final professors = professorsAsync.value ?? const <Professor>[];
    final links = linksAsync.value ?? const <ProfessorSubject>[];
    final unavailability =
        unavailabilityAsync.value ?? const <ProfessorUnavailability>[];
    final rooms = roomsAsync.value ?? const <Room>[];
    final courses = coursesAsync.value ?? const <Course>[];

    return BaseLayout(
      title: 'Página 3',
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selected != null)
              BoardColumn(
                flex: 7,
                title: 'Horário — ${selected.name}',
                icon: Icons.table_chart_outlined,
                actions: [
                  TextButton(
                    onPressed: _busy || courses.isEmpty
                        ? null
                        : () => _generateAll(
                              courses: courses,
                              loads: loads,
                              professors: professors,
                              links: links,
                              unavailability: unavailability,
                              subjects: subjects,
                            ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Gerar'),
                  ),
                  IconButton(
                    onPressed: _busy ? null : () => _clearCourse(selected),
                    tooltip: 'Limpar grade',
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: () => setState(() => _selectedCourse = null),
                    tooltip: 'Fechar',
                    icon: const Icon(Icons.close, color: Colors.white),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                child: aulasAsync.when(
                  data: (_) {
                    final courseSubjects =
                        _subjectsForCourse(selected.id, loads, subjects);
                    final bySlot = {
                      for (final a
                          in aulas.where((a) => a.courseId == selected.id))
                        a.slot: a,
                    };
                    final subjectMap = _subjectById(subjects);
                    final professorMap = _professorById(professors);
                    final roomsMap = _roomById(rooms);

                    final validation = const TimetableValidator().validateCourse(
                      courseId: selected.id,
                      allAulas: aulas,
                      courses: courses,
                      loads: loads,
                      professors: professors,
                      subjects: subjects,
                      rooms: rooms,
                      unavailability: unavailability,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                          child: Text(
                            '${_progressSubtitle(selected, loads, aulas)} · '
                            'toque na célula para editar',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        if (_busy) const LinearProgressIndicator(minHeight: 2),
                        Expanded(
                          child: TimetableGrid(
                            buildCell: (slot) => _scheduleCell(
                              slot: slot,
                              course: selected,
                              bySlot: bySlot,
                              subjects: subjectMap,
                              professors: professorMap,
                              roomsById: roomsMap,
                              courseSubjects: courseSubjects,
                              allProfessors: professors,
                              links: links,
                              allAulas: aulas,
                              loads: loads,
                              unavailability: unavailability,
                              rooms: rooms,
                            ),
                          ),
                        ),
                        _validationPanel(validation: validation),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => EmptyColumnHint(
                    message:
                        'Erro ao carregar aulas (crie a tabela tb_aula no Supabase se ainda não existir):\n$e',
                  ),
                ),
              )
            else
              const Expanded(
                flex: 7,
                child: EmptyColumnHint(
                  message: 'Selecione um curso para abrir a grade horária',
                ),
              ),
            BoardColumn(
              flex: 3,
              title: 'Cursos',
              icon: Icons.school_outlined,
              child: coursesAsync.when(
                data: (courses) {
                  if (courses.isEmpty) {
                    return const EmptyColumnHint(
                      message: 'Nenhum curso cadastrado',
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: courses.map((course) {
                      final isSelected = selected?.id == course.id;
                      return ItemCard(
                        title: course.name,
                        subtitle: _progressSubtitle(course, loads, aulas),
                        selected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedCourse = isSelected ? null : course;
                          });
                        },
                      );
                    }).toList(),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, stack) => EmptyColumnHint(message: 'Erro: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
