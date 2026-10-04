import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test_project/model/sala/sala.dart';

class DadosSala {
  const DadosSala({required this.numero, required this.tipo});

  final int numero;
  final TipoSala tipo;
}

Future<DadosSala?> mostrarDialogoNumero(
  BuildContext context, {
  required String titulo,
  int? numeroInicial,
  TipoSala tipoInicial = TipoSala.salaAula,
  String rotulo = 'Número',
}) {
  return showDialog<DadosSala>(
    context: context,
    builder: (context) => _NumberFormDialog(
      titulo: titulo,
      numeroInicial: numeroInicial,
      tipoInicial: tipoInicial,
      rotulo: rotulo,
    ),
  );
}

class _NumberFormDialog extends StatefulWidget {
  const _NumberFormDialog({
    required this.titulo,
    this.numeroInicial,
    required this.tipoInicial,
    required this.rotulo,
  });

  final String titulo;
  final int? numeroInicial;
  final TipoSala tipoInicial;
  final String rotulo;

  @override
  State<_NumberFormDialog> createState() => _NumberFormDialogState();
}

class _NumberFormDialogState extends State<_NumberFormDialog> {
  late final TextEditingController _controlador;
  late TipoSala _tipo;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _tipo = widget.tipoInicial;
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
    Navigator.of(context).pop(DadosSala(numero: numero, tipo: _tipo));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<TipoSala>(
              key: ValueKey('tipo-$_tipo'),
              initialValue: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: TipoSala.values
                  .map(
                    (tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo.rotulo),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _tipo = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _enviar, child: const Text('Salvar')),
      ],
    );
  }
}
