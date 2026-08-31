import 'package:flutter_test_project/model/course/course_period_preference.dart';

class Course {
  Course({
    required this.id,
    required this.name,
    this.roomId,
    this.periodPreference = CoursePeriodPreference.manha,
  });

  final String id;
  final String name;

  /// Sala padrão do curso (opcional).
  final String? roomId;

  /// Manhã, tarde ou contraturno (manhã primeiro, resto na tarde).
  final CoursePeriodPreference periodPreference;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'].toString(),
        name: json['nome'] as String,
        roomId: json['id_sala']?.toString(),
        periodPreference: CoursePeriodPreference.fromDb(
          json['periodo_preferencia'] as String?,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': name,
        if (roomId != null) 'id_sala': int.parse(roomId!),
        'periodo_preferencia': periodPreference.toDb(),
      };

  Map<String, dynamic> toInsertJson() => {
        'nome': name,
        if (roomId != null) 'id_sala': int.parse(roomId!),
        'periodo_preferencia': periodPreference.toDb(),
      };
}
