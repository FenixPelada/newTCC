import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/board_column.dart';
import 'package:flutter_test_project/components/dialogs/confirm_delete_dialog.dart';
import 'package:flutter_test_project/components/dialogs/number_form_dialog.dart';
import 'package:flutter_test_project/components/item_card.dart';
import 'package:flutter_test_project/model/room/room.dart';
import 'package:flutter_test_project/providers/providers.dart';

class RoomColumn extends ConsumerWidget {
  const RoomColumn({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final number = await showNumberFormDialog(
      context,
      title: 'Nova sala',
      label: 'Número da sala',
    );
    if (number == null) return;

    try {
      await ref.read(roomRepositoryProvider).add(number);
      ref.invalidate(roomsProvider);
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, e);
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    Room room,
  ) async {
    final number = await showNumberFormDialog(
      context,
      title: 'Editar sala',
      label: 'Número da sala',
      initialNumber: room.number,
    );
    if (number == null) return;

    try {
      await ref.read(roomRepositoryProvider).update(
            Room(id: room.id, number: number),
          );
      ref.invalidate(roomsProvider);
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, e);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Room room,
  ) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'Excluir sala',
      message: 'Excluir a Sala ${room.number}?',
    );
    if (!confirmed) return;

    try {
      await ref.read(roomRepositoryProvider).delete(room.id);
      ref.invalidate(roomsProvider);
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
    final roomsAsync = ref.watch(roomsProvider);

    return BoardColumn(
      title: 'Salas',
      icon: Icons.meeting_room_outlined,
      actions: [
        IconButton(
          onPressed: () => _create(context, ref),
          tooltip: 'Adicionar sala',
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          visualDensity: VisualDensity.compact,
        ),
      ],
      child: roomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return const EmptyColumnHint(message: 'Nenhuma sala cadastrada');
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: rooms
                .map(
                  (room) => ItemCard(
                    title: 'Sala ${room.number}',
                    onEdit: () => _edit(context, ref, room),
                    onDelete: () => _delete(context, ref, room),
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
