import 'package:flutter/material.dart';

class LayoutBase extends StatelessWidget {
  final String titulo;
  final Widget body;

  const LayoutBase({super.key, required this.titulo, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Icon(Icons.calendar_month_outlined),
        ),
        title: const Text("PROJETO TIMETABLE"),
        toolbarHeight: 72,
        actions: [
          _NavButton(rotulo: "Página 1", route: "/"),
          _NavButton(rotulo: "Página 2", route: "/page2"),
          _NavButton(rotulo: "Página 3", route: "/page3"),
          const SizedBox(width: 12),
        ],
      ),
      body: body,
    );
  }
}

class _NavButton extends StatelessWidget {
  final String rotulo;
  final String route;

  const _NavButton({required this.rotulo, required this.route});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final selecionado = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: selecionado
            ? null
            : () => Navigator.pushReplacementNamed(context, route),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.white.withValues(alpha: selecionado ? 0.28 : 0.12),
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(rotulo),
      ),
    );
  }
}
