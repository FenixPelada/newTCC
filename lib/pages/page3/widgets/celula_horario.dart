import 'package:flutter/material.dart';
import 'package:flutter_test_project/components/grade_horaria.dart';
import 'package:flutter_test_project/model/aula/aula.dart';
import 'package:flutter_test_project/model/materia/materia.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/sala/sala.dart';
import 'package:flutter_test_project/theme/app_theme.dart';

class CelulaHorario extends StatelessWidget {
  const CelulaHorario({
    super.key,
    required this.celula,
    required this.aulas,
    required this.materias,
    required this.professores,
    required this.salasPorId,
    required this.ocupado,
    required this.aoTocar,
  });

  final CelulaGrade celula;
  final List<Aula> aulas;
  final Map<String, Materia> materias;
  final Map<String, Professor> professores;
  final Map<String, Sala> salasPorId;
  final bool ocupado;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final ordenadas = List<Aula>.from(aulas)
      ..sort((a, b) => a.grupo.compareTo(b.grupo));

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: ordenadas.isEmpty ? Colors.grey.shade100 : IfprColors.verdeFundo,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: ocupado ? null : aoTocar,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: ordenadas.length > 1 ? 88 : 68,
            child: ordenadas.isEmpty
                ? const Center(
                    child: Icon(Icons.add, color: IfprColors.cinzaClaro),
                  )
                : ordenadas.length == 1
                    ? _conteudoAula(ordenadas.first)
                    : Row(
                        children: [
                          for (var i = 0; i < ordenadas.length; i++) ...[
                            if (i > 0)
                              Container(
                                width: 1,
                                color: IfprColors.verde.withValues(alpha: 0.35),
                              ),
                            Expanded(child: _conteudoAula(ordenadas[i])),
                          ],
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  Widget _conteudoAula(Aula aula) {
    final nomeMateria = materias[aula.idMateria]?.nome;
    final nomeProfessor = professores[aula.idProfessor]?.nome;
    final sala = aula.idSala == null ? null : salasPorId[aula.idSala!];

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'G${aula.grupo}',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: IfprColors.verde,
            ),
          ),
          Text(
            nomeMateria ?? 'Matéria',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: IfprColors.verdeEscuro,
            ),
          ),
          Text(
            nomeProfessor ?? 'Professor',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: IfprColors.cinzaClaro,
            ),
          ),
          if (sala != null)
            Text(
              sala.rotulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: IfprColors.verde,
              ),
            ),
        ],
      ),
    );
  }
}
