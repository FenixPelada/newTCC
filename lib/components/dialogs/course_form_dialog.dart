import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test_project/model/course/course_subject_load.dart';
import 'package:flutter_test_project/model/subject/subject.dart';

class CourseFormResult {
  const CourseFormResult({
    required this.name,
    required this.loads,
  });

  final String name;
  final List<CourseSubjectLoad> loads;
}

class _LoadRow {
  _LoadRow({this.subjectId, int classCount = 1})
      : countController = TextEditingController(text: '$classCount');

  String? subjectId;
  final TextEditingController countController;

  void dispose() => countController.dispose();
}

Future<CourseFormResult?> showCourseFormDialog(
  BuildContext context, {
  required String title,
  required List<Subject> subjects,
  String? initialName,
  List<CourseSubjectLoad> initialLoads = const [],
  String courseId = '0',
}) {
  return showDialog<CourseFormResult>(
    context: context,
    builder: (context) => _CourseFormDialog(
      title: title,
      subjects: subjects,
      initialName: initialName,
      initialLoads: initialLoads,
      courseId: courseId,
    ),
  );
}

class _CourseFormDialog extends StatefulWidget {
  const _CourseFormDialog({
    required this.title,
    required this.subjects,
    this.initialName,
    required this.initialLoads,
    required this.courseId,
  });

  final String title;
  final List<Subject> subjects;
  final String? initialName;
  final List<CourseSubjectLoad> initialLoads;
  final String courseId;

  @override
  State<_CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<_CourseFormDialog> {
  late final TextEditingController _nameController;
  late final List<_LoadRow> _rows;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    if (widget.initialLoads.isEmpty) {
      _rows = [_LoadRow()];
    } else {
      _rows = widget.initialLoads
          .map(
            (load) => _LoadRow(
              subjectId: load.subjectId,
              classCount: load.classCount,
            ),
          )
          .toList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow() => setState(() => _rows.add(_LoadRow()));

  void _removeRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
      if (_rows.isEmpty) _rows.add(_LoadRow());
    });
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Informe o nome do curso');
      return;
    }

    final loads = <CourseSubjectLoad>[];
    final seenSubjects = <String>{};

    for (final row in _rows) {
      final subjectId = row.subjectId;
      if (subjectId == null) continue;

      final count = int.tryParse(row.countController.text.trim());
      if (count == null || count < 1) {
        setState(() => _error = 'Quantidade de aulas deve ser um número ≥ 1');
        return;
      }
      if (!seenSubjects.add(subjectId)) {
        setState(() => _error = 'Cada matéria só pode aparecer uma vez');
        return;
      }

      loads.add(
        CourseSubjectLoad(
          courseId: widget.courseId,
          subjectId: subjectId,
          classCount: count,
        ),
      );
    }

    setState(() => _error = null);
    Navigator.of(context).pop(CourseFormResult(name: name, loads: loads));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nome do curso',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Matérias e quantidade de aulas',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton.icon(
                  onPressed: widget.subjects.isEmpty ? null : _addRow,
                  icon: const Icon(Icons.add),
                  label: const Text('Linha'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.subjects.isEmpty)
              const Text('Cadastre matérias antes de definir a carga horária.')
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < _rows.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  key: ValueKey(
                                    'load-$i-${_rows[i].subjectId}',
                                  ),
                                  initialValue: _rows[i].subjectId,
                                  decoration: const InputDecoration(
                                    labelText: 'Matéria',
                                    isDense: true,
                                  ),
                                  items: widget.subjects
                                      .map(
                                        (subject) => DropdownMenuItem(
                                          value: subject.id,
                                          child: Text(subject.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() => _rows[i].subjectId = value);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _rows[i].countController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'Aulas',
                                    isDense: true,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeRow(i),
                                tooltip: 'Remover linha',
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
