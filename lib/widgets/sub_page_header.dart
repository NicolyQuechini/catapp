import 'package:flutter/material.dart';
import 'package:cat_app/state/navigation.dart';
import 'package:cat_app/theme/app_theme.dart';

// Botão redondo branco de "voltar".
class BackCircleButton extends StatelessWidget {
  const BackCircleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: AppColors.primary.withAlpha(60),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          final nav = Navigator.of(context);
          if (nav.canPop()) {
            nav.pop(); // tela interna: volta para a anterior
          } else {
            currentTab.value = 0; // tela principal de uma aba: volta para Descobrir
          }
        },
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.chevron_left, size: 28),
        ),
      ),
    );
  }
}

// Cabeçalho das telas internas: botão de voltar + título.
class SubPageHeader extends StatelessWidget {
  const SubPageHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          const BackCircleButton(),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}