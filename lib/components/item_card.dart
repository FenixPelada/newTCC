import 'package:flutter/material.dart';
import 'package:flutter_test_project/theme/app_theme.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  const ItemCard({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: IfprColors.verdeEscuro,
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(subtitle),
              ),
          ],
        ),
      ),
    );
  }
}
