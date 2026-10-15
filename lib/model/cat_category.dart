// Categoria temática de uma imagem (chapéus, espaço, etc.).
class CatCategory {
  final String id;
  final String name;
  final String? speciesId;

  CatCategory({required this.id, required this.name, this.speciesId});

  factory CatCategory.fromJson(Map<String, dynamic> json) {
    return CatCategory(
      id: json['id'].toString(),
      name: (json['name'] ?? '').toString(),
      speciesId: json['species_id']?.toString(),
    );
  }

  // Tradução dos nomes mais comuns para exibir nos chips.
  String get label {
    const traducao = {
      'hats': 'Chapéus',
      'space': 'Espaço',
      'sunglasses': 'Óculos',
      'boxes': 'Caixas',
      'ties': 'Gravatas',
      'sinks': 'Pias',
      'clothes': 'Roupas',
    };
    final key = name.toLowerCase();
    if (traducao.containsKey(key)) return traducao[key]!;
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }
}
