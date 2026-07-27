import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/model/course/course.dart';
import 'package:flutter_test_project/model/course/course_subject_load.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/professor/professor_subject.dart';
import 'package:flutter_test_project/model/room/room.dart';
import 'package:flutter_test_project/model/subject/subject.dart';
import 'package:flutter_test_project/providers/repository_providers.dart';

// streamProviders: escutam os streams realtime dos repos

/// usa .when(loading:, error:, data:) pra renderizar
final roomsProvider = StreamProvider<List<Room>>((ref) {
  return ref.read(roomRepositoryProvider).watchAll();
});

final professorsProvider = StreamProvider<List<Professor>>((ref) {
  return ref.read(professorRepositoryProvider).watchAll();
});

final professorSubjectsProvider = StreamProvider<List<ProfessorSubject>>((ref) {
  return ref.read(professorRepositoryProvider).watchSubjectLinks();
});

final subjectsProvider = StreamProvider<List<Subject>>((ref) {
  return ref.read(subjectRepositoryProvider).watchAll();
});

final coursesProvider = StreamProvider<List<Course>>((ref) {
  return ref.read(courseRepositoryProvider).watchAll();
});

final courseLoadsProvider = StreamProvider<List<CourseSubjectLoad>>((ref) {
  return ref.read(courseRepositoryProvider).watchLoads();
});
