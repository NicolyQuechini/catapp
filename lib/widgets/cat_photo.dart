import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cat_app/theme/app_theme.dart';

// Fundo pastel com a patinha, mostrado enquanto a foto carrega (ou se falhar).
class CatPlaceholder extends StatelessWidget {
  const CatPlaceholder({super.key, this.colorIndex = 0, this.iconSize = 40});

  final int colorIndex;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.pastel(colorIndex),
      child: Center(
        child: Icon(
          Icons.pets,
          size: iconSize,
          color: AppColors.pastelInk(colorIndex),
        ),
      ),
    );
  }
}

// Foto de gato da internet, com cache em disco (pacote cached_network_image).
class CatPhoto extends StatelessWidget {
  const CatPhoto({
    super.key,
    required this.url,
    this.colorIndex = 0,
    this.fit = BoxFit.cover,
    this.iconSize = 40,
  });

  final String? url;
  final int colorIndex;
  final BoxFit fit;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final u = url;
    if (u == null || u.isEmpty) {
      return CatPlaceholder(colorIndex: colorIndex, iconSize: iconSize);
    }

    // No Chrome, usa a tag de imagem do navegador (evita o bloqueio de CORS).
    if (kIsWeb) {
      return Image.network(
        u,
        fit: fit,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : CatPlaceholder(colorIndex: colorIndex, iconSize: iconSize),
        errorBuilder: (_, __, ___) =>
            CatPlaceholder(colorIndex: colorIndex, iconSize: iconSize),
      );
    }

    return CachedNetworkImage(
      imageUrl: u,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, __) =>
          CatPlaceholder(colorIndex: colorIndex, iconSize: iconSize),
      errorWidget: (_, __, ___) =>
          CatPlaceholder(colorIndex: colorIndex, iconSize: iconSize),
    );
  }
}
