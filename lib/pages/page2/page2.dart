import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/board_column.dart';
import 'package:flutter_test_project/components/item_card.dart';
import 'package:flutter_test_project/components/timetable_grid.dart';
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

  /// Local marks until `tb_professor_indisponibilidade` is wired.
  /// Key = professor id.
  final Map<String, Set<TimetableSlot>> _unavailableByProfessor = {};

  Set<TimetableSlot> _slotsFor(Professor professor) {
    return _unavailableByProfessor.putIfAbsent(
      professor.id,
      () => <TimetableSlot>{},
    );
  }

  void _toggleSlot(TimetableSlot slot) {
    final professor = _selectedProfessor;
    if (professor == null) return;

    setState(() {
      final slots = _slotsFor(professor);
      if (!slots.add(slot)) {
        slots.remove(slot);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final professorsAsync = ref.watch(professorsProvider);
    final selected = _selectedProfessor;

    return BaseLayout(
      title: 'Página 2',
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selected != null)
              BoardColumn(
                flex: 7,
                title: 'Indisponibilidade — ${selected.name}',
                icon: Icons.calendar_month_outlined,
                actions: [
                  IconButton(
                    onPressed: () => setState(() => _selectedProfessor = null),
                    tooltip: 'Fechar',
                    icon: const Icon(Icons.close, color: Colors.white),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: Text(
                        'Toque em um horário para marcar (vermelho = não pode dar aula).',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: TimetableGrid(
                        interactive: true,
                        markedSlots: _slotsFor(selected),
                        onToggle: _toggleSlot,
                      ),
                    ),
                  ],
                ),
              )
            else
              const Expanded(
                flex: 7,
                child: EmptyColumnHint(
                  message:
                      'Selecione um professor para marcar dias e horários indisponíveis',
                ),
              ),
            BoardColumn(
              flex: 3,
              title: 'Professores',
              icon: Icons.person_outline,
              child: professorsAsync.when(
                data: (professors) {
                  if (professors.isEmpty) {
                    return const EmptyColumnHint(
                      message: 'Nenhum professor cadastrado',
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: professors.map((professor) {
                      final isSelected = selected?.id == professor.id;
                      final blocked = _unavailableByProfessor[professor.id]?.length ?? 0;
                      return ItemCard(
                        title: professor.name,
                        selected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedProfessor =
                                isSelected ? null : professor;
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
