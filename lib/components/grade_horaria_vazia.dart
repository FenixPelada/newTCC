import 'package:flutter/material.dart';
import 'package:flutter_test_project/components/grade_horaria.dart';

/// Grade horária vazia (Page 3): mesmos slots, sem interação.
class GradeHorariaVazia extends StatelessWidget {
  const GradeHorariaVazia({super.key});

  @override
  Widget build(BuildContext context) {
    return const GradeHoraria(interativo: false);
  }
}
