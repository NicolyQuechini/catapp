import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:cat_app/config.dart';
import 'package:cat_app/model/breed.dart';
import 'package:cat_app/model/cat_image.dart';
import 'package:cat_app/model/favourite.dart';
import 'package:cat_app/model/my_photo.dart';
import 'package:cat_app/model/vote.dart';
import 'package:cat_app/services/cat_api_client.dart';
import 'package:cat_app/services/cat_api_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Estado global do app (usuário, favoritos, votos e fotos enviadas).
// A The Cat API não tem login: o "usuário" é identificado por um sub_id
// único gerado no primeiro uso, que separa votos e favoritos de cada pessoa.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  final CatApiClient api = CatApiClient();
  SharedPreferences? _prefs;

  // ---- usuário
  String subId = '';
  String name = '';
  String email = '';

  bool get isLoggedIn => subId.isNotEmpty;

  // Letra do avatar (G de "gateiro" quando não há nome).
  String get initial =>
      name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'G';

  // Nome usado na saudação "Olá, ...".
  String get greetingName =>
      name.trim().isNotEmpty ? name.trim().split(' ').first : 'gateiro(a)';

  // ---- dados
  List<Favourite> favourites = [];
  bool loadingFavourites = false;
  String? favouritesError;

  List<Vote> votes = []; // mais recentes primeiro
  bool loadingVotes = false;

  List<String> uploads = []; // ids das fotos enviadas, mais recentes primeiro

  List<Breed>? _breeds;

  final Map<String, Favourite> _favByImage = {};
  final Set<String> _favouriteBusy = {};
  final Map<String, String> _imageUrls = {}; // só em memória
  Map<String, String> _breedNames = {}; // imageId -> nome da raça (salvo)

  // ------------------------------------------------------------ inicialização

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    subId = prefs.getString('sub_id') ?? '';
    name = prefs.getString('name') ?? '';
    email = prefs.getString('email') ?? '';
    uploads = prefs.getStringList('uploads') ?? [];
    final raw = prefs.getString('breed_names');
    if (raw != null) {
      try {
        _breedNames = Map<String, String>.from(json.decode(raw) as Map);
      } catch (_) {
        _breedNames = {};
      }
    }
  }

  // Carrega favoritos e votos do usuário (chamado quando o app abre).
  Future<void> bootstrap() async {
    await Future.wait([loadFavourites(), refreshVotes()]);
  }

  // ------------------------------------------------------------------ conta

  String _newSubId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random.secure();
    final sufixo = List.generate(10, (_) => chars[rnd.nextInt(chars.length)]);
    return 'gato-${sufixo.join()}';
  }

  // "Começar": cria um novo usuário com um sub_id único.
  Future<void> createAccount({String name = '', String email = ''}) async {
    await _saveUser(_newSubId(), name.trim(), email.trim());
  }

  // "Já tenho uma conta": volta a usar um sub_id que já existe.
  Future<void> signInWithCode(String code) async {
    await _saveUser(code.trim(), '', '');
  }

  Future<void> _saveUser(String sub, String nome, String mail) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    subId = sub;
    name = nome;
    email = mail;
    uploads = [];
    _breedNames = {};
    await prefs.setString('sub_id', sub);
    await prefs.setString('name', nome);
    await prefs.setString('email', mail);
    await prefs.setStringList('uploads', uploads);
    await prefs.remove('breed_names');
    notifyListeners();
  }

  // "Sair da conta": apaga os dados locais. Os votos e favoritos continuam
  // na API e podem ser recuperados com o mesmo código (sub_id).
  Future<void> signOut() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove('sub_id');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('uploads');
    await prefs.remove('breed_names');
    subId = '';
    name = '';
    email = '';
    favourites = [];
    votes = [];
    uploads = [];
    _breedNames = {};
    _favByImage.clear();
    notifyListeners();
  }

  // ------------------------------------------------------------------ raças

  // Lista de raças em cache (economiza cota da API).
  Future<List<Breed>> loadBreeds({bool force = false}) async {
    if (_breeds != null && !force) return _breeds!;
    final todas = await api.listBreeds();
    final gatos = todas.where((b) => b.isCat).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    _breeds = gatos;
    return gatos;
  }

  // ---------------------------------------------------------- imagens em cache

  // Guarda a url das fotos já vistas (usado nas miniaturas de votos).
  void rememberImages(Iterable<CatImage> images) {
    for (final img in images) {
      if (img.id.isNotEmpty && img.url.isNotEmpty) _imageUrls[img.id] = img.url;
    }
  }

  String imageUrlFor(String imageId) =>
      _imageUrls[imageId] ?? '${AppConfig.imageCdn}/$imageId.jpg';

  // ---------------------------------------------------------------- favoritos

  bool isFavourite(String imageId) => _favByImage.containsKey(imageId);

  String breedNameOf(Favourite fav) =>
      fav.image?.breed?.name ?? _breedNames[fav.imageId] ?? 'Sem raça';

  void _reindexFavourites() {
    _favByImage
      ..clear()
      ..addEntries(favourites.map((f) => MapEntry(f.imageId, f)));
  }

  Future<void> loadFavourites() async {
    if (!isLoggedIn) return;
    loadingFavourites = true;
    favouritesError = null;
    notifyListeners();
    try {
      final todos = <Favourite>[];
      for (var page = 0; page < 5; page++) {
        final lote = await api.listFavourites(subId: subId, page: page);
        todos.addAll(lote);
        if (lote.length < 100) break;
      }
      todos.sort((a, b) => (b.createdAt ?? DateTime(1970))
          .compareTo(a.createdAt ?? DateTime(1970)));
      favourites = todos;
      for (final f in todos) {
        if (f.image != null) rememberImages([f.image!]);
      }
      _reindexFavourites();
    } catch (e) {
      favouritesError = friendlyError(e);
    }
    loadingFavourites = false;
    notifyListeners();
  }

  // Favorita ou desfavorita. Lança CatApiException se a API falhar.
  Future<void> toggleFavourite(CatImage image) async {
    if (image.id.isEmpty) {
      throw CatApiException(404, 'Esta raça não tem foto de referência.');
    }
    if (_favouriteBusy.contains(image.id)) return;
    _favouriteBusy.add(image.id);
    try {
      final existente = _favByImage[image.id];
      if (existente != null) {
        await api.removeFavourite(existente.id);
        favourites = favourites.where((f) => f.imageId != image.id).toList();
      } else {
        final id = await api.addFavourite(imageId: image.id, subId: subId);
        final fav = Favourite(
          id: id,
          imageId: image.id,
          subId: subId,
          createdAt: DateTime.now(),
          image: image,
        );
        favourites = [fav, ...favourites];
        rememberImages([image]);
        if (image.breed != null) {
          _breedNames[image.id] = image.breed!.name;
          await _prefs?.setString('breed_names', json.encode(_breedNames));
        }
        _reindexFavourites();
        notifyListeners();
        // Se a API não devolveu o id do favorito, recarrega para poder remover depois.
        if (id == 0) await loadFavourites();
      }
      _reindexFavourites();
      notifyListeners();
    } finally {
      _favouriteBusy.remove(image.id);
    }
  }

  // -------------------------------------------------------------------- votos

  Future<void> refreshVotes() async {
    if (!isLoggedIn) return;
    loadingVotes = true;
    notifyListeners();
    try {
      final todos = <Vote>[];
      for (var page = 0; page < 5; page++) {
        final lote = await api.listVotes(subId: subId, page: page);
        todos.addAll(lote);
        if (lote.length < 100) break;
      }
      votes = todos;
      for (final v in todos) {
        if (v.image != null) rememberImages([v.image!]);
      }
    } catch (_) {
      // Mantém os votos que já estavam na tela.
    }
    loadingVotes = false;
    notifyListeners();
  }

  // Registra um voto (+1 ou -1). Lança CatApiException se a API falhar.
  Future<void> vote(CatImage image, int value) async {
    await api.vote(imageId: image.id, value: value, subId: subId);
    rememberImages([image]);
    votes = [
      Vote(
        id: 0,
        imageId: image.id,
        value: value,
        subId: subId,
        createdAt: DateTime.now(),
        image: image,
      ),
      ...votes,
    ];
    notifyListeners();
  }

  String voteThumbUrl(Vote v) =>
      (v.image != null && v.image!.url.isNotEmpty)
          ? v.image!.url
          : imageUrlFor(v.imageId);

  // ------------------------------------------------------------------- fotos

  // Envia uma foto do usuário e guarda o id para acompanhar a análise.
  Future<String> uploadPhoto(List<int> bytes, String filename) async {
    final id =
        await api.uploadImage(bytes: bytes, filename: filename, subId: subId);
    uploads = [id, ...uploads];
    await _prefs?.setStringList('uploads', uploads);
    notifyListeners();
    return id;
  }

  // Apaga uma foto enviada (na API e na lista local).
  Future<void> deletePhoto(String id) async {
    try {
      await api.deleteImage(id);
    } on CatApiException catch (e) {
      // 404 = a foto já não existe na API; segue e tira só da lista local
      if (e.statusCode != 404) rethrow;
    }
    uploads = uploads.where((u) => u != id).toList();
    await _prefs?.setStringList('uploads', uploads);
    notifyListeners();
  }

  // Busca a foto e a situação (aprovada / em análise / recusada) de cada envio.
  Future<List<MyPhoto>> loadMyPhotos({int max = 30}) async {
    final ids = uploads.take(max).toList();
    return Future.wait(ids.map(_loadPhoto));
  }

  Future<MyPhoto> _loadPhoto(String id) async {
    String? url;
    String? status;
    try {
      url = (await api.getImage(id)).url;
    } catch (_) {}
    try {
      status = await api.imageStatus(id);
    } catch (_) {}
    return MyPhoto(id: id, url: url, status: photoStatusFromApi(status));
  }
}