import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/services/repositories/aula_repository.dart';
import 'package:flutter_test_project/services/repositories/course_repository.dart';
import 'package:flutter_test_project/services/repositories/professor_repository.dart';
import 'package:flutter_test_project/services/repositories/room_repository.dart';
import 'package:flutter_test_project/services/repositories/subject_repository.dart';

// providers que entregam os repositórios (acesso ao supabase)

final roomRepositoryProvider = Provider<RoomRepository>(
  (ref) => RoomRepository(),
);

final professorRepositoryProvider = Provider<ProfessorRepository>(
  (ref) => ProfessorRepository(),
);

final subjectRepositoryProvider = Provider<SubjectRepository>(
  (ref) => SubjectRepository(),
);

final courseRepositoryProvider = Provider<CourseRepository>(
  (ref) => CourseRepository(),
);

final aulaRepositoryProvider = Provider<AulaRepository>(
  (ref) => AulaRepository(),
);
