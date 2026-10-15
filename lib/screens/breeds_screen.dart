import 'package:flutter/material.dart';
import 'package:cat_app/model/breed.dart';
import 'package:cat_app/screens/breed_detail_screen.dart';
import 'package:cat_app/services/cat_api_exception.dart';
import 'package:cat_app/state/app_state.dart';
import 'package:cat_app/theme/app_theme.dart';
import 'package:cat_app/widgets/app_feedback.dart';
import 'package:cat_app/widgets/cat_photo.dart';
import 'package:cat_app/widgets/filter_chips.dart';
import 'package:cat_app/widgets/screen_header.dart';
import 'package:cat_app/widgets/search_field.dart';

// Tela 3: lista de raças (GET /breeds, guardada em cache na memória).
class BreedsScreen extends StatefulWidget {
  const BreedsScreen({super.key});

  @override
  State<BreedsScreen> createState() => _BreedsScreenState();
}

class _BreedsScreenState extends State<BreedsScreen> {
  static const List<String> _filters = ['Todas', 'Calmas', 'Ativas', 'Sociáveis'];

  final TextEditingController _searchCtrl = TextEditingController();
  List<Breed> _all = [];
  bool _loading = true;
  String? _error;
  String _query = '';
  int _filter = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({bool force = false}) async {
    if (!force) setState(() => _loading = true);
    try {
      final racas = await AppState.instance.loadBreeds(force: force);
      if (!mounted) return;
      setState(() {
        _all = racas;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(e);
        _loading = false;
      });
    }
  }

  static bool _tem(Breed b, List<String> palavras) {
    final t = (b.temperament ?? '').toLowerCase();
    return palavras.any((p) => t.contains(p));
  }

  // Usa os números (1 a 5) quando a API manda; senão, usa o temperamento.
  bool _passaNoFiltro(Breed b) {
    switch (_filter) {
      case 1: // Calmas
        if (b.energyLevel != null) return b.energyLevel! <= 2;
        return _tem(b, ['calm', 'gentle', 'docile', 'quiet', 'relaxed', 'patient', 'placid']);
      case 2: // Ativas
        if (b.energyLevel != null) return b.energyLevel! >= 4;
        return _tem(b, ['active', 'energetic', 'playful', 'lively', 'agile', 'athletic']);
      case 3: // Sociáveis
        if (b.socialNeeds != null || b.strangerFriendly != null) {
          return (b.socialNeeds ?? 0) >= 4 || (b.strangerFriendly ?? 0) >= 4;
        }
        return _tem(b, ['social', 'sociable', 'friendly', 'affectionate', 'outgoing', 'loving']);
      default:
        return true;
    }
  }

  // Aplica a busca por nome e o filtro (Calmas / Ativas / Sociáveis).
  List<Breed> get _visible {
    final q = _query.toLowerCase();
    return _all.where((b) {
      if (q.isNotEmpty &&
          !b.name.toLowerCase().contains(q) &&
          !(b.altNames ?? '').toLowerCase().contains(q)) {
        return false;
      }
      return _passaNoFiltro(b);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ScreenHeader(
              subtitle: 'Conheça cada uma',
              title: 'Raças',
              showBack: true,
            ),
            SearchField(
              controller: _searchCtrl,
              hint: 'Buscar raça...',
              onChanged: (t) => setState(() => _query = t.trim()),
            ),
            const SizedBox(height: 12),
            FilterChips(
              labels: _filters,
              selected: _filter,
              onSelected: (i) => setState(() => _filter = i),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null && _all.isEmpty) {
      return ErrorView(message: _error!, onRetry: _load);
    }
    final lista = _visible;
    return RefreshIndicator(
      onRefresh: () => _load(force: true),
      child: lista.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(
                  height: 280,
                  child: EmptyView(
                    icon: Icons.search_off,
                    message: 'Nenhuma raça encontrada.',
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: lista.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) => _BreedTile(breed: lista[i], index: i),
            ),
    );
  }
}

class _BreedTile extends StatelessWidget {
  const _BreedTile({required this.breed, required this.index});

  final Breed breed;
  final int index;

  // (fundo, texto) da primeira etiqueta, que muda de cor de linha em linha
  static const List<List<Color>> _tagColors = [
    [Color(0xFFFFD9E0), Color(0xFFD6336C)],
    [Color(0xFFD7F5E7), Color(0xFF0E9F6E)],
    [Color(0xFFE0DBFF), AppColors.primary],
    [Color(0xFFFFE8C7), Color(0xFFD97706)],
  ];

  @override
  Widget build(BuildContext context) {
    final tags = breed.temperamentTags.take(2).toList();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => BreedDetailScreen(breed: breed)),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: softShadow(0.06),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 74,
                  height: 74,
                  child: CatPhoto(
                    url: breed.imageUrl,
                    colorIndex: index,
                    iconSize: 30,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      breed.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (var t = 0; t < tags.length; t++)
                          _Tag(
                            text: tags[t],
                            background: t == 0
                                ? _tagColors[index % _tagColors.length][0]
                                : const Color(0xFFECE9F7),
                            color: t == 0
                                ? _tagColors[index % _tagColors.length][1]
                                : AppColors.muted,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1EEFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.background, required this.color});

  final String text;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}