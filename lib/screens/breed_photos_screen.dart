import 'package:flutter/material.dart';
import 'package:cat_app/model/breed.dart';
import 'package:cat_app/model/cat_image.dart';
import 'package:cat_app/services/cat_api_exception.dart';
import 'package:cat_app/state/app_state.dart';
import 'package:cat_app/widgets/app_feedback.dart';
import 'package:cat_app/widgets/cat_image_card.dart';
import 'package:cat_app/widgets/masonry_grid.dart';
import 'package:cat_app/widgets/sub_page_header.dart';

// Fotos de uma raça (botão "Ver fotos desta raça").
class BreedPhotosScreen extends StatefulWidget {
  const BreedPhotosScreen({super.key, required this.breed});

  final Breed breed;

  @override
  State<BreedPhotosScreen> createState() => _BreedPhotosScreenState();
}

class _BreedPhotosScreenState extends State<BreedPhotosScreen> {
  static const int _pageSize = 20;

  final ScrollController _scroll = ScrollController();
  final List<CatImage> _images = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _noMore = false;
  String? _error;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
        _load();
      }
    });
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loadingMore || _noMore) return;
    final primeira = _images.isEmpty;
    setState(() {
      _loadingMore = true;
      if (primeira) _error = null;
    });
    try {
      final novas = await AppState.instance.api.searchImages(
        limit: _pageSize,
        page: _page,
        order: 'ASC',
        breedIds: widget.breed.id,
      );
      if (!mounted) return;
      AppState.instance.rememberImages(novas);
      setState(() {
        final ids = _images.map((e) => e.id).toSet();
        _images.addAll(novas.where((e) => ids.add(e.id)));
        _page++;
        if (novas.length < _pageSize) _noMore = true;
      });
    } catch (e) {
      if (!mounted) return;
      if (_images.isEmpty) {
        setState(() => _error = friendlyError(e));
      } else {
        showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SubPageHeader(title: widget.breed.name),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null && _images.isEmpty) {
      return ErrorView(
        message: _error!,
        onRetry: () {
          setState(() => _loading = true);
          _load();
        },
      );
    }
    if (_images.isEmpty) {
      return const EmptyView(
        icon: Icons.photo_outlined,
        message: 'Ainda não há fotos desta raça.',
      );
    }
    return SingleChildScrollView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        children: [
          MasonryGrid(
            itemCount: _images.length,
            itemBuilder: (context, i, ratio) => CatImageCard(
              image: _images[i],
              index: i,
              aspectRatio: ratio,
              showBreedLabel: false,
            ),
          ),
          if (_loadingMore)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
