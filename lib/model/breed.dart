import 'package:cat_app/config.dart';
import 'package:cat_app/data/breed_traits.dart';
import 'package:cat_app/data/textos_pt.dart';
import 'package:cat_app/model/json_utils.dart';

// Imagem de referência que vem dentro do objeto da raça (BasicImage).
class BreedImage {
  final String id;
  final String url;
  final int? width;
  final int? height;

  BreedImage({required this.id, required this.url, this.width, this.height});

  factory BreedImage.fromJson(Map<String, dynamic> json) {
    return BreedImage(
      id: json['id'].toString(),
      url: (json['url'] ?? '').toString(),
      width: asInt(json['width']),
      height: asInt(json['height']),
    );
  }
}

// Raça de gato. Só id e name são obrigatórios; o resto pode não vir
// (a documentação recomenda tratar a maioria dos campos como opcionais).
class Breed {
  final String id;
  final String name;
  final String? speciesId;
  final String? description;
  final String? history;
  final String? temperament;
  final String? origin;
  final String? countryCode;
  final String? lifeSpan;
  final String? altNames;
  final String? breedGroup;
  final String? referenceImageId;
  final BreedImage? image;
  final String? wikipediaUrl;
  final String? cfaUrl;
  final String? vetstreetUrl;
  final String? vcahospitalsUrl;

  // Características de 1 a 5
  final int? adaptability;
  final int? affectionLevel;
  final int? childFriendly;
  final int? catFriendly;
  final int? dogFriendly;
  final int? energyLevel;
  final int? grooming;
  final int? healthIssues;
  final int? intelligence;
  final int? sheddingLevel;
  final int? socialNeeds;
  final int? strangerFriendly;
  final int? vocalisation;

  // Características verdadeiro/falso
  final bool indoor;
  final bool lap;
  final bool hypoallergenic;
  final bool hairless;
  final bool natural;
  final bool rare;
  final bool experimental;
  final bool rex;
  final bool suppressedTail;
  final bool shortLegs;

  Breed({
    required this.id,
    required this.name,
    this.speciesId,
    this.description,
    this.history,
    this.temperament,
    this.origin,
    this.countryCode,
    this.lifeSpan,
    this.altNames,
    this.breedGroup,
    this.referenceImageId,
    this.image,
    this.wikipediaUrl,
    this.cfaUrl,
    this.vetstreetUrl,
    this.vcahospitalsUrl,
    this.adaptability,
    this.affectionLevel,
    this.childFriendly,
    this.catFriendly,
    this.dogFriendly,
    this.energyLevel,
    this.grooming,
    this.healthIssues,
    this.intelligence,
    this.sheddingLevel,
    this.socialNeeds,
    this.strangerFriendly,
    this.vocalisation,
    this.indoor = false,
    this.lap = false,
    this.hypoallergenic = false,
    this.hairless = false,
    this.natural = false,
    this.rare = false,
    this.experimental = false,
    this.rex = false,
    this.suppressedTail = false,
    this.shortLegs = false,
  });

  factory Breed.fromJson(Map<String, dynamic> json) {
    // A conta Free não manda as características de 1 a 5; quando faltam,
    // completa com a tabela local (ou estimativa pelo temperamento).
    final tr = traitsFor(
      json['id'].toString(),
      asString(json['temperament']),
    );

    return Breed(
      id: json['id'].toString(),
      name: json['name'] as String,
      speciesId: asString(json['species_id']),
      // Usa a descrição em português quando a raça está na tabela local.
      description:
          descricaoPt(json['name'].toString()) ?? asString(json['description']),
      history: asString(json['history']),
      temperament: asString(json['temperament']),
      origin: asString(json['origin']),
      countryCode: asString(json['country_code'] ?? json['country_codes']),
      lifeSpan: asString(json['life_span']),
      altNames: asString(json['alt_names']),
      breedGroup: asString(json['breed_group']),
      referenceImageId: asString(json['reference_image_id']),
      image: json['image'] is Map
          ? BreedImage.fromJson(Map<String, dynamic>.from(json['image']))
          : null,
      wikipediaUrl: asString(json['wikipedia_url']),
      cfaUrl: asString(json['cfa_url']),
      vetstreetUrl: asString(json['vetstreet_url']),
      vcahospitalsUrl: asString(json['vcahospitals_url']),
      adaptability: asInt(json['adaptability']),
      affectionLevel: asInt(json['affection_level']) ?? tr?.affection,
      childFriendly: asInt(json['child_friendly']),
      catFriendly: asInt(json['cat_friendly']),
      dogFriendly: asInt(json['dog_friendly']),
      energyLevel: asInt(json['energy_level']) ?? tr?.energy,
      grooming: asInt(json['grooming']),
      healthIssues: asInt(json['health_issues']),
      intelligence: asInt(json['intelligence']) ?? tr?.intelligence,
      sheddingLevel: asInt(json['shedding_level']),
      socialNeeds: asInt(json['social_needs']) ?? tr?.social,
      strangerFriendly: asInt(json['stranger_friendly']) ?? tr?.social,
      vocalisation: asInt(json['vocalisation']),
      indoor: asBool(json['indoor']),
      lap: asBool(json['lap']),
      hypoallergenic: asBool(json['hypoallergenic']),
      hairless: asBool(json['hairless']),
      natural: asBool(json['natural']),
      rare: asBool(json['rare']),
      experimental: asBool(json['experimental']),
      rex: asBool(json['rex']),
      suppressedTail: asBool(json['suppressed_tail']),
      shortLegs: asBool(json['short_legs']),
    );
  }

  // O esquema da API também traz raças de cães e cavalos; o app só usa gatos.
  bool get isCat {
    final s = speciesId?.toLowerCase();
    return s != 'dog' && s != 'horse';
  }

  // Foto para mostrar na lista: a imagem de referência, ou o CDN pelo id.
  String? get imageUrl {
    if (image != null && image!.url.isNotEmpty) return image!.url;
    if (referenceImageId != null && referenceImageId!.isNotEmpty) {
      return '${AppConfig.imageCdn}/$referenceImageId.jpg';
    }
    return null;
  }

  // Id da imagem de referência (usado para favoritar a raça).
  String? get imageId => image?.id ?? referenceImageId;

  // "Calmo, Gentil, Sociável" -> ["Calmo", "Gentil", "Sociável"]
  List<String> get temperamentTags {
    if (temperament == null || temperament!.trim().isEmpty) return const [];
    return temperament!
        .split(',')
        .map((e) => traduzirTemperamento(e.trim()))
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // Texto de "País de origem" para o chip.
  String get originLabel {
    if (origin != null && origin!.isNotEmpty) return traduzirOrigem(origin!);
    if (countryCode != null && countryCode!.isNotEmpty) return countryCode!;
    return 'Origem desconhecida';
  }

  // Texto de "Expectativa de vida" para o chip.
  String get lifeSpanLabel {
    if (lifeSpan == null || lifeSpan!.isEmpty) return 'Vida: sem dados';
    return '$lifeSpan anos';
  }
}