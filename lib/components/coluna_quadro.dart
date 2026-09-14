import 'package:flutter/material.dart';
import 'package:flutter_test_project/theme/app_theme.dart';

class ColunaQuadro extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final Widget child;
  final int flex;

  final List<Widget> acoes;

  const ColunaQuadro({
    super.key,
    required this.titulo,
    required this.icone,
    required this.child,
    this.acoes = const [],
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8E0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: IfprColors.verde,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Icon(icone, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ...acoes,
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class DicaColunaVazia extends StatelessWidget {
  final String mensagem;
  const DicaColunaVazia({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          mensagem,
          textAlign: TextAlign.center,
          style: const TextStyle(color: IfprColors.cinzaClaro),
        ),
      ),
    );
  }
}
