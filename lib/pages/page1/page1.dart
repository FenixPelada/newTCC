import 'package:flutter/material.dart';
import 'package:flutter_test_project/pages/page1/columns/courseColumn.dart';
import 'package:flutter_test_project/pages/page1/columns/professorColumn.dart';
import 'package:flutter_test_project/pages/page1/columns/roomColumn.dart';
import 'package:flutter_test_project/pages/page1/columns/subjectColumn.dart';
import 'package:flutter_test_project/pages/baseLayout.dart';

class Page1 extends StatelessWidget {
  const Page1 ({super.key});


  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: "Página 1",
      body: Row(
        //mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ProfessorColumn(color: Colors.blue, text: "One"),

          SubjectColumn(color: Colors.red, text: "two"),

          RoomColumn(color: Colors.blue, text: "three"),

          CourseColumn(color: Colors.red, text: "four")
        ],
      )
    );
  }
}