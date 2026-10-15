import 'package:cat_app/model/json_utils.dart';

// Dica de saúde (geral ou de uma raça).
class HealthTip {
  final String id;
  final String description;
  final String speciesId;
  final String? title;
  final String? category;
  final List<String> sources;

  HealthTip({
    required this.id,
    required this.description,
    required this.speciesId,
    this.title,
    this.category,
    this.sources = const [],
  });

  factory HealthTip.fromJson(Map<String, dynamic> json) {
    return HealthTip(
      id: json['id'].toString(),
      description: (json['description'] ?? '').toString(),
      speciesId: (json['species_id'] ?? '').toString(),
      title: asString(json['title']),
      category: asString(json['category']),
      sources: asStringList(json['sources']),
    );
  }
}
