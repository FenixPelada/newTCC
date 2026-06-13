import 'package:flutter/material.dart';

class CourseItem extends StatelessWidget {
  const CourseItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.brown,
          height: 200,
          
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }
}