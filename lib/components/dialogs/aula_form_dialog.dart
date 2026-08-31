import 'package:flutter/material.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/room/room.dart';
import 'package:flutter_test_project/model/subject/subject.dart';

class AulaFormResult {
  const AulaFormResult({
    required this.subjectId,
    required this.professorId,
    this.roomId,
  });

  final String subjectId;
  final String professorId;
  final String? roomId;
}

/// Returned when the user confirms delete (only if [allowDelete]).
class AulaFormDelete {
  const AulaFormDelete();
}

Future<Object?> showAulaFormDialogWithDelete(
  BuildContext context, {
  required String title,
  required List<Subject> subjects,
  required List<Professor> Function(String subjectId) professorsForSubject,
  required List<Room> rooms,
  String? initialSubjectId,
  String? initialProfessorId,
  String? initialRoomId,
}) {
  return showDialog<Object>(
    context: context,
    builder: (context) => _AulaFormDialog(
      title: title,
      subjects: subjects,
      rooms: rooms,
      professorsForSubject: professorsForSubject,
      initialSubjectId: initialSubjectId,
      initialProfessorId: initialProfessorId,
      initialRoomId: initialRoomId,
      allowDelete: true,
    ),
  );
}

class _AulaFormDialog extends StatefulWidget {
  const _AulaFormDialog({
    required this.title,
    required this.subjects,
    required this.rooms,
    required this.professorsForSubject,
    this.initialSubjectId,
    this.initialProfessorId,
    this.initialRoomId,
    this.allowDelete = false,
  });

  final String title;
  final List<Subject> subjects;
  final List<Room> rooms;
  final List<Professor> Function(String subjectId) professorsForSubject;
  final String? initialSubjectId;
  final String? initialProfessorId;
  final String? initialRoomId;
  final bool allowDelete;

  @override
  State<_AulaFormDialog> createState() => _AulaFormDialogState();
}

class _AulaFormDialogState extends State<_AulaFormDialog> {
  String? _subjectId;
  String? _professorId;
  String? _roomId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _subjectId = widget.initialSubjectId;
    _professorId = widget.initialProfessorId;
    _roomId = widget.initialRoomId;
  }

  List<Professor> get _professors {
    final subjectId = _subjectId;
    if (subjectId == null) return const [];
    return widget.professorsForSubject(subjectId);
  }

  void _submit() {
    final subjectId = _subjectId;
    final professorId = _professorId;
    if (subjectId == null) {
      setState(() => _error = 'Selecione uma matéria');
      return;
    }
    if (professorId == null) {
      setState(() => _error = 'Selecione um professor');
      return;
    }
    Navigator.of(context).pop(
      AulaFormResult(
        subjectId: subjectId,
        professorId: professorId,
        roomId: _roomId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final professors = _professors;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.subjects.isEmpty)
              const Text('Este curso não tem matérias na carga horária.')
            else ...[
              DropdownButtonFormField<String>(
                key: ValueKey('subject-$_subjectId'),
                initialValue: _subjectId,
                decoration: const InputDecoration(labelText: 'Matéria'),
                items: widget.subjects
                    .map(
                      (s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _subjectId = value;
                    _professorId = null;
                    _error = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey('prof-$_subjectId-$_professorId'),
                initialValue: _professorId,
                decoration: const InputDecoration(labelText: 'Professor'),
                items: professors
                    .map(
                      (p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name),
                      ),
                    )
                    .toList(),
                onChanged: professors.isEmpty
                    ? null
                    : (value) {
                        setState(() {
                          _professorId = value;
                          _error = null;
                        });
                      },
              ),
              if (_subjectId != null && professors.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Nenhum professor disponível neste horário.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                key: ValueKey('room-$_roomId'),
                initialValue: _roomId,
                decoration: const InputDecoration(
                  labelText: 'Sala (opcional)',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Nenhuma'),
                  ),
                  ...widget.rooms.map(
                    (room) => DropdownMenuItem<String?>(
                      value: room.id,
                      child: Text('Sala ${room.number}'),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _roomId = value),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (widget.allowDelete)
          TextButton(
            onPressed: () => Navigator.of(context).pop(const AulaFormDelete()),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: widget.subjects.isEmpty ? null : _submit,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
