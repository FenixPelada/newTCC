import 'package:flutter_test_project/model/subject/subject.dart';

class Course {
  Course({required this.id, required this.name, required this.subjects});

  final String id;
  final String name;
  final Map<Subject, int> subjects;
}