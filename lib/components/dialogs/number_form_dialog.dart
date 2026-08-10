import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<int?> showNumberFormDialog(
  BuildContext context, {
  required String title,
  int? initialNumber,
  String label = 'Número',
}) {
  return showDialog<int>(
    context: context,
    builder: (context) => _NumberFormDialog(
      title: title,
      initialNumber: initialNumber,
      label: label,
    ),
  );
}

class _NumberFormDialog extends StatefulWidget {
  const _NumberFormDialog({
    required this.title,
    this.initialNumber,
    required this.label,
  });

  final String title;
  final int? initialNumber;
  final String label;

  @override
  State<_NumberFormDialog> createState() => _NumberFormDialogState();
}

class _NumberFormDialogState extends State<_NumberFormDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialNumber?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text.trim();
    final number = int.tryParse(raw);
    if (number == null || number < 1) {
      setState(() => _error = 'Informe um número válido (≥ 1)');
      return;
    }
    Navigator.of(context).pop(number);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
