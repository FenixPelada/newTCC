import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/board_column.dart';
import 'package:flutter_test_project/components/item_card.dart';
import 'package:flutter_test_project/components/timetable_grid.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/professor/professor_unavailability.dart';
import 'package:flutter_test_project/pages/baseLayout.dart';
import 'package:flutter_test_project/providers/providers.dart';

class Page2 extends ConsumerStatefulWidget {
  const Page2({super.key});

  @override
  ConsumerState<Page2> createState() => _Page2State();
}

class _Page2State extends ConsumerState<Page2> {
  Professor? _selectedProfessor;
  bool _saving = false;

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $e')),
    );
  }

  Set<TimetableSlot> _slotsForProfessor(
    String professorId,
    List<ProfessorUnavailability> rows,
  ) {
    return rows
        .where((r) => r.professorId == professorId)
        .map((r) => r.slot)
        .toSet();
  }

  Future<void> _toggleSlot(
    TimetableSlot slot,
    Set<TimetableSlot> current,
  ) async {
    final professor = _selectedProfessor;
    if (professor == null || _saving) return;

    setState(() => _saving = true);
    final repo = ref.read(professorUnavailabilityRepositoryProvider);

    try {
      if (current.contains(slot)) {
        await repo.deleteByProfessorSlot(
          professorId: professor.id,
          slot: slot,
        );
      } else {
        await repo.add(professorId: professor.id, slot: slot);
      }
      ref.invalidate(professorUnavailabilityProvider);
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final professorsAsync = ref.watch(professorsProvider);
    final unavailabilityAsync = ref.watch(professorUnavailabilityProvider);
    final selected = _selectedProfessor;
    final rows =
        unavailabilityAsync.value ?? const <ProfessorUnavailability>[];

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
                child: unavailabilityAsync.when(
                  data: (data) {
                    final marked = _slotsForProfessor(selected.id, data);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                          child: Text(
                            'Selecione os dias indisponíveis para cada professor'
                            'Salvo no banco automaticamente.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        if (_saving)
                          const LinearProgressIndicator(minHeight: 2),
                        Expanded(
                          child: TimetableGrid(
                            interactive: true,
                            markedSlots: marked,
                            onToggle: _saving
                                ? null
                                : (slot) => _toggleSlot(slot, marked),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => EmptyColumnHint(
                    message:
                        'Erro ao carregar indisponibilidade '
                        '(crie tb_professor_indisponibilidade no Supabase):\n$e',
                  ),
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
                      final blocked = rows
                          .where((r) => r.professorId == professor.id)
                          .length;
                      return ItemCard(
                        title: professor.name,
                        subtitle: blocked == 0
                            ? null
                            : '$blocked horário(s) bloqueado(s)',
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
