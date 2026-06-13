import 'package:flutter/material.dart';
import 'package:flutter_test_project/model/course/course.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/room/room.dart';
import 'package:flutter_test_project/model/subject/subject.dart';


class Database extends ChangeNotifier {
  get getCharacters => courses;
  get getProfessors => professors;
  get getRooms => rooms;
  get getSubjects => subjects;

  final List<Course> courses = [];

  final List<Professor> professors = [];

  final List<Room> rooms = [];

  final List<Subject> subjects = [];

  void addCourse(Course course) {
    courses.add(course);
    notifyListeners();
  }

  void addProfessor(Professor professor) {
    professors.add(professor);
    notifyListeners();
  }

  void addRoom(Room room) {
    rooms.add(room);
    notifyListeners();
  }

  void addSubject(Subject subject) {
    subjects.add(subject);
    notifyListeners();
  }
}