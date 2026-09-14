import 'package:flutter_test_project/components/grade_horaria.dart';

class Aula {
  Aula({
    required this.id,
    required this.idCurso,
    required this.indiceDia,
    required this.indicePeriodo,
    required this.idMateria,
    required this.idProfessor,
    this.idSala,
  });

  final String id;
  final String idCurso;

  /// 0 = Seg … 4 = Sex (mesmo índice do [CelulaGrade])
  final int indiceDia;

  /// 0–5 manhã, 6–11 tarde (DB: periodo 1–12)
  final int indicePeriodo;

  final String idMateria;
  final String idProfessor;
  final String? idSala;

  CelulaGrade get celula => CelulaGrade(
        indiceDia: indiceDia,
        indicePeriodo: indicePeriodo,
      );

  factory Aula.fromJson(Map<String, dynamic> json) => Aula(
        id: json['id'].toString(),
        idCurso: json['id_curso'].toString(),
        // DB: dia_semana 1–5, periodo 1–12
        indiceDia: (json['dia_semana'] as num).toInt() - 1,
        indicePeriodo: (json['periodo'] as num).toInt() - 1,
        idMateria: json['id_materia'].toString(),
        idProfessor: json['id_professor'].toString(),
        idSala: json['id_sala']?.toString(),
      );

  Map<String, dynamic> toInsertJson() => {
        'id_curso': int.parse(idCurso),
        'dia_semana': indiceDia + 1,
        'periodo': indicePeriodo + 1,
        'id_materia': int.parse(idMateria),
        'id_professor': int.parse(idProfessor),
        'id_sala': idSala == null ? null : int.parse(idSala!),
      };
}
