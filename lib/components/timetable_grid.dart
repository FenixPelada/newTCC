import 'package:flutter/material.dart';
import 'package:flutter_test_project/theme/app_theme.dart';

/// Identifies a cell in the shared week × period grid (Page 2 / Page 3).
class TimetableSlot {
  const TimetableSlot({required this.dayIndex, required this.periodIndex});

  /// 0 = Seg … 4 = Sex
  final int dayIndex;

  /// 0–5 = manhã (1º–6º), 6–11 = tarde (1º–6º)
  final int periodIndex;

  @override
  bool operator ==(Object other) =>
      other is TimetableSlot &&
      other.dayIndex == dayIndex &&
      other.periodIndex == periodIndex;

  @override
  int get hashCode => Object.hash(dayIndex, periodIndex);
}

/// Shared grade: Seg–Sex × 6 manhã + Almoço + 6 tarde.
///
/// - Page 2: [interactive] true — tap toggles red (unavailable).
/// - Page 3: pass [buildCell] to show/edit aulas.
class TimetableGrid extends StatelessWidget {
  const TimetableGrid({
    super.key,
    this.interactive = false,
    this.markedSlots = const {},
    this.onToggle,
    this.buildCell,
  });

  static const days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];

  /// 12 períodos: índices 0–5 manhã, 6–11 tarde. Persistidos no DB como 1–12.
  static const periods = [
    '1º M',
    '2º M',
    '3º M',
    '4º M',
    '5º M',
    '6º M',
    '1º T',
    '2º T',
    '3º T',
    '4º T',
    '5º T',
    '6º T',
  ];

  static const morningPeriodCount = 6;

  final bool interactive;
  final Set<TimetableSlot> markedSlots;
  final void Function(TimetableSlot slot)? onToggle;

  /// When set, overrides the default empty / unavailability cell.
  final Widget Function(TimetableSlot slot)? buildCell;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth - 24),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.all(
                  color: const Color(0xFFE2E8E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                columnWidths: {
                  0: const FixedColumnWidth(64),
                  for (var i = 1; i <= days.length; i++)
                    i: const FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    decoration:
                        const BoxDecoration(color: IfprColors.verdeFundo),
                    children: [
                      _headerCell(''),
                      ...days.map(_headerCell),
                    ],
                  ),
                  for (var p = 0; p < morningPeriodCount; p++)
                    _periodRow(p),
                  _lunchRow(),
                  for (var p = morningPeriodCount; p < periods.length; p++)
                    _periodRow(p),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  TableRow _periodRow(int periodIndex) {
    return TableRow(
      children: [
        _headerCell(periods[periodIndex]),
        for (var d = 0; d < days.length; d++)
          _slotCell(
            TimetableSlot(dayIndex: d, periodIndex: periodIndex),
          ),
      ],
    );
  }

  TableRow _lunchRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      children: [
        for (var i = 0; i <= days.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Text(
              i == 0 ? 'Almoço' : '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: IfprColors.verdeEscuro,
        ),
      ),
    );
  }

  Widget _slotCell(TimetableSlot slot) {
    if (buildCell != null) {
      return buildCell!(slot);
    }

    if (!interactive) {
      return const SizedBox(height: 48);
    }

    final marked = markedSlots.contains(slot);
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: marked ? Colors.red.shade600 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onToggle == null ? null : () => onToggle!(slot),
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 40,
            child: Center(
              child: Icon(
                marked ? Icons.block : Icons.add,
                size: 16,
                color: marked ? Colors.white : IfprColors.cinzaClaro,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
