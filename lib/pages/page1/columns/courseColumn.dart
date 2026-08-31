import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/board_column.dart';
import 'package:flutter_test_project/components/dialogs/confirm_delete_dialog.dart';
import 'package:flutter_test_project/components/dialogs/course_form_dialog.dart';
import 'package:flutter_test_project/components/item_card.dart';
import 'package:flutter_test_project/model/course/course.dart';
import 'package:flutter_test_project/model/room/room.dart';
import 'package:flutter_test_project/model/subject/subject.dart';
import 'package:flutter_test_project/providers/providers.dart';

class CourseColumn extends ConsumerWidget {
  const CourseColumn({super.key});

  List<Subject> _subjectsOrEmpty(AsyncValue<List<Subject>> subjectsAsync) {
    return subjectsAsync.value ?? const [];
  }

  List<Room> _roomsOrEmpty(AsyncValue<List<Room>> roomsAsync) {
    return roomsAsync.value ?? const [];
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final subjects = _subjectsOrEmpty(ref.read(subjectsProvider));
    final rooms = _roomsOrEmpty(ref.read(roomsProvider));
    final result = await showCourseFormDialog(
      context,
      title: 'Novo curso',
      subjects: subjects,
      rooms: rooms,
    );
    if (result == null) return;

    try {
      await ref.read(courseRepositoryProvider).add(
            result.name,
            roomId: result.roomId,
            periodPreference: result.periodPreference,
            loads: result.loads,
          );
      ref.invalidate(coursesProvider);
      ref.invalidate(courseLoadsProvider);
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, e);
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    Course course,
  ) async {
    final subjects = _subjectsOrEmpty(ref.read(subjectsProvider));
    final rooms = _roomsOrEmpty(ref.read(roomsProvider));
    final loads =
        await ref.read(courseRepositoryProvider).fetchLoads(course.id);
    if (!context.mounted) return;

    final result = await showCourseFormDialog(
      context,
      title: 'Editar curso',
      subjects: subjects,
      rooms: rooms,
      initialName: course.name,
      initialRoomId: course.roomId,
      initialPeriodPreference: course.periodPreference,
      initialLoads: loads,
      courseId: course.id,
    );
    if (result == null) return;

    try {
      await ref.read(courseRepositoryProvider).update(
            Course(
              id: course.id,
              name: result.name,
              roomId: result.roomId,
              periodPreference: result.periodPreference,
            ),
            loads: result.loads,
          );
      ref.invalidate(coursesProvider);
      ref.invalidate(courseLoadsProvider);
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, e);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Course course,
  ) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'Excluir curso',
      message: 'Excluir "${course.name}" e sua carga de aulas?',
    );
    if (!confirmed) return;

    try {
      await ref.read(courseRepositoryProvider).delete(course.id);
      ref.invalidate(coursesProvider);
      ref.invalidate(courseLoadsProvider);
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, e);
    }
  }

  void _showError(BuildContext context, Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $e')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final loadsAsync = ref.watch(courseLoadsProvider);
    final roomsAsync = ref.watch(roomsProvider);
    final roomsById = {
      for (final r in roomsAsync.value ?? const <Room>[]) r.id: r,
    };

    return BoardColumn(
      title: 'Cursos',
      icon: Icons.school_outlined,
      actions: [
        IconButton(
          onPressed: () => _create(context, ref),
          tooltip: 'Adicionar curso',
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          visualDensity: VisualDensity.compact,
        ),
      ],
      child: coursesAsync.when(
        data: (courses) {
          if (courses.isEmpty) {
            return const EmptyColumnHint(message: 'Nenhum curso cadastrado');
          }

          final loads = loadsAsync.value ?? const [];
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: courses.map((course) {
              final courseLoads =
                  loads.where((load) => load.courseId == course.id);
              final totalAulas = courseLoads.fold<int>(
                0,
                (sum, load) => sum + load.classCount,
              );
              final materiaCount = courseLoads.length;
              final room = course.roomId == null
                  ? null
                  : roomsById[course.roomId!];

              final parts = <String>[
                course.periodPreference.label,
                if (materiaCount == 0)
                  'Sem matérias'
                else
                  '$materiaCount matérias · $totalAulas aulas',
                if (room != null) 'Sala ${room.number}',
              ];

              return ItemCard(
                title: course.name,
                subtitle: parts.join(' · '),
                onEdit: () => _edit(context, ref, course),
                onDelete: () => _delete(context, ref, course),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => EmptyColumnHint(message: 'Erro: $e'),
      ),
    );
  }
}
