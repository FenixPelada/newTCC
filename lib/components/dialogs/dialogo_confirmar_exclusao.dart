import 'package:flutter/material.dart';

Future<bool> mostrarDialogoConfirmarExclusao(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  String rotuloConfirmar = 'Excluir',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(rotuloConfirmar),
        ),
      ],
    ),
  );
  return result ?? false;
}
