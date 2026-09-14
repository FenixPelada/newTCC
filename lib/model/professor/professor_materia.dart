class ProfessorMateria {
  ProfessorMateria({
    required this.idProfessor,
    required this.idMateria,
  });

  final String idProfessor;
  final String idMateria;

  factory ProfessorMateria.fromJson(Map<String, dynamic> json) =>
      ProfessorMateria(
        idProfessor: json['id_professor'].toString(),
        idMateria: json['id_materia'].toString(),
      );

  Map<String, dynamic> toInsertJson() => {
        'id_professor': int.parse(idProfessor),
        'id_materia': int.parse(idMateria),
      };
}
