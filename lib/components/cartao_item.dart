import 'package:flutter/material.dart';
import 'package:flutter_test_project/theme/app_theme.dart';

class CartaoItem extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final VoidCallback? aoTocar;
  final VoidCallback? aoEditar;
  final VoidCallback? aoExcluir;
  final bool selecionado;

  const CartaoItem({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.aoTocar,
    this.aoEditar,
    this.aoExcluir,
    this.selecionado = false,
  });

  @override
  Widget build(BuildContext context) {
    final subtitulo = this.subtitulo;
    final hasActions = aoEditar != null || aoExcluir != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: selecionado ? IfprColors.verdeFundo : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: selecionado
            ? const BorderSide(color: IfprColors.verde, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: aoTocar,
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
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: IfprColors.verdeEscuro,
                      ),
                    ),
                    if (subtitulo != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitulo,
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
                if (aoEditar != null)
                  IconButton(
                    onPressed: aoEditar,
                    tooltip: 'Editar',
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: IfprColors.verdeEscuro,
                    visualDensity: VisualDensity.compact,
                  ),
                if (aoExcluir != null)
                  IconButton(
                    onPressed: aoExcluir,
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
