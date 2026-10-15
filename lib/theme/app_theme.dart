import 'package:flutter/material.dart';

// Cores tiradas do wireframe.
class AppColors {
  static const Color primary = Color(0xFF5B3CF5); // roxo dos botões
  static const Color primaryLight = Color(0xFF7459FA); // círculos decorativos
  static const Color background = Color(0xFFF5F3FF); // fundo das telas
  static const Color ink = Color(0xFF1C1838); // texto escuro
  static const Color muted = Color(0xFF6E6A8C); // texto secundário
  static const Color pink = Color(0xFFFF5C7A);
  static const Color green = Color(0xFF16C784);
  static const Color orange = Color(0xFFFFB020);

  // Fundos pastel dos cards (usados também como "placeholder" das fotos).
  static const List<Color> pastels = [
    Color(0xFFFFD9E0), // rosa
    Color(0xFFE0DBFF), // lilás
    Color(0xFFD7F5E7), // verde
    Color(0xFFFFE8C7), // laranja
  ];

  // Cor do ícone de gatinho que combina com cada pastel.
  static const List<Color> pastelInks = [
    Color(0xFFEE8AA0),
    Color(0xFF9B8AF5),
    Color(0xFF6CC7A0),
    Color(0xFFE5B060),
  ];

  static Color pastel(int i) => pastels[i % pastels.length];
  static Color pastelInk(int i) => pastelInks[i % pastelInks.length];
}

class AppTheme {
  static ThemeData get light {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.background,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: ThemeData.light().textTheme.apply(
            bodyColor: AppColors.ink,
            displayColor: AppColors.ink,
          ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// Sombra suave usada nos cards brancos e botões redondos.
List<BoxShadow> softShadow([double alpha = 0.10]) => [
      BoxShadow(
        color: AppColors.primary.withAlpha((alpha * 255).round()),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
