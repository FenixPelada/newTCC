import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/board_column.dart';
import 'package:flutter_test_project/components/item_card.dart';
import 'package:flutter_test_project/pages/baseLayout.dart';
import 'package:flutter_test_project/providers/stream_providers.dart';

class Page2 extends ConsumerWidget{
  const Page2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);

    return BaseLayout(
      title: "Página 2",
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: Container(
                
              )
            ),

            Expanded(
              flex: 3,
              child: roomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return const EmptyColumnHint(message: "Nenhuma sala cadastrada");
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: rooms
                .map((room) => ItemCard(title: 'Professor sample'))
                .toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => EmptyColumnHint(message: 'Erro: $e'),
      ),
            )
          ],
        ),
        )
      );
  }
}