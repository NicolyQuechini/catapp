import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cat_app/model/cat_image.dart';
import 'package:cat_app/services/cat_api_exception.dart';
import 'package:cat_app/state/app_state.dart';
import 'package:cat_app/theme/app_theme.dart';
import 'package:cat_app/widgets/app_feedback.dart';
import 'package:cat_app/widgets/cat_photo.dart';
import 'package:cat_app/widgets/screen_header.dart';

// Tela 5: Votar.
//  - X (ou deslizar para a esquerda)  -> voto negativo (-1)
//  - estrela (ou deslizar para a direita) -> voto positivo (+1)
//  - coração -> favorita a foto e também vota +1
class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final List<CatImage> _queue = []; // fotos esperando voto; a primeira é a do topo
  bool _loading = true;
  bool _fetching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fill();
  }

  CatImage? get _current => _queue.isEmpty ? null : _queue.first;

  // Busca mais 10 fotos aleatórias (que tenham raça associada).
  Future<void> _fill() async {
    if (_fetching) return;
    _fetching = true;
    try {
      final fotos = await AppState.instance.api.searchImages(
        limit: 10,
        order: 'RANDOM',
        hasBreeds: true,
      );
      if (!mounted) return;
      AppState.instance.rememberImages(fotos);
      setState(() {
        final ids = _queue.map((e) => e.id).toSet();
        _queue.addAll(fotos.where((e) => e.url.isNotEmpty && ids.add(e.id)));
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      _fetching = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  void _advance() {
    setState(() {
      _queue.removeAt(0);
      if (_queue.isEmpty) _loading = true;
    });
    if (_queue.length < 4) _fill();
    // já deixa a próxima foto carregando
    if (_queue.length > 1 && mounted) {
      precacheImage(
        CachedNetworkImageProvider(_queue[1].url),
        context,
        onError: (_, __) {},
      );
    }
  }

  Future<void> _vote(int value, {bool favourite = false}) async {
    final foto = _current;
    if (foto == null) return;
    _advance();
    try {
      await AppState.instance.vote(foto, value);
      if (favourite && !AppState.instance.isFavourite(foto.id)) {
        await AppState.instance.toggleFavourite(foto);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ScreenHeader(
              subtitle: 'Quem leva o seu voto?',
              title: 'Votar',
              showBack: true,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: _buildCardArea(),
              ),
            ),
            const SizedBox(height: 16),
            _buildActions(),
            const SizedBox(height: 16),
            _buildRecentVotes(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCardArea() {
    final foto = _current;
    if (foto == null) {
      if (_loading) return const Center(child: CircularProgressIndicator());
      if (_error != null) {
        return ErrorView(
          message: _error!,
          onRetry: () {
            setState(() => _loading = true);
            _fill();
          },
        );
      }
      return const EmptyView(
        icon: Icons.pets,
        message: 'Acabaram as fotos por agora.',
      );
    }
    return Stack(
      children: [
        // card lilás atrás, para dar a ideia de pilha
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD9D3FA),
                borderRadius: BorderRadius.circular(36),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Dismissible(
              key: ValueKey(foto.id),
              direction: DismissDirection.horizontal,
              background: const _SwipeHint(
                icon: Icons.star,
                color: AppColors.green,
                alignment: Alignment.centerLeft,
              ),
              secondaryBackground: const _SwipeHint(
                icon: Icons.close,
                color: AppColors.pink,
                alignment: Alignment.centerRight,
              ),
              onDismissed: (dir) =>
                  _vote(dir == DismissDirection.startToEnd ? 1 : -1),
              child: _PhotoCard(image: foto),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    final ativo = _current != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.close,
          color: AppColors.pink,
          size: 62,
          onTap: ativo ? () => _vote(-1) : null,
        ),
        const SizedBox(width: 22),
        _ActionButton(
          icon: Icons.favorite,
          color: Colors.white,
          background: AppColors.pink,
          size: 76,
          onTap: ativo ? () => _vote(1, favourite: true) : null,
        ),
        const SizedBox(width: 22),
        _ActionButton(
          icon: Icons.star_border,
          color: AppColors.primary,
          size: 62,
          onTap: ativo ? () => _vote(1) : null,
        ),
      ],
    );
  }

  // "Últimos votos": miniaturas com selo de estrela (+1) ou X (-1).
  Widget _buildRecentVotes() {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final recentes = AppState.instance.votes.take(4).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                'Últimos votos',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              if (recentes.isEmpty)
                const Text(
                  'Nenhum voto ainda',
                  style: TextStyle(color: AppColors.muted),
                ),
              for (var i = 0; i < recentes.length; i++)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CatPhoto(
                              url: AppState.instance.voteThumbUrl(recentes[i]),
                              colorIndex: i,
                              iconSize: 18,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -5,
                          right: -5,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: recentes[i].isPositive
                                  ? AppColors.green
                                  : AppColors.pink,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              recentes[i].isPositive ? Icons.star : Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Foto grande com o selo "Raça · País de origem".
class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.image});

  final CatImage image;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.pastel(0),
        borderRadius: BorderRadius.circular(36),
        boxShadow: softShadow(0.18),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CatPhoto(url: image.url, iconSize: 64),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  image.breedLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Fundo que aparece atrás do card enquanto ele é deslizado.
class _SwipeHint extends StatelessWidget {
  const _SwipeHint({
    required this.icon,
    required this.color,
    required this.alignment,
  });

  final IconData icon;
  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Icon(icon, size: 56, color: color),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
    this.background = Colors.white,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: Material(
        color: background,
        elevation: 6,
        shadowColor: AppColors.primary.withAlpha(70),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: color, size: size * 0.44),
          ),
        ),
      ),
    );
  }
}