import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cat_app/model/my_photo.dart';
import 'package:cat_app/screens/my_photos_screen.dart';
import 'package:cat_app/screens/my_votes_screen.dart';
import 'package:cat_app/state/app_state.dart';
import 'package:cat_app/theme/app_theme.dart';
import 'package:cat_app/widgets/app_feedback.dart';
import 'package:cat_app/widgets/cat_photo.dart';
import 'package:cat_app/widgets/primary_button.dart';
import 'package:cat_app/widgets/screen_header.dart';
import 'package:cat_app/widgets/sub_page_header.dart';
import 'package:image_picker/image_picker.dart';

// Tela 7: Perfil.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<MyPhoto> _photos = [];
  bool _loadingPhotos = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  // Mostra as 3 últimas fotos enviadas, com a situação de cada uma.
  Future<void> _loadPhotos() async {
    if (AppState.instance.uploads.isEmpty) {
      setState(() => _photos = []);
      return;
    }
    setState(() => _loadingPhotos = true);
    try {
      final fotos = await AppState.instance.loadMyPhotos(max: 3);
      if (mounted) setState(() => _photos = fotos);
    } catch (_) {
      // mantém o que já estava na tela
    }
    if (mounted) setState(() => _loadingPhotos = false);
  }

  Future<void> _pickAndUpload() async {
    try {
      final escolhida = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (escolhida == null) return;
      setState(() => _uploading = true);
      final bytes = await escolhida.readAsBytes();
      final nome = escolhida.name.isNotEmpty ? escolhida.name : 'foto.jpg';
      await AppState.instance.uploadPhoto(bytes, nome);
      if (!mounted) return;
      showMessage(context, 'Foto enviada! Ela vai passar por uma análise.');
      await _loadPhotos();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _confirmSignOut() async {
    final sair = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seus votos e favoritos continuam salvos na The Cat API. '
              'Para vê-los de novo, use "Já tenho uma conta" com este código:',
            ),
            const SizedBox(height: 12),
            SelectableText(
              AppState.instance.subId,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.pink),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (sair == true) await AppState.instance.signOut();
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
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: BackCircleButton(),
                  ),
                  const SizedBox(height: 14),
                  _buildHeaderCard(state),
                  const SizedBox(height: 10),
                  _buildCode(state),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.star_border,
                        iconColor: AppColors.primary,
                        background: const Color(0xFFE0DBFF),
                        value: '${state.votes.length}',
                        label: 'Votos',
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.favorite_border,
                        iconColor: AppColors.pink,
                        background: const Color(0xFFFFD9E0),
                        value: '${state.favourites.length}',
                        label: 'Favoritos',
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.upload,
                        iconColor: AppColors.green,
                        background: const Color(0xFFD7F5E7),
                        value: '${state.uploads.length}',
                        label: 'Fotos',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPhotosCard(state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard(AppState state) {
    final nome = state.name.isNotEmpty ? state.name : 'Gateiro(a)';
    final mail = state.email.isNotEmpty ? state.email : 'Sem e-mail cadastrado';
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: softShadow(0.30),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                const UserAvatar(size: 68, tappable: false),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Código da conta (sub_id): toque para copiar.
  Widget _buildCode(AppState state) {
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: state.subId));
        if (mounted) showMessage(context, 'Código copiado!');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              'Código da conta: ${state.subId}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.copy, size: 14, color: AppColors.muted),
        ],
      ),
    );
  }

  Widget _buildPhotosCard(AppState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: softShadow(0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Minhas fotos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyPhotosScreen()),
                ),
                child: const Text(
                  'Ver todas',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildThumbs(state),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Enviar nova foto',
            icon: Icons.upload,
            loading: _uploading,
            onPressed: _pickAndUpload,
          ),
          const SizedBox(height: 16),
          _MenuTile(
            label: 'Meus votos',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyVotesScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _MenuTile(
            label: 'Sair da conta',
            color: AppColors.pink,
            onTap: _confirmSignOut,
          ),
        ],
      ),
    );
  }

  Widget _buildThumbs(AppState state) {
    if (state.uploads.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Você ainda não enviou nenhuma foto.',
          style: TextStyle(color: AppColors.muted, fontSize: 15),
        ),
      );
    }
    if (_loadingPhotos && _photos.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Row(
      children: [
        for (var i = 0; i < 3; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
              child: i < _photos.length
                  ? PhotoThumb(
                      photo: _photos[i],
                      index: i,
                      onDelete: () async {
                        final feito =
                            await confirmAndDeletePhoto(context, _photos[i]);
                        if (feito && mounted) _loadPhotos();
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }
}

// Pergunta se a pessoa quer apagar e, se sim, apaga. Devolve true se apagou.
Future<bool> confirmAndDeletePhoto(BuildContext context, MyPhoto photo) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Apagar foto?'),
      content: const Text(
        'Ela será excluída da The Cat API. Essa ação não pode ser desfeita.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.pink),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Apagar'),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  try {
    await AppState.instance.deletePhoto(photo.id);
    if (context.mounted) showMessage(context, 'Foto apagada.');
    return true;
  } catch (e) {
    if (context.mounted) showError(context, e);
    return false;
  }
}

// Miniatura de uma foto enviada, com o selo da situação.
// Se onDelete for informado, mostra o botão de lixeira no canto.
class PhotoThumb extends StatelessWidget {
  const PhotoThumb({
    super.key,
    required this.photo,
    required this.index,
    this.onDelete,
  });

  final MyPhoto photo;
  final int index;
  final VoidCallback? onDelete;

  Color get _color {
    switch (photo.status) {
      case PhotoStatus.approved:
        return AppColors.green;
      case PhotoStatus.rejected:
        return AppColors.pink;
      case PhotoStatus.pending:
        return AppColors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CatPhoto(url: photo.url, colorIndex: index, iconSize: 30),
            if (onDelete != null)
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.pink,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 6,
              right: 6,
              bottom: 6,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  photo.statusLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color background;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: softShadow(0.06),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.label,
    required this.onTap,
    this.color = AppColors.ink,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}