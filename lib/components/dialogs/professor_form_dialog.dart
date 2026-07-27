import 'package:flutter/material.dart';
import 'package:flutter_test_project/model/subject/subject.dart';

class ProfessorFormResult {
  const ProfessorFormResult({
    required this.name,
    required this.subjectIds,
  });

  final String name;
  final List<String> subjectIds;
}

Future<ProfessorFormResult?> showProfessorFormDialog(
  BuildContext context, {
  required String title,
  required List<Subject> subjects,
  String? initialName,
  List<String> initialSubjectIds = const [],
}) {
  return showDialog<ProfessorFormResult>(
    context: context,
    builder: (context) => _ProfessorFormDialog(
      title: title,
      subjects: subjects,
      initialName: initialName,
      initialSubjectIds: initialSubjectIds,
    ),
  );
}

class _ProfessorFormDialog extends StatefulWidget {
  const _ProfessorFormDialog({
    required this.title,
    required this.subjects,
    this.initialName,
    required this.initialSubjectIds,
  });

  final String title;
  final List<Subject> subjects;
  final String? initialName;
  final List<String> initialSubjectIds;

  @override
  State<_ProfessorFormDialog> createState() => _ProfessorFormDialogState();
}

class _ProfessorFormDialogState extends State<_ProfessorFormDialog> {
  late final TextEditingController _controller;
  late final Set<String> _selectedIds;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
    _selectedIds = {...widget.initialSubjectIds};
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Informe um nome');
      return;
    }
    Navigator.of(context).pop(
      ProfessorFormResult(
        name: name,
        subjectIds: _selectedIds.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nome',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Matérias que leciona',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (widget.subjects.isEmpty)
              const Text('Nenhuma matéria cadastrada ainda.')
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: SingleChildScrollView(
                  child: Column(
                    children: widget.subjects.map((subject) {
                      final selected = _selectedIds.contains(subject.id);
                      return CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: selected,
                        title: Text(subject.name),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedIds.add(subject.id);
                            } else {
                              _selectedIds.remove(subject.id);
                            }
                          });
                        },
                      );
                    }).toList(),
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
