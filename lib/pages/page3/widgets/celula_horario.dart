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
    required this.porCelula,
    required this.materias,
    required this.professores,
    required this.salasPorId,
    required this.ocupado,
    required this.aoTocar,
  });

  final CelulaGrade celula;
  final Map<CelulaGrade, Aula> porCelula;
  final Map<String, Materia> materias;
  final Map<String, Professor> professores;
  final Map<String, Sala> salasPorId;
  final bool ocupado;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final aula = porCelula[celula];
    final nomeMateria = aula == null ? null : materias[aula.idMateria]?.nome;
    final nomeProfessor =
        aula == null ? null : professores[aula.idProfessor]?.nome;
    final sala = aula?.idSala == null ? null : salasPorId[aula!.idSala!];

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: aula == null ? Colors.grey.shade100 : IfprColors.verdeFundo,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: ocupado ? null : aoTocar,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 68,
            child: aula == null
                ? const Center(
                    child: Icon(Icons.add, color: IfprColors.cinzaClaro),
                  )
                : Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                            'Sala ${sala.numero}',
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
                  ),
          ),
        ),
      ),
    );
  }
}
