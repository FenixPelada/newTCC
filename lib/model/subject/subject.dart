import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test_project/model/course/course.dart';
import 'package:flutter_test_project/model/professor/professor.dart';

class Subject {
  Subject({required this.id, required this.name, required this.professors, required this.courses});
  
  final String id;
  final String name;
  final List<Professor> professors;
  final List<Course> courses;
}