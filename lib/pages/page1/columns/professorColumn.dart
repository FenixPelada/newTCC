import 'package:flutter/material.dart';
import 'package:flutter_test_project/components/board_column.dart';

class ProfessorColumn extends StatelessWidget {
  const ProfessorColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return const BoardColumn(
      title: "Professores",
      icon: Icons.person_outline,
      child: EmptyColumnHint(message: "Nenhum professor cadastrado"),
    );
  }
}
