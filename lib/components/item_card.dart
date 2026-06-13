import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  const ItemCard({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return Container(
      color: Colors.blueGrey,
      child: Column(
        children: [Text(title), if (subtitle != null) Text(subtitle)],
      ),
    );
  }
}
