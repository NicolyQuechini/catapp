import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cat_app/config.dart';
import 'package:cat_app/state/app_state.dart';
import 'package:cat_app/theme/app_theme.dart';
import 'package:cat_app/widgets/primary_button.dart';

// Tela 1: Onboarding.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const List<List<String>> _slides = [
    [
      'Todos os gatos do mundo na palma da mão',
      'Descubra raças, vote nos seus favoritos e envie as suas próprias fotos.',
    ],
    [
      'Conheça cada raça',
      'Veja origem, expectativa de vida e o nível de afeto, energia e inteligência.',
    ],
    [
      'Vote e salve os favoritos',
      'Deslize para votar nas fotos e guarde os gatinhos que você mais amou.',
    ],
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // "Começar": pede nome e e-mail (opcionais) e cria o usuário.
  void _start() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => const _ProfileSheet(),
    );
  }

  // "Já tenho uma conta": volta a usar um código (sub_id) já existente.
  Future<void> _signIn() async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _CodeDialog(),
    );
    if (code != null && code.isNotEmpty) {
      await AppState.instance.signInWithCode(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // círculos decorativos do fundo
          Positioned(
            top: -90,
            right: -80,
            child: _circle(280, AppColors.primaryLight),
          ),
          Positioned(
            top: 280,
            left: -110,
            child: _circle(240, AppColors.primaryLight.withAlpha(110)),
          ),
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppConfig.appName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const Expanded(child: _CardsArt()),
              _buildPanel(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _buildPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 175,
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _slides[i][0],
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _slides[i][1],
                      style: const TextStyle(
                        fontSize: 17,
                        color: AppColors.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < _slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 6),
                    width: i == _page ? 26 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? AppColors.primary
                          : const Color(0xFFD9D3FA),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Começar', onPressed: _start),
            const SizedBox(height: 4),
            TextButton(
              onPressed: _signIn,
              child: const Text(
                'Já tenho uma conta',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Três cards pastel inclinados com a patinha (ilustração do topo).
class _CardsArt extends StatelessWidget {
  const _CardsArt();

  Widget _card(double size, int color, double angle) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size,
        height: size * 1.1,
        decoration: BoxDecoration(
          color: AppColors.pastel(color),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white, width: 6),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 10)),
          ],
        ),
        child: Icon(Icons.pets, size: size * 0.3, color: AppColors.pastelInk(color)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final size = math.min(c.maxWidth * 0.44, c.maxHeight * 0.55);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: c.maxWidth * 0.06,
              top: c.maxHeight * 0.04,
              child: _card(size, 0, -0.10),
            ),
            Positioned(
              right: c.maxWidth * 0.04,
              top: c.maxHeight * 0.14,
              child: _card(size, 2, 0.10),
            ),
            Positioned(
              left: c.maxWidth * 0.28,
              top: c.maxHeight * 0.36,
              child: _card(size, 1, -0.02),
            ),
          ],
        );
      },
    );
  }
}

// Folha de baixo: nome e e-mail (opcionais) para criar o perfil.
class _ProfileSheet extends StatefulWidget {
  const _ProfileSheet();

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  final _name = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _enter() async {
    final nome = _name.text;
    final mail = _email.text;
    Navigator.of(context).pop();
    await AppState.instance.createAccount(name: nome, email: mail);
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Como podemos te chamar?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Opcional. Os dados ficam só neste aparelho.',
            style: TextStyle(color: AppColors.muted, fontSize: 15),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: _decoration('Seu nome'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: _decoration('Seu e-mail'),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Entrar', onPressed: _enter),
        ],
      ),
    );
  }
}

// Diálogo de "Já tenho uma conta": pede o código (sub_id).
class _CodeDialog extends StatefulWidget {
  const _CodeDialog();

  @override
  State<_CodeDialog> createState() => _CodeDialogState();
}

class _CodeDialogState extends State<_CodeDialog> {
  final _code = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _confirm() {
    final texto = _code.text.trim();
    if (!RegExp(r'^[A-Za-z0-9_\-]{3,}$').hasMatch(texto)) {
      setState(() => _error = 'Digite um código válido (letras, números e -).');
      return;
    }
    Navigator.of(context).pop(texto);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Entrar com seu código'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Use o código da conta (aparece no Perfil) para recuperar seus votos e favoritos.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _code,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: 'gato-xxxxxxxxxx',
              errorText: _error,
            ),
            onSubmitted: (_) => _confirm(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _confirm, child: const Text('Entrar')),
      ],
    );
  }
}
