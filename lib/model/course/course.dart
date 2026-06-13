import 'dart:nativewrappers/_internal/vm/lib/ffi_patch.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test_project/model/subject/subject.dart';

class Course {
  Course({required this.id, required this.name, required this.subjects});

  final String id;
  final String name;
  final Map<Subject, int> subjects;
}