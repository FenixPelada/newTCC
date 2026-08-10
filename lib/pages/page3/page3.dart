import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/board_column.dart';
import 'package:flutter_test_project/components/dialogs/aula_form_dialog.dart';
import 'package:flutter_test_project/components/item_card.dart';
import 'package:flutter_test_project/components/timetable_grid.dart';
import 'package:flutter_test_project/model/aula/aula.dart';
import 'package:flutter_test_project/model/course/course.dart';
import 'package:flutter_test_project/model/course/course_subject_load.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/professor/professor_subject.dart';
import 'package:flutter_test_project/model/subject/subject.dart';
import 'package:flutter_test_project/pages/baseLayout.dart';
import 'package:flutter_test_project/providers/providers.dart';
import 'package:flutter_test_project/theme/app_theme.dart';

class Page3 extends ConsumerStatefulWidget {
  const Page3({super.key});

  @override
  ConsumerState<Page3> createState() => _Page3State();
}

class _Page3State extends ConsumerState<Page3> {
  Course? _selectedCourse;

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $e')),
    );
  }

  Map<String, Subject> _subjectById(List<Subject> subjects) => {
        for (final s in subjects) s.id: s,
      };

  Map<String, Professor> _professorById(List<Professor> professors) => {
        for (final p in professors) p.id: p,
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

  List<Professor> _professorsForSubject(
    String subjectId,
    List<Professor> professors,
    List<ProfessorSubject> links,
  ) {
    final ids = links
        .where((l) => l.subjectId == subjectId)
        .map((l) => l.professorId)
        .toSet();
    return professors.where((p) => ids.contains(p.id)).toList();
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

  Future<void> _onSlotTap({
    required TimetableSlot slot,
    required Course course,
    required Aula? existing,
    required List<Subject> courseSubjects,
    required List<Professor> professors,
    required List<ProfessorSubject> links,
    required List<Aula> allAulas,
    required List<CourseSubjectLoad> loads,
  }) async {
    final dayLabel = TimetableGrid.days[slot.dayIndex];
    final periodLabel = TimetableGrid.periods[slot.periodIndex];
    final title = existing == null
        ? 'Nova aula — $dayLabel $periodLabel'
        : 'Editar aula — $dayLabel $periodLabel';

    final result = await showAulaFormDialogWithDelete(
      context,
      title: title,
      subjects: courseSubjects,
      professorsForSubject: (subjectId) =>
          _professorsForSubject(subjectId, professors, links),
      initialSubjectId: existing?.subjectId,
      initialProfessorId: existing?.professorId,
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
      _showError(
        'Carga completa para esta matéria ($max aula(s)).',
      );
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
    required List<Subject> courseSubjects,
    required List<Professor> allProfessors,
    required List<ProfessorSubject> links,
    required List<Aula> allAulas,
    required List<CourseSubjectLoad> loads,
  }) {
    final aula = bySlot[slot];
    final subjectName = aula == null ? null : subjects[aula.subjectId]?.name;
    final professorName =
        aula == null ? null : professors[aula.professorId]?.name;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: aula == null ? Colors.grey.shade100 : IfprColors.verdeFundo,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _onSlotTap(
            slot: slot,
            course: course,
            existing: aula,
            courseSubjects: courseSubjects,
            professors: allProfessors,
            links: links,
            allAulas: allAulas,
            loads: loads,
          ),
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 64,
            child: aula == null
                ? const Center(
                    child: Icon(Icons.add, color: IfprColors.cinzaClaro),
                  )
                : Padding(
                    padding: const EdgeInsets.all(6),
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
                            fontSize: 12,
                            color: IfprColors.verdeEscuro,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          professorName ?? 'Professor',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: IfprColors.cinzaClaro,
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

    final selected = _selectedCourse;
    final aulas = aulasAsync.value ?? const <Aula>[];
    final loads = loadsAsync.value ?? const <CourseSubjectLoad>[];
    final subjects = subjectsAsync.value ?? const <Subject>[];
    final professors = professorsAsync.value ?? const <Professor>[];
    final links = linksAsync.value ?? const <ProfessorSubject>[];

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
                      for (final a in aulas.where((a) => a.courseId == selected.id))
                        a.slot: a,
                    };
                    final subjectMap = _subjectById(subjects);
                    final professorMap = _professorById(professors);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                          child: Text(
                            '${_progressSubtitle(selected, loads, aulas)} · toque numa célula para alocar',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: TimetableGrid(
                            buildCell: (slot) => _scheduleCell(
                              slot: slot,
                              course: selected,
                              bySlot: bySlot,
                              subjects: subjectMap,
                              professors: professorMap,
                              courseSubjects: courseSubjects,
                              allProfessors: professors,
                              links: links,
                              allAulas: aulas,
                              loads: loads,
                            ),
                          ),
                        ),
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
