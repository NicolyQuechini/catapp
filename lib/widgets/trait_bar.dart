import 'package:flutter/material.dart';
import 'package:cat_app/theme/app_theme.dart';

// Barra de característica da raça (Afeto, Energia...) com valor de 1 a 5.
class TraitBar extends StatelessWidget {
  const TraitBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int? value; // pode não vir da API
  final Color color;

  @override
  Widget build(BuildContext context) {
    final v = (value ?? 0).clamp(0, 5);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value == null ? 'sem dados' : '$v de 5',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: v / 5,
              minHeight: 10,
              color: color,
              backgroundColor: const Color(0xFFE6E3F5),
            ),
          ),
        ],
      ),
    );
  }
}
