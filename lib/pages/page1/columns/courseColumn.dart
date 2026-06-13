import 'package:flutter/material.dart';
import 'package:flutter_test_project/components/board_column.dart';

class CourseColumn extends StatefulWidget {
  const CourseColumn({super.key});

  @override
  State<CourseColumn> createState() => _CourseColumnState();
}

class _CourseColumnState extends State<CourseColumn> {
  void addItem() {}

  @override
  Widget build(BuildContext context) {
    return BoardColumn(
      title: "Cursos",
      icon: Icons.school_outlined,
      actions: [
        IconButton(
          onPressed: addItem,
          tooltip: "Adicionar curso",
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          visualDensity: VisualDensity.compact,
        ),
      ],
      child: const EmptyColumnHint(message: "Nenhum curso cadastrado"),
    );
  }
}
