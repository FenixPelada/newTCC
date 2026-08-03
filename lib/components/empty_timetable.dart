import 'package:flutter/material.dart';
import 'package:flutter_test_project/theme/app_theme.dart';

/// Grade horária vazia: dias × períodos, sem dados ainda.
class EmptyTimetable extends StatelessWidget {
  const EmptyTimetable({super.key});

  static const _days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];
  static const _periods = [
    '1º',
    '2º',
    '3º',
    '4º',
    '5º',
    '6º',
  ];

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
                  for (var i = 1; i <= _days.length; i++)
                    i: const FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: IfprColors.verdeFundo),
                    children: [
                      _headerCell(''),
                      ..._days.map(_headerCell),
                    ],
                  ),
                  for (final period in _periods)
                    TableRow(
                      children: [
                        _headerCell(period),
                        ...List.generate(_days.length, (_) => _emptyCell()),
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

  Widget _emptyCell() {
    return const SizedBox(height: 56);
  }
}
