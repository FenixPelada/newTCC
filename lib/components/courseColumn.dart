import 'package:flutter/material.dart';

class CourseColumn extends StatelessWidget {

  final Color color;
  final String text;

  const CourseColumn({super.key, required this.text, required this.color});

  void createItem(){
    
  }
  
  void deleteItem(){
    
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.topCenter,
        color: color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(text,style: TextStyle(fontSize: 30)),

            SizedBox(width: 10),

            FilledButton(onPressed: (){}, child: Text("Adicionar")),

            SizedBox(width: 10),

            FilledButton(onPressed: (){}, child: Text("Remover")),
            ],
        ),
      ),
    );
  }
}