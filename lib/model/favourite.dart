
import 'package:cat_app/model/cat_image.dart';
import 'package:cat_app/model/json_utils.dart';

// Favorito (FavouriteDto). O id é necessário para remover o favorito.
class Favourite {
  final int id;
  final String imageId;
  final String? subId;
  final DateTime? createdAt;
  final CatImage? image;

  Favourite({
    required this.id,
    required this.imageId,
    this.subId,
    this.createdAt,
    this.image,
  });

  factory Favourite.fromJson(Map<String, dynamic> json) {
    final imageJson = json['image'];
    return Favourite(
      id: asInt(json['id']) ?? 0,
      imageId: (json['image_id'] ?? '').toString(),
      subId: asString(json['sub_id']),
      createdAt: asDate(json['created_at']),
      image: imageJson is Map
          ? CatImage.fromJson({
              ...Map<String, dynamic>.from(imageJson),
              // dentro do favorito, o id da imagem pode não vir; usa image_id
              'id': imageJson['id'] ?? json['image_id'],
            })
          : null,
    );
  }
}
