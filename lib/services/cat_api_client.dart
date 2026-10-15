import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:cat_app/config.dart';
import 'package:cat_app/model/breed.dart';
import 'package:cat_app/model/cat_category.dart';
import 'package:cat_app/model/cat_fact.dart';
import 'package:cat_app/model/cat_image.dart';
import 'package:cat_app/model/favourite.dart';
import 'package:cat_app/model/vote.dart';
import 'package:cat_app/services/cat_api_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// Única classe que fala com a The Cat API (camada de acesso recomendada na
// documentação). Todas as requisições levam o cabeçalho x-api-key.
class CatApiClient {
  CatApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> get _headers => {'x-api-key': AppConfig.apiKey};

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final params = <String, String>{};
    query?.forEach((k, v) {
      if (v != null) params[k] = v.toString();
    });
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    return params.isEmpty ? uri : uri.replace(queryParameters: params);
  }

  // Executa a requisição e converte falhas de rede em CatApiException.
  Future<http.Response> _run(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(const Duration(seconds: 20));
    } catch (e) {
      throw CatApiException.network(e);
    }
  }

  // Valida o status e decodifica o JSON.
  dynamic _decode(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      // Ajuda a achar o problema: aparece no terminal do "flutter run".
      final k = AppConfig.apiKey;
      debugPrint(
        'ERRO API ${r.request?.method} ${r.request?.url} -> ${r.statusCode} ${r.body}'
        ' | chave em uso: ${k.length > 5 ? k.substring(0, 5) : k}... (${k.length} caracteres)',
      );
      throw CatApiException(r.statusCode, r.body);
    }
    if (r.body.isEmpty) return null;
    return json.decode(utf8.decode(r.bodyBytes));
  }

  Future<dynamic> _get(String path, [Map<String, dynamic>? query]) async {
    final r = await _run(() => _client.get(_uri(path, query), headers: _headers));
    return _decode(r);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final r = await _run(
      () => _client.post(
        _uri(path),
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: json.encode(body),
      ),
    );
    return _decode(r);
  }

  Future<dynamic> _delete(String path) async {
    final r = await _run(() => _client.delete(_uri(path), headers: _headers));
    return _decode(r);
  }

  // Algumas respostas podem vir "embrulhadas" ({data: [...]}); aceita as duas.
  List<Map<String, dynamic>> _list(dynamic data) {
    dynamic lista = data;
    if (data is Map) {
      lista = data['data'] ?? data['results'] ?? data['items'];
    }
    if (lista is! List) return const [];
    return lista
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // ---------------------------------------------------------------- Imagens

  // GET /images/search
  Future<List<CatImage>> searchImages({
    int limit = 10,
    int? page,
    String? order, // ASC, DESC ou RANDOM
    bool? hasBreeds,
    String? breedIds, // separados por vírgula
    String? categoryIds, // separados por vírgula
    String? subId,
  }) async {
    final data = await _get('/images/search', {
      'limit': limit,
      'page': page,
      'order': order,
      'has_breeds': hasBreeds,
      'include_breeds': true,
      'include_categories': true,
      'breed_ids': breedIds,
      'category_ids': categoryIds,
      'sub_id': subId,
    });
    return _list(data).map(CatImage.fromJson).toList();
  }

  // GET /images/{id}
  Future<CatImage> getImage(String id) async {
    final data = await _get('/images/$id');
    return CatImage.fromJson(Map<String, dynamic>.from(data as Map));
  }

  // POST /images/upload (multipart): devolve o id da imagem enviada.
  Future<String> uploadImage({
    required List<int> bytes,
    required String filename,
    required String subId,
  }) async {
    // A API rejeita arquivos sem tipo ("That file type is not supported"),
    // então descobrimos o tipo pela própria imagem e mandamos o content-type.
    final mime = _mimeOf(bytes, filename);
    final ext = mime == 'image/jpeg' ? 'jpg' : mime.split('/').last;
    final request = http.MultipartRequest('POST', _uri('/images/upload'))
      ..headers.addAll(_headers)
      ..fields['sub_id'] = subId
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'foto.$ext',
          contentType: MediaType.parse(mime),
        ),
      );

    final response = await _run(() async {
      final streamed = await _client.send(request);
      return http.Response.fromStream(streamed);
    });
    final data = _decode(response);
    if (data is Map && data['id'] != null) return data['id'].toString();
    throw CatApiException(response.statusCode, response.body);
  }

  // Descobre o tipo da imagem pelos primeiros bytes (ou pela extensão do nome).
  String _mimeOf(List<int> b, String filename) {
    if (b.length > 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (b.length > 4 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) {
      return 'image/png';
    }
    if (b.length > 3 && b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46) {
      return 'image/gif';
    }
    if (b.length > 12 &&
        b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 &&
        b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) {
      return 'image/webp';
    }
    final n = filename.toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.gif')) return 'image/gif';
    if (n.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  // GET /images/{id}/status -> to_be_reviewed, clean, unsafe, flagged, ...
  Future<String?> imageStatus(String id) async {
    final data = await _get('/images/$id/status');
    if (data is String) return data;
    if (data is Map) {
      return (data['status'] ?? data['state'] ?? data['result'])?.toString();
    }
    return null;
  }

  // DELETE /images/{id}: exclui uma foto enviada pelo próprio usuário
  Future<void> deleteImage(String id) async {
    await _delete('/images/$id');
  }

  // ------------------------------------------------------------------ Raças

  // GET /breeds
  Future<List<Breed>> listBreeds({int limit = 1000}) async {
    final data = await _get('/breeds', {'limit': limit});
    return _list(data).map(Breed.fromJson).toList();
  }

  // GET /breeds/search?q=
  Future<List<Breed>> searchBreeds(String q) async {
    final data = await _get('/breeds/search', {'q': q});
    return _list(data).map(Breed.fromJson).toList();
  }

  // GET /breeds/{id}
  Future<Breed> getBreed(String id) async {
    final data = await _get('/breeds/$id');
    return Breed.fromJson(Map<String, dynamic>.from(data as Map));
  }

  // -------------------------------------------------------------- Categorias

  // GET /categories
  Future<List<CatCategory>> listCategories() async {
    final data = await _get('/categories');
    return _list(data).map(CatCategory.fromJson).toList();
  }

  // ------------------------------------------------------------------ Fatos

  // GET /facts/random
  Future<CatFact> randomFact() async {
    final data = await _get('/facts/random');
    Map<String, dynamic>? item;
    if (data is Map && data['fact'] != null) {
      item = Map<String, dynamic>.from(data);
    } else {
      final lista = _list(data);
      if (lista.isNotEmpty) item = lista.first;
    }
    if (item == null) throw CatApiException(404, 'Nenhum fato retornado');
    return CatFact.fromJson(item);
  }

  // ------------------------------------------------------------------ Votos

  // POST /votes
  Future<void> vote({
    required String imageId,
    required int value, // 1 ou -1
    required String subId,
  }) async {
    await _post('/votes', {'image_id': imageId, 'value': value, 'sub_id': subId});
  }

  // GET /votes
  Future<List<Vote>> listVotes({
    required String subId,
    int limit = 100,
    int page = 0,
    String order = 'DESC',
  }) async {
    final data = await _get('/votes', {
      'sub_id': subId,
      'limit': limit,
      'page': page,
      'order': order,
    });
    return _list(data).map(Vote.fromJson).toList();
  }

  // ------------------------------------------------------------- Favoritos

  // POST /favourites -> devolve o id do favorito (necessário para remover)
  Future<int> addFavourite({
    required String imageId,
    required String subId,
  }) async {
    final data = await _post('/favourites', {'image_id': imageId, 'sub_id': subId});
    if (data is Map && data['id'] != null) {
      return int.tryParse(data['id'].toString()) ?? 0;
    }
    return 0;
  }

  // GET /favourites (attach_image=true traz os dados da foto)
  Future<List<Favourite>> listFavourites({
    required String subId,
    int limit = 100,
    int page = 0,
  }) async {
    final data = await _get('/favourites', {
      'sub_id': subId,
      'attach_image': true,
      'limit': limit,
      'page': page,
    });
    return _list(data).map(Favourite.fromJson).toList();
  }

  // DELETE /favourites/{id}
  Future<void> removeFavourite(int id) async {
    await _delete('/favourites/$id');
  }
}