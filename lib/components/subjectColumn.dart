import 'package:flutter/material.dart';

class SubjectColumn extends StatelessWidget {

  final Color color;
  final String text;

  const SubjectColumn({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text(text, style: TextStyle(fontSize: 30))],
        ),
      ),
    );
  }
}