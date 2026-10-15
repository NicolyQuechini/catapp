import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cat_app/model/cat_category.dart';
import 'package:cat_app/model/cat_fact.dart';
import 'package:cat_app/model/cat_image.dart';
import 'package:cat_app/screens/breed_detail_screen.dart';
import 'package:cat_app/services/cat_api_exception.dart';
import 'package:cat_app/state/app_state.dart';
import 'package:cat_app/theme/app_theme.dart';
import 'package:cat_app/widgets/app_feedback.dart';
import 'package:cat_app/widgets/cat_image_card.dart';
import 'package:cat_app/widgets/filter_chips.dart';
import 'package:cat_app/widgets/masonry_grid.dart';
import 'package:cat_app/widgets/screen_header.dart';
import 'package:cat_app/widgets/search_field.dart';
import 'package:cat_app/data/cat_facts_pt.dart';

// Tela 2: Descobrir (busca, categorias, fato do dia e grade de fotos).
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  static const int _pageSize = 12;

  final _api = AppState.instance.api;
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  Timer? _debounce;

  final List<CatImage> _images = [];
  List<CatCategory> _categories = [];
  int _selectedCat = 0; // 0 = Todos
  String _query = '';
  List<String> _searchBreedIds = [];

  CatFact? _fact;
  bool _factError = false;

  bool _loading = true;
  bool _loadingMore = false;
  bool _noMore = false;
  String? _error;
  int _page = 0;
  int _requestId = 0; // evita que uma resposta antiga sobrescreva a nova

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
        _load();
      }
    });
    _loadCategories();
    _loadFact();
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _api.listCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {
      // sem categorias, só aparece o chip "Todos"
    }
  }

   // Escolhe a curiosidade do dia (muda a cada dia do ano).
    // Escolhe a curiosidade do dia (muda a cada dia do ano).
  Future<void> _loadFact() async {
    final hoje = DateTime.now();
    final dia = hoje.difference(DateTime(hoje.year, 1, 1)).inDays;
    setState(() {
      _factError = false;
      _fact = CatFact(
        id: 'local-$dia',
        fact: catFactsPt[dia % catFactsPt.length],
        speciesId: 'cat',
      );
    });
  }

  // Busca as fotos conforme o filtro atual (busca por raça, categoria ou aleatório).
  Future<List<CatImage>> _fetch() async {
    if (_query.isNotEmpty) {
      if (_page == 0) {
        final racas = await _api.searchBreeds(_query);
        _searchBreedIds = racas.map((b) => b.id).toList();
      }
      if (_searchBreedIds.isEmpty) return [];
      return _api.searchImages(
        limit: _pageSize,
        page: _page,
        order: 'ASC',
        breedIds: _searchBreedIds.join(','),
      );
    }
    if (_selectedCat > 0 && _selectedCat <= _categories.length) {
      return _api.searchImages(
        limit: _pageSize,
        page: _page,
        order: 'ASC',
        categoryIds: _categories[_selectedCat - 1].id,
      );
    }
    return _api.searchImages(limit: _pageSize, order: 'RANDOM', hasBreeds: true);
  }

  bool get _isFiltering => _query.isNotEmpty || _selectedCat > 0;

  Future<void> _load({bool reset = false}) async {
    if (!reset && (_loading || _loadingMore || _noMore)) return;
    final request = ++_requestId;
    setState(() {
      if (reset) {
        _loading = true;
        _error = null;
        _images.clear();
        _page = 0;
        _noMore = false;
      } else {
        _loadingMore = true;
      }
    });
    try {
      final novas = await _fetch();
      if (!mounted || request != _requestId) return;
      AppState.instance.rememberImages(novas);
      setState(() {
        final ids = _images.map((e) => e.id).toSet();
        final unicas = novas.where((e) => ids.add(e.id)).toList();
        _images.addAll(unicas);
        _page++;
        if (_isFiltering ? novas.length < _pageSize : unicas.isEmpty) {
          _noMore = true;
        }
      });
    } catch (e) {
      if (!mounted || request != _requestId) return;
      if (_images.isEmpty) {
        setState(() => _error = friendlyError(e));
      } else {
        showError(context, e);
      }
    } finally {
      if (mounted && request == _requestId) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _applySearch(text));
  }

  void _applySearch(String text) {
    final q = text.trim();
    if (q == _query) return;
    _query = q;
    if (q.isNotEmpty) _selectedCat = 0;
    _load(reset: true);
  }

  void _onCategory(int i) {
    if (i == _selectedCat && _query.isEmpty) return;
    _debounce?.cancel();
    _searchCtrl.clear();
    _query = '';
    setState(() => _selectedCat = i);
    _load(reset: true);
  }

  Future<void> _refresh() async {
    _loadFact();
    await _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['Todos', ..._categories.map((c) => c.label)];
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ScreenHeader(
                  subtitle: 'Olá, ${AppState.instance.greetingName}',
                  title: 'Descobrir',
                ),
              ),
              SliverToBoxAdapter(
                child: SearchField(
                  controller: _searchCtrl,
                  hint: 'Buscar gatos...',
                  onChanged: _onSearchChanged,
                  onSubmitted: (t) {
                    _debounce?.cancel();
                    _applySearch(t);
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: FilterChips(
                  labels: labels,
                  selected: _query.isNotEmpty ? -1 : _selectedCat,
                  onSelected: _onCategory,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(child: _buildFactCard()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ..._buildContent(),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    if (_loading) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ];
    }
    if (_error != null && _images.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 320,
            child: ErrorView(
              message: _error!,
              onRetry: () => _load(reset: true),
            ),
          ),
        ),
      ];
    }
    if (_images.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 260,
            child: EmptyView(
              icon: Icons.search_off,
              message: 'Nenhum gato encontrado por aqui.',
            ),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: MasonryGrid(
            itemCount: _images.length,
            itemBuilder: (context, i, ratio) {
              final img = _images[i];
              return CatImageCard(
                image: img,
                index: i,
                aspectRatio: ratio,
                onTap: img.breed == null
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BreedDetailScreen(breed: img.breed!),
                          ),
                        ),
              );
            },
          ),
        ),
      ),
      if (_loadingMore)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
    ];
  }

  // Card roxo "Fato do dia" (GET /facts/random).
  Widget _buildFactCard() {
    final texto = _fact?.fact ??
        (_factError
            ? 'Não foi possível carregar o fato do dia. Toque para tentar de novo.'
            : 'Buscando uma curiosidade...');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _factError ? _loadFact : null,
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: softShadow(0.30),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Fato do dia',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      texto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
