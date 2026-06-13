import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/providers/providers.dart';

class RoomColumn extends ConsumerWidget {
  final Color color;
  final String text;

  const RoomColumn({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);

    return Expanded(
      child: Container(
        color: color,
        child: roomsAsync.when(
          data: (rooms) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rooms
                .map((room) => Text('Sala ${room.number}'))
                .toList(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, stack) => Center(child: Text('Erro: $e')),
        ),
      ),
    );
  }
}
