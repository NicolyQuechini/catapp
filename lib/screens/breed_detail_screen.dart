import 'package:flutter/material.dart';
import 'package:cat_app/model/breed.dart';
import 'package:cat_app/model/cat_image.dart';
import 'package:cat_app/screens/breed_photos_screen.dart';
import 'package:cat_app/theme/app_theme.dart';
import 'package:cat_app/widgets/cat_photo.dart';
import 'package:cat_app/widgets/heart_button.dart';
import 'package:cat_app/widgets/primary_button.dart';
import 'package:cat_app/widgets/sub_page_header.dart';
import 'package:cat_app/widgets/trait_bar.dart';

// Tela 4: detalhe da raça.
class BreedDetailScreen extends StatelessWidget {
  const BreedDetailScreen({super.key, required this.breed});

  final Breed breed;

  @override
  Widget build(BuildContext context) {
    final topo = MediaQuery.of(context).padding.top;
    final temFoto = breed.imageId != null && breed.imageId!.isNotEmpty;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // foto de referência no topo, com voltar e favoritar
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0DBFF),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(44),
                    ),
                  ),
                  child: CatPhoto(
                    url: breed.imageUrl,
                    colorIndex: 1,
                    iconSize: 64,
                  ),
                ),
                Positioned(
                  top: topo + 12,
                  left: 20,
                  child: const BackCircleButton(),
                ),
                if (temFoto)
                  Positioned(
                    top: topo + 12,
                    right: 20,
                    child: HeartButton(
                      image: CatImage.fromBreed(breed),
                      size: 44,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    breed.name,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _InfoPill(
                        text: breed.originLabel,
                        background: const Color(0xFFE0DBFF),
                        color: AppColors.primary,
                      ),
                      _InfoPill(
                        text: breed.lifeSpanLabel,
                        background: const Color(0xFFD7F5E7),
                        color: const Color(0xFF0E9F6E),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    breed.description ?? 'Sem descrição disponível.',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TraitBar(
                    label: 'Afeto',
                    value: breed.affectionLevel,
                    color: AppColors.pink,
                  ),
                  TraitBar(
                    label: 'Energia',
                    value: breed.energyLevel,
                    color: AppColors.green,
                  ),
                  TraitBar(
                    label: 'Inteligência',
                    value: breed.intelligence,
                    color: AppColors.primary,
                  ),
                  TraitBar(
                    label: 'Sociabilidade',
                    value: breed.socialNeeds,
                    color: AppColors.orange,
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: 'Ver fotos desta raça',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BreedPhotosScreen(breed: breed),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.text,
    required this.background,
    required this.color,
  });

  final String text;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w800),
      ),
    );
  }
}
