import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/board_column.dart';
import 'package:flutter_test_project/components/item_card.dart';
import 'package:flutter_test_project/providers/providers.dart';

class RoomColumn extends ConsumerWidget {
  const RoomColumn({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);

    return BoardColumn(
      title: "Salas",
      icon: Icons.meeting_room_outlined,
      child: roomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return const EmptyColumnHint(message: "Nenhuma sala cadastrada");
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: rooms
                .map((room) => ItemCard(title: 'Sala ${room.number}'))
                .toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => EmptyColumnHint(message: 'Erro: $e'),
      ),
    );
  }
}
