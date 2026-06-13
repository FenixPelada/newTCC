import 'package:flutter/material.dart';

class IfprColors {
  static const Color verde = Color(0xFF4C8C2B); //principal
  static const Color verdeClaroMarca = Color(0xFF509E2F);
  static const Color verdeEscuro = Color(0xFF3A6B20); // topo / cabeçalhos
  static const Color verdeFundo = Color(0xFFEAF3E4); // superfícies suaves
  static const Color cinzaTexto = Color(0xFF374151);
  static const Color cinzaClaro = Color(0xFF6B7280);
}

ThemeData buildIfprTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: IfprColors.verde,
    primary: IfprColors.verde,
    secondary: IfprColors.verdeClaroMarca,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFF3F6F1),
    textTheme: const TextTheme().apply(
      bodyColor: IfprColors.cinzaTexto,
      displayColor: IfprColors.cinzaTexto,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: IfprColors.verdeEscuro,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: IfprColors.verde,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: IfprColors.verde,
        side: const BorderSide(color: IfprColors.verde),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
