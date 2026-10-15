import 'package:flutter/material.dart';
import 'package:cat_app/theme/app_theme.dart';

// Campo de busca branco e arredondado (Buscar gatos... / Buscar raça...).
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: softShadow(0.06),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 17),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: hint,
                  hintStyle:
                      const TextStyle(color: AppColors.muted, fontSize: 17),
                ),
              ),
            ),
            // botão "limpar" aparece só quando há texto
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: const Icon(Icons.close, size: 20, color: AppColors.muted),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
