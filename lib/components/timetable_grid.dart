import 'package:flutter/material.dart';
import 'package:flutter_test_project/theme/app_theme.dart';

/// Identifies a cell in the shared week × period grid (Page 2 / Page 3).
class TimetableSlot {
  const TimetableSlot({required this.dayIndex, required this.periodIndex});

  /// 0 = Seg … 4 = Sex
  final int dayIndex;

  /// 0 = 1º … 5 = 6º
  final int periodIndex;

  @override
  bool operator ==(Object other) =>
      other is TimetableSlot &&
      other.dayIndex == dayIndex &&
      other.periodIndex == periodIndex;

  @override
  int get hashCode => Object.hash(dayIndex, periodIndex);
}

/// Shared grade: Seg–Sex × 1º–6º.
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
  static const periods = ['1º', '2º', '3º', '4º', '5º', '6º'];

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
                  0: const FixedColumnWidth(56),
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
                  for (var p = 0; p < periods.length; p++)
                    TableRow(
                      children: [
                        _headerCell(periods[p]),
                        for (var d = 0; d < days.length; d++)
                          _slotCell(
                            TimetableSlot(dayIndex: d, periodIndex: p),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
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
      return const SizedBox(height: 56);
    }

    final marked = markedSlots.contains(slot);
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: marked ? Colors.red.shade600 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onToggle == null ? null : () => onToggle!(slot),
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 44,
            child: Center(
              child: Icon(
                marked ? Icons.block : Icons.add,
                size: 18,
                color: marked ? Colors.white : IfprColors.cinzaClaro,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
