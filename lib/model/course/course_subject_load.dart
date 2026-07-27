class CourseSubjectLoad {
  CourseSubjectLoad({
    required this.courseId,
    required this.subjectId,
    required this.classCount,
  });

  final String courseId;
  final String subjectId;
  final int classCount;

  factory CourseSubjectLoad.fromJson(Map<String, dynamic> json) =>
      CourseSubjectLoad(
        courseId: json['id_curso'].toString(),
        subjectId: json['id_materia'].toString(),
        classCount: (json['quantidade_aulas'] as num).toInt(),
      );

  Map<String, dynamic> toInsertJson() => {
        'id_curso': int.parse(courseId),
        'id_materia': int.parse(subjectId),
        'quantidade_aulas': classCount,
      };
}
