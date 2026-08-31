import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/board_column.dart';
import 'package:flutter_test_project/components/dialogs/confirm_delete_dialog.dart';
import 'package:flutter_test_project/components/dialogs/name_form_dialog.dart';
import 'package:flutter_test_project/components/item_card.dart';
import 'package:flutter_test_project/model/subject/subject.dart';
import 'package:flutter_test_project/providers/providers.dart';

class SubjectColumn extends ConsumerWidget {
  const SubjectColumn({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final name = await showNameFormDialog(
      context,
      title: 'Nova matéria',
    );
    if (name == null) return;

    try {
      await ref.read(subjectRepositoryProvider).add(name);
      ref.invalidate(subjectsProvider);
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, e);
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
  ) async {
    final name = await showNameFormDialog(
      context,
      title: 'Editar matéria',
      initialName: subject.name,
    );
    if (name == null) return;

    try {
      await ref.read(subjectRepositoryProvider).update(
            Subject(id: subject.id, name: name),
          );
      ref.invalidate(subjectsProvider);
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, e);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
  ) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'Excluir matéria',
      message: 'Excluir "${subject.name}"? Isso pode falhar se ela estiver '
          'ligada a professores ou cursos.',
    );
    if (!confirmed) return;

    try {
      await ref.read(subjectRepositoryProvider).delete(subject.id);
      ref.invalidate(subjectsProvider);
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
    final subjectsAsync = ref.watch(subjectsProvider);

    return BoardColumn(
      title: 'Matérias',
      icon: Icons.menu_book_outlined,
      actions: [
        IconButton(
          onPressed: () => _create(context, ref),
          tooltip: 'Adicionar matéria',
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          visualDensity: VisualDensity.compact,
        ),
      ],
      child: subjectsAsync.when(
        data: (subjects) {
          if (subjects.isEmpty) {
            return const EmptyColumnHint(message: 'Nenhuma matéria cadastrada');
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: subjects
                .map(
                  (subject) => ItemCard(
                    title: subject.name,
                    onEdit: () => _edit(context, ref, subject),
                    onDelete: () => _delete(context, ref, subject),
                  ),
                )
                .toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => EmptyColumnHint(message: 'Erro: $e'),
      ),
    );
  }
}
