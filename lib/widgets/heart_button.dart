import 'package:flutter/material.dart';
import 'package:cat_app/model/cat_image.dart';
import 'package:cat_app/state/app_state.dart';
import 'package:cat_app/theme/app_theme.dart';
import 'package:cat_app/widgets/app_feedback.dart';

// Coração branco redondo: favorita / desfavorita a foto usando a API.
class HeartButton extends StatelessWidget {
  const HeartButton({super.key, required this.image, this.size = 40});

  final CatImage image;
  final double size;

  Future<void> _toggle(BuildContext context) async {
    try {
      await AppState.instance.toggleFavourite(image);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final fav = AppState.instance.isFavourite(image.id);
        return Material(
          color: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primary.withAlpha(60),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _toggle(context),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                fav ? Icons.favorite : Icons.favorite_border,
                color: AppColors.pink,
                size: size * 0.52,
              ),
            ),
          ),
        );
      },
    );
  }
}
