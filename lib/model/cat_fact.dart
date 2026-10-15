import 'package:cat_app/model/json_utils.dart';

// Curiosidade sobre gatos (usada no "Fato do dia").
class CatFact {
  final String id;
  final String fact;
  final String speciesId;
  final String? title;
  final String? slug;
  final String? category;
  final List<String> sourceUrls;

  CatFact({
    required this.id,
    required this.fact,
    required this.speciesId,
    this.title,
    this.slug,
    this.category,
    this.sourceUrls = const [],
  });

  factory CatFact.fromJson(Map<String, dynamic> json) {
    return CatFact(
      id: json['id'].toString(),
      fact: (json['fact'] ?? '').toString(),
      speciesId: (json['species_id'] ?? '').toString(),
      title: asString(json['title']),
      slug: asString(json['slug']),
      category: asString(json['category']),
      sourceUrls: asStringList(json['source_urls']),
    );
  }
}
