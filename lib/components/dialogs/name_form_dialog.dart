import 'package:flutter/material.dart';

Future<String?> showNameFormDialog(
  BuildContext context, {
  required String title,
  String? initialName,
  String label = 'Nome',
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _NameFormDialog(
      title: title,
      initialName: initialName,
      label: label,
    ),
  );
}

class _NameFormDialog extends StatefulWidget {
  const _NameFormDialog({
    required this.title,
    this.initialName,
    required this.label,
  });

  final String title;
  final String? initialName;
  final String label;

  @override
  State<_NameFormDialog> createState() => _NameFormDialogState();
}

class _NameFormDialogState extends State<_NameFormDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
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
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: widget.label,
          errorText: _error,
        ),
        onSubmitted: (_) => _submit(),
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
