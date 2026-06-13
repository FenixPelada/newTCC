import 'package:flutter/material.dart';
import 'package:flutter_test_project/components/board_column.dart';

class SubjectColumn extends StatelessWidget {
  const SubjectColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return const BoardColumn(
      title: "Matérias",
      icon: Icons.menu_book_outlined,
      child: EmptyColumnHint(message: "Nenhuma matéria cadastrada"),
    );
  }
}
