import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/board_column.dart';
import 'package:flutter_test_project/components/item_card.dart';
import 'package:flutter_test_project/model/professor/availableDays.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/pages/baseLayout.dart';
import 'package:flutter_test_project/providers/providers.dart';

class Page2 extends ConsumerStatefulWidget {
  const Page2({super.key});

  @override
  ConsumerState<Page2> createState() => _Page2State();
}

class _Page2State extends ConsumerState<Page2> {
  Professor? _selectedProfessor;

  @override
  Widget build(BuildContext context) {
    final professorsAsync = ref.watch(professorsProvider);

    return BaseLayout(
      title: "Página 2",
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedProfessor != null)
              BoardColumn(
                flex: 7,
                title: "Dias — ${_selectedProfessor!.name}",
                icon: Icons.calendar_month_outlined,
                actions: [
                  IconButton(
                    onPressed: () => setState(() => _selectedProfessor = null),
                    tooltip: "Fechar",
                    icon: const Icon(Icons.close, color: Colors.white),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: Availabledays.values
                      .map((day) => ItemCard(title: day.labelPt))
                      .toList(),
                ),
              )
            else
              const Expanded(
                flex: 7,
                child: EmptyColumnHint(
                  message: "Selecione um professor para ver os dias da semana",
                ),
              ),
            BoardColumn(
              flex: 3,
              title: "Professores",
              icon: Icons.person_outline,
              child: professorsAsync.when(
                data: (professors) {
                  if (professors.isEmpty) {
                    return const EmptyColumnHint(
                      message: "Nenhum professor cadastrado",
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: professors.map((professor) {
                      final selected = _selectedProfessor?.id == professor.id;
                      return ItemCard(
                        title: professor.name,
                        selected: selected,
                        onTap: () {
                          setState(() {
                            _selectedProfessor =
                                selected ? null : professor;
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
