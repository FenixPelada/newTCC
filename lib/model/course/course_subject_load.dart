class CourseSubjectLoad {
  CourseSubjectLoad({
    required this.courseId,
    required this.subjectId,
    required this.classCount,
    this.blockSize = 1,
  });

  final String courseId;
  final String subjectId;
  final int classCount;

  /// Aulas consecutivas no mesmo dia: 1 ou 2.
  final int blockSize;

  factory CourseSubjectLoad.fromJson(Map<String, dynamic> json) =>
      CourseSubjectLoad(
        courseId: json['id_curso'].toString(),
        subjectId: json['id_materia'].toString(),
        classCount: (json['quantidade_aulas'] as num).toInt(),
        blockSize: (json['tamanho_bloco'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toInsertJson() => {
        'id_curso': int.parse(courseId),
        'id_materia': int.parse(subjectId),
        'quantidade_aulas': classCount,
        'tamanho_bloco': blockSize,
      };
}
