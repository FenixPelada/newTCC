import 'package:flutter/material.dart';
import 'package:flutter_test_project/components/timetable_grid.dart';

/// Grade horária vazia (Page 3): mesmos slots, sem interação.
class EmptyTimetable extends StatelessWidget {
  const EmptyTimetable({super.key});

  @override
  Widget build(BuildContext context) {
    return const TimetableGrid(interactive: false);
  }
}
