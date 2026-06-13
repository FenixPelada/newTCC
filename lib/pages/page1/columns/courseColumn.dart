import 'package:flutter/material.dart';

class CourseColumn extends StatefulWidget {

  final Color color;
  final String text;

  const CourseColumn({super.key, required this.color, required this.text});

  void addItem(){
    
  }

  @override
  State<CourseColumn> createState() => _CourseColumnState();
}

class _CourseColumnState extends State<CourseColumn> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Row(
              children: [
                Text(widget.text, style: TextStyle(fontSize: 30)),
                SizedBox(width: 10),
                FilledButton(
                  onPressed: (){
                    widget.addItem();
                  },
                  child: Text("Adicionar")
                ),
                SizedBox(width: 10),
                FilledButton(onPressed: (){}, child: Text("Remover")),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                  ],
                ),
              )
            )
          ],
        ),
      )
    );
  }
}