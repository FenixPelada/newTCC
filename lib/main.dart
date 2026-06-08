import 'package:flutter/material.dart';
import 'package:flutter_test_project/pages/page1.dart';
import 'package:flutter_test_project/pages/page2.dart';
import 'package:flutter_test_project/pages/page3.dart';


void main() {
  runApp(
    MaterialApp(
      title: "Timetable project",
      initialRoute: "/",
      routes: {
        "/": (context) => const Page1(),
        "/page2": (context) => const Page2(),
        "/page3": (context) => const Page3(),
      },
    )
  );
}