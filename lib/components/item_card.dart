import 'package:flutter/material.dart';
import 'package:flutter_test_project/theme/app_theme.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool selected;

  const ItemCard({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final hasActions = onEdit != null || onDelete != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: selected ? IfprColors.verdeFundo : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: selected
            ? const BorderSide(color: IfprColors.verde, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
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
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            color: IfprColors.cinzaClaro,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (hasActions) ...[
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    tooltip: 'Editar',
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: IfprColors.verdeEscuro,
                    visualDensity: VisualDensity.compact,
                  ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    tooltip: 'Excluir',
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Colors.red.shade700,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
