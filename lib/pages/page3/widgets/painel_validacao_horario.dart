import 'package:flutter/material.dart';
import 'package:flutter_test_project/services/validador_horario.dart';

class PainelValidacaoHorario extends StatelessWidget {
  const PainelValidacaoHorario({
    super.key,
    required this.validacao,
  });

  final ValidacaoHorario validacao;

  @override
  Widget build(BuildContext context) {
    final ok = validacao.ok;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ok ? Colors.green.shade50 : Colors.red.shade50,
        border: Border(
          top: BorderSide(
            color: ok ? Colors.green.shade200 : Colors.red.shade200,
          ),
        ),
      ),
      child: ok
          ? Text(
              'Sem problemas',
              style: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.w600,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: validacao.problemas
                  .map(
                    (problema) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        problema,
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
