import 'package:flutter/material.dart';
import 'package:cat_app/model/cat_image.dart';
import 'package:cat_app/widgets/cat_photo.dart';
import 'package:cat_app/widgets/heart_button.dart';

// Card de foto com coração no canto e, se houver, o nome da raça embaixo.
class CatImageCard extends StatelessWidget {
  const CatImageCard({
    super.key,
    required this.image,
    required this.index,
    required this.aspectRatio,
    this.showBreedLabel = true,
    this.onTap,
  });

  final CatImage image;
  final int index; // define a cor pastel do fundo
  final double aspectRatio;
  final bool showBreedLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final raca = image.breed?.name;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CatPhoto(url: image.url, colorIndex: index),
              Positioned(
                top: 10,
                right: 10,
                child: HeartButton(image: image),
              ),
              if (showBreedLabel && raca != null)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        raca,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
