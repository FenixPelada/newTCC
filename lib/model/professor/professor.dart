import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test_project/model/professor/availableDays.dart';
import 'package:flutter_test_project/model/subject/subject.dart';

class Professor {

  Professor ({required this.id, required this.name, required this.availableDays, required this.subjects});
  
  final String id;
  final String name;
  final Availabledays availableDays;
  final List<Subject> subjects;
}