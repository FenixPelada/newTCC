import 'package:flutter/material.dart';

class BaseLayout extends StatelessWidget {
  final String title;
  final Widget body;

  const BaseLayout({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PROJETO TIMETABLE"),
        backgroundColor: Colors.grey,
        toolbarHeight: 110,
        actions: [

          FilledButton(
            onPressed: () => Navigator.pushNamed(context, "/"),
            style: FilledButton.styleFrom(backgroundColor: Colors.blue),
            child: Text("Página 1"),
          ),
          
          SizedBox(width: 10),

          FilledButton(
            onPressed: () => Navigator.pushNamed(context, "/page2"),
            style: FilledButton.styleFrom(backgroundColor: Colors.blue),
            child: Text("Página 2"),
          ),

          SizedBox(width: 10),

          FilledButton(
            onPressed: () => Navigator.pushNamed(context, "/page3"),
            style: FilledButton.styleFrom(backgroundColor: Colors.blue),
            child: Text("Página 3"),
          ),

          SizedBox(width: 20),
        ],
      ),
      body: body,
    );
  }
}
