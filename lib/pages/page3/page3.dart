import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/board_column.dart';
import 'package:flutter_test_project/components/empty_timetable.dart';
import 'package:flutter_test_project/components/item_card.dart';
import 'package:flutter_test_project/model/course/course.dart';
import 'package:flutter_test_project/pages/baseLayout.dart';
import 'package:flutter_test_project/providers/providers.dart';

class Page3 extends ConsumerStatefulWidget {
  const Page3({super.key});

  @override
  ConsumerState<Page3> createState() => _Page3State();
}

class _Page3State extends ConsumerState<Page3> {
  Course? _selectedCourse;

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);

    return BaseLayout(
      title: 'Página 3',
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedCourse != null)
              BoardColumn(
                flex: 7,
                title: 'Horário — ${_selectedCourse!.name}',
                icon: Icons.table_chart_outlined,
                actions: [
                  IconButton(
                    onPressed: () => setState(() => _selectedCourse = null),
                    tooltip: 'Fechar',
                    icon: const Icon(Icons.close, color: Colors.white),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                child: const EmptyTimetable(),
              )
            else
              const Expanded(
                flex: 7,
                child: EmptyColumnHint(
                  message: 'Selecione um curso para abrir a grade horária',
                ),
              ),
            BoardColumn(
              flex: 3,
              title: 'Cursos',
              icon: Icons.school_outlined,
              child: coursesAsync.when(
                data: (courses) {
                  if (courses.isEmpty) {
                    return const EmptyColumnHint(
                      message: 'Nenhum curso cadastrado',
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: courses.map((course) {
                      final selected = _selectedCourse?.id == course.id;
                      return ItemCard(
                        title: course.name,
                        selected: selected,
                        onTap: () {
                          setState(() {
                            _selectedCourse = selected ? null : course;
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
