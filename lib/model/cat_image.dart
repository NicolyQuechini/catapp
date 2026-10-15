import 'package:cat_app/config.dart';
import 'package:cat_app/model/breed.dart';
import 'package:cat_app/model/cat_category.dart';
import 'package:cat_app/model/cat_colour.dart';
import 'package:cat_app/model/json_utils.dart';

// Foto de gato (ImageDto da documentação).
class CatImage {
  final String id;
  final String url;
  final int width;
  final int height;
  final List<Breed> breeds;
  final List<CatCategory> categories;
  final List<CatColour> colours;
  final List<String> tags;
  final int? ageMonths;
  final DateTime? createdAt;

  CatImage({
    required this.id,
    required this.url,
    this.width = 0,
    this.height = 0,
    this.breeds = const [],
    this.categories = const [],
    this.colours = const [],
    this.tags = const [],
    this.ageMonths,
    this.createdAt,
  });

  factory CatImage.fromJson(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final url = (json['url'] ?? '').toString();
    return CatImage(
      id: id,
      // Se a API não mandar a url, monta pelo endereço público das imagens.
      url: url.isNotEmpty ? url : '${AppConfig.imageCdn}/$id.jpg',
      width: asInt(json['width']) ?? 0,
      height: asInt(json['height']) ?? 0,
      breeds: asMapList(json['breeds']).map(Breed.fromJson).toList(),
      categories:
          asMapList(json['categories']).map(CatCategory.fromJson).toList(),
      colours: asMapList(json['colours']).map(CatColour.fromJson).toList(),
      tags: asStringList(json['tags']),
      ageMonths: asInt(json['age_months']),
      createdAt: asDate(json['created_at']),
    );
  }

  // Cria uma CatImage a partir da imagem de referência de uma raça.
  factory CatImage.fromBreed(Breed breed) {
    return CatImage(
      id: breed.imageId ?? '',
      url: breed.imageUrl ?? '',
      breeds: [breed],
    );
  }

  Breed? get breed => breeds.isEmpty ? null : breeds.first;

  // Texto do selo na tela de votar: "Raça · País de origem".
  String get breedLabel {
    final b = breed;
    if (b == null) return 'Gatinho misterioso';
    final origem = b.origin;
    if (origem == null || origem.isEmpty) return b.name;
    return '${b.name} · $origem';
  }
}
