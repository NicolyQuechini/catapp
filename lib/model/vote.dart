import 'package:cat_app/model/cat_image.dart';
import 'package:cat_app/model/json_utils.dart';

// Voto (VoteDto): value = 1 (positivo) ou -1 (negativo).
class Vote {
  final int id;
  final String imageId;
  final int value;
  final String? subId;
  final String? countryCode;
  final DateTime? createdAt;
  final CatImage? image;

  Vote({
    required this.id,
    required this.imageId,
    required this.value,
    this.subId,
    this.countryCode,
    this.createdAt,
    this.image,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    final imageJson = json['image'];
    return Vote(
      id: asInt(json['id']) ?? 0,
      imageId: (json['image_id'] ?? '').toString(),
      value: asInt(json['value']) ?? 1,
      subId: asString(json['sub_id']),
      countryCode: asString(json['country_code']),
      createdAt: asDate(json['created_at']),
      image: imageJson is Map
          ? CatImage.fromJson({
              ...Map<String, dynamic>.from(imageJson),
              'id': imageJson['id'] ?? json['image_id'],
            })
          : null,
    );
  }

  bool get isPositive => value > 0;
}
