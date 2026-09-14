import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<int?> mostrarDialogoNumero(
  BuildContext context, {
  required String titulo,
  int? numeroInicial,
  String rotulo = 'Número',
}) {
  return showDialog<int>(
    context: context,
    builder: (context) => _NumberFormDialog(
      titulo: titulo,
      numeroInicial: numeroInicial,
      rotulo: rotulo,
    ),
  );
}

class _NumberFormDialog extends StatefulWidget {
  const _NumberFormDialog({
    required this.titulo,
    this.numeroInicial,
    required this.rotulo,
  });

  final String titulo;
  final int? numeroInicial;
  final String rotulo;

  @override
  State<_NumberFormDialog> createState() => _NumberFormDialogState();
}

class _NumberFormDialogState extends State<_NumberFormDialog> {
  late final TextEditingController _controlador;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _controlador = TextEditingController(
      text: widget.numeroInicial?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _enviar() {
    final raw = _controlador.text.trim();
    final numero = int.tryParse(raw);
    if (numero == null || numero < 1) {
      setState(() => _erro = 'Informe um número válido (≥ 1)');
      return;
    }
    Navigator.of(context).pop(numero);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: TextField(
        controller: _controlador,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: widget.rotulo,
          errorText: _erro,
        ),
        onSubmitted: (_) => _enviar(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _enviar,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
