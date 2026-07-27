class ProfessorSubject {
  ProfessorSubject({
    required this.professorId,
    required this.subjectId,
  });

  final String professorId;
  final String subjectId;

  factory ProfessorSubject.fromJson(Map<String, dynamic> json) =>
      ProfessorSubject(
        professorId: json['id_professor'].toString(),
        subjectId: json['id_materia'].toString(),
      );

  Map<String, dynamic> toInsertJson() => {
        'id_professor': int.parse(professorId),
        'id_materia': int.parse(subjectId),
      };
}
