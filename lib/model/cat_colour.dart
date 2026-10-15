// Variação de cor e padrão registrada para uma imagem ou raça.
class CatColour {
  final String id;
  final String code;
  final String name;
  final String? baseColour;
  final String? pattern;
  final String? standard;
  final String? breedId;
  final String? description;

  CatColour({
    required this.id,
    required this.code,
    required this.name,
    this.baseColour,
    this.pattern,
    this.standard,
    this.breedId,
    this.description,
  });

  factory CatColour.fromJson(Map<String, dynamic> json) {
    return CatColour(
      id: json['id'].toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      baseColour: json['base_colour']?.toString(),
      pattern: json['pattern']?.toString(),
      standard: json['standard']?.toString(),
      breedId: json['breed_id']?.toString(),
      description: json['description']?.toString(),
    );
  }
}
