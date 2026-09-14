import 'package:flutter/material.dart';

Future<String?> mostrarDialogoNome(
  BuildContext context, {
  required String titulo,
  String? nomeInicial,
  String rotulo = 'Nome',
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _NameFormDialog(
      titulo: titulo,
      nomeInicial: nomeInicial,
      rotulo: rotulo,
    ),
  );
}

class _NameFormDialog extends StatefulWidget {
  const _NameFormDialog({
    required this.titulo,
    this.nomeInicial,
    required this.rotulo,
  });

  final String titulo;
  final String? nomeInicial;
  final String rotulo;

  @override
  State<_NameFormDialog> createState() => _NameFormDialogState();
}

class _NameFormDialogState extends State<_NameFormDialog> {
  late final TextEditingController _controlador;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _controlador = TextEditingController(text: widget.nomeInicial ?? '');
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _enviar() {
    final nome = _controlador.text.trim();
    if (nome.isEmpty) {
      setState(() => _erro = 'Informe um nome');
      return;
    }
    Navigator.of(context).pop(nome);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: TextField(
        controller: _controlador,
        autofocus: true,
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
