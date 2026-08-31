import 'package:flutter_test_project/components/timetable_grid.dart';

class Aula {
  Aula({
    required this.id,
    required this.courseId,
    required this.dayIndex,
    required this.periodIndex,
    required this.subjectId,
    required this.professorId,
    this.roomId,
  });

  final String id;
  final String courseId;

  /// 0 = Seg … 4 = Sex (mesmo índice do [TimetableSlot])
  final int dayIndex;

  /// 0–5 manhã, 6–11 tarde (DB: periodo 1–12)
  final int periodIndex;

  final String subjectId;
  final String professorId;
  final String? roomId;

  TimetableSlot get slot => TimetableSlot(
        dayIndex: dayIndex,
        periodIndex: periodIndex,
      );

  factory Aula.fromJson(Map<String, dynamic> json) => Aula(
        id: json['id'].toString(),
        courseId: json['id_curso'].toString(),
        // DB: dia_semana 1–5, periodo 1–12
        dayIndex: (json['dia_semana'] as num).toInt() - 1,
        periodIndex: (json['periodo'] as num).toInt() - 1,
        subjectId: json['id_materia'].toString(),
        professorId: json['id_professor'].toString(),
        roomId: json['id_sala']?.toString(),
      );

  Map<String, dynamic> toInsertJson() => {
        'id_curso': int.parse(courseId),
        'dia_semana': dayIndex + 1,
        'periodo': periodIndex + 1,
        'id_materia': int.parse(subjectId),
        'id_professor': int.parse(professorId),
        'id_sala': roomId == null ? null : int.parse(roomId!),
      };
}
