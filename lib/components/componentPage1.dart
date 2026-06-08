import 'package:flutter/material.dart';

class ComponentPage1 extends StatelessWidget {
  final Color color;
  final String text;

  const ComponentPage1({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: color,
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text(text, style: TextStyle(fontSize: 30))],
        ),
      ),
    );
  }
}
