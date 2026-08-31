import 'package:flutter_test_project/components/timetable_grid.dart';

class ProfessorUnavailability {
  ProfessorUnavailability({
    required this.id,
    required this.professorId,
    required this.dayIndex,
    required this.periodIndex,
  });

  final String id;
  final String professorId;

  /// 0 = Seg … 4 = Sex
  final int dayIndex;

  /// 0–5 manhã, 6–11 tarde (DB: periodo 1–12)
  final int periodIndex;

  TimetableSlot get slot => TimetableSlot(
        dayIndex: dayIndex,
        periodIndex: periodIndex,
      );

  factory ProfessorUnavailability.fromJson(Map<String, dynamic> json) =>
      ProfessorUnavailability(
        id: json['id'].toString(),
        professorId: json['id_professor'].toString(),
        dayIndex: (json['dia_semana'] as num).toInt() - 1,
        periodIndex: (json['periodo'] as num).toInt() - 1,
      );

  Map<String, dynamic> toInsertJson() => {
        'id_professor': int.parse(professorId),
        'dia_semana': dayIndex + 1,
        'periodo': periodIndex + 1,
      };
}
