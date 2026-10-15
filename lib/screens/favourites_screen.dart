import 'package:flutter/material.dart';
import 'package:cat_app/model/cat_image.dart';
import 'package:cat_app/model/favourite.dart';
import 'package:cat_app/screens/breed_detail_screen.dart';
import 'package:cat_app/state/app_state.dart';
import 'package:cat_app/theme/app_theme.dart';
import 'package:cat_app/widgets/app_feedback.dart';
import 'package:cat_app/widgets/cat_image_card.dart';
import 'package:cat_app/widgets/filter_chips.dart';
import 'package:cat_app/widgets/masonry_grid.dart';
import 'package:cat_app/widgets/screen_header.dart';

// Tela 6: Favoritos (GET /favourites do usuário).
//  Todos    -> todos, do mais novo para o mais antigo
//  Por raça -> agrupados pelo nome da raça
//  Recentes -> salvos nos últimos 7 dias
class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  static const List<String> _filters = ['Todos', 'Por raça', 'Recentes'];
  int _filter = 0;

  CatImage _imageOf(Favourite f) =>
      f.image ??
      CatImage(id: f.imageId, url: AppState.instance.imageUrlFor(f.imageId));

  Widget _grid(List<Favourite> lista) {
    return MasonryGrid(
      itemCount: lista.length,
      itemBuilder: (context, i, ratio) {
        final img = _imageOf(lista[i]);
        return CatImageCard(
          image: img,
          index: i,
          aspectRatio: ratio,
          showBreedLabel: false,
          onTap: img.breed == null
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BreedDetailScreen(breed: img.breed!),
                    ),
                  ),
        );
      },
    );
  }

  List<Widget> _content(AppState state) {
    final todos = state.favourites;
    if (state.loadingFavourites && todos.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (state.favouritesError != null && todos.isEmpty) {
      return [
        SizedBox(
          height: 320,
          child: ErrorView(
            message: state.favouritesError!,
            onRetry: state.loadFavourites,
          ),
        ),
      ];
    }
    if (todos.isEmpty) {
      return const [
        SizedBox(
          height: 300,
          child: EmptyView(
            icon: Icons.favorite_border,
            message: 'Você ainda não favoritou nenhum gato.\nToque no coração para salvar!',
          ),
        ),
      ];
    }

    if (_filter == 1) {
      // agrupa por raça
      final grupos = <String, List<Favourite>>{};
      for (final f in todos) {
        grupos.putIfAbsent(state.breedNameOf(f), () => []).add(f);
      }
      final nomes = grupos.keys.toList()..sort();
      return [
        for (final nome in nomes) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
            child: Text(
              '$nome (${grupos[nome]!.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          _grid(grupos[nome]!),
          const SizedBox(height: 8),
        ],
      ];
    }

    if (_filter == 2) {
      final limite = DateTime.now().subtract(const Duration(days: 7));
      final recentes = todos
          .where((f) => f.createdAt != null && f.createdAt!.isAfter(limite))
          .toList();
      if (recentes.isEmpty) {
        return const [
          SizedBox(
            height: 260,
            child: EmptyView(
              icon: Icons.schedule,
              message: 'Nenhum favorito salvo nos últimos 7 dias.',
            ),
          ),
        ];
      }
      return [_grid(recentes)];
    }

    return [_grid(todos)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: AppState.instance,
          builder: (context, _) {
            final state = AppState.instance;
            final n = state.favourites.length;
            return Column(
              children: [
                ScreenHeader(
                  subtitle: n == 1 ? '1 gato salvo' : '$n gatos salvos',
                  title: 'Favoritos',
                  showBack: true,
                ),
                FilterChips(
                  labels: _filters,
                  selected: _filter,
                  onSelected: (i) => setState(() => _filter = i),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: state.loadFavourites,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      children: _content(state),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}