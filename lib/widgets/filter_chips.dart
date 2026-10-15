import 'package:flutter/material.dart';
import 'package:cat_app/theme/app_theme.dart';

// Linha de "pílulas" rolável na horizontal (Todos, Chapéus, Espaço...).
class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final ativo = i == selected;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: ativo ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: ativo ? softShadow(0.25) : null,
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: ativo ? Colors.white : AppColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
