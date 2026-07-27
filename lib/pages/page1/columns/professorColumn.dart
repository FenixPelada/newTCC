import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/board_column.dart';
import 'package:flutter_test_project/components/dialogs/confirm_delete_dialog.dart';
import 'package:flutter_test_project/components/dialogs/professor_form_dialog.dart';
import 'package:flutter_test_project/components/item_card.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/subject/subject.dart';
import 'package:flutter_test_project/providers/providers.dart';

class ProfessorColumn extends ConsumerWidget {
  const ProfessorColumn({super.key});

  List<Subject> _subjectsOrEmpty(AsyncValue<List<Subject>> subjectsAsync) {
    return subjectsAsync.value ?? const [];
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final subjects = _subjectsOrEmpty(ref.read(subjectsProvider));
    final result = await showProfessorFormDialog(
      context,
      title: 'Novo professor',
      subjects: subjects,
    );
    if (result == null) return;

    try {
      await ref.read(professorRepositoryProvider).add(
            result.name,
            subjectIds: result.subjectIds,
          );
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, e);
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    Professor professor,
  ) async {
    final subjects = _subjectsOrEmpty(ref.read(subjectsProvider));
    final currentIds =
        await ref.read(professorRepositoryProvider).fetchSubjectIds(professor.id);
    if (!context.mounted) return;

    final result = await showProfessorFormDialog(
      context,
      title: 'Editar professor',
      subjects: subjects,
      initialName: professor.name,
      initialSubjectIds: currentIds,
    );
    if (result == null) return;

    try {
      await ref.read(professorRepositoryProvider).update(
            Professor(id: professor.id, name: result.name),
            subjectIds: result.subjectIds,
          );
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, e);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Professor professor,
  ) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'Excluir professor',
      message: 'Excluir "${professor.name}"?',
    );
    if (!confirmed) return;

    try {
      await ref.read(professorRepositoryProvider).delete(professor.id);
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
    final professorsAsync = ref.watch(professorsProvider);
    final linksAsync = ref.watch(professorSubjectsProvider);

    return BoardColumn(
      title: 'Professores',
      icon: Icons.person_outline,
      actions: [
        IconButton(
          onPressed: () => _create(context, ref),
          tooltip: 'Adicionar professor',
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          visualDensity: VisualDensity.compact,
        ),
      ],
      child: professorsAsync.when(
        data: (professors) {
          if (professors.isEmpty) {
            return const EmptyColumnHint(
              message: 'Nenhum professor cadastrado',
            );
          }

          final links = linksAsync.value ?? const [];
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: professors.map((professor) {
              final count = links
                  .where((link) => link.professorId == professor.id)
                  .length;
              return ItemCard(
                title: professor.name,
                subtitle: count == 1
                    ? '1 matéria'
                    : '$count matérias',
                onEdit: () => _edit(context, ref, professor),
                onDelete: () => _delete(context, ref, professor),
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
