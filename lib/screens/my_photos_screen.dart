import 'package:flutter/material.dart';
import 'package:cat_app/model/my_photo.dart';
import 'package:cat_app/screens/profile_screen.dart';
import 'package:cat_app/services/cat_api_exception.dart';
import 'package:cat_app/state/app_state.dart';
import 'package:cat_app/widgets/app_feedback.dart';
import 'package:cat_app/widgets/sub_page_header.dart';

// "Ver todas": todas as fotos enviadas, com a situação de cada uma.
class MyPhotosScreen extends StatefulWidget {
  const MyPhotosScreen({super.key});

  @override
  State<MyPhotosScreen> createState() => _MyPhotosScreenState();
}

class _MyPhotosScreenState extends State<MyPhotosScreen> {
  List<MyPhoto> _photos = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final fotos = await AppState.instance.loadMyPhotos();
      if (!mounted) return;
      setState(() {
        _photos = fotos;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SubPageHeader(title: 'Minhas fotos'),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    return RefreshIndicator(
      onRefresh: _load,
      child: _photos.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(
                  height: 300,
                  child: EmptyView(
                    icon: Icons.photo_outlined,
                    message: 'Você ainda não enviou nenhuma foto.',
                  ),
                ),
              ],
            )
          : GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.8,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, i) => PhotoThumb(
                photo: _photos[i],
                index: i,
                onDelete: () async {
                  final foto = _photos[i];
                  final feito = await confirmAndDeletePhoto(context, foto);
                  if (feito && mounted) {
                    setState(() => _photos.removeWhere((p) => p.id == foto.id));
                  }
                },
              ),
            ),
    );
  }
}