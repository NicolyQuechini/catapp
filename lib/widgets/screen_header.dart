import 'package:flutter/material.dart';
import 'package:cat_app/state/app_state.dart';
import 'package:cat_app/state/navigation.dart';
import 'package:cat_app/theme/app_theme.dart';
import 'package:cat_app/widgets/sub_page_header.dart';

// Cabeçalho das telas: subtítulo pequeno, título grande e o avatar do usuário.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.subtitle,
    required this.title,
    this.showBack = false,
  });

  final String subtitle;
  final String title;
  final bool showBack; // mostra a seta de voltar à esquerda

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBack) ...[
            const BackCircleButton(),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.muted, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const UserAvatar(),
        ],
      ),
    );
  }
}

// Círculo rosa com a inicial do usuário. Ao tocar, abre a aba Perfil.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.size = 48, this.tappable = true});

  final double size;
  final bool tappable;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        return GestureDetector(
          onTap: tappable ? () => currentTab.value = 4 : null,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.pink,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink.withAlpha(90),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              AppState.instance.initial,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      },
    );
  }
}