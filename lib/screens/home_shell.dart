import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cat_app/screens/breeds_screen.dart';
import 'package:cat_app/screens/discover_screen.dart';
import 'package:cat_app/screens/favourites_screen.dart';
import 'package:cat_app/screens/profile_screen.dart';
import 'package:cat_app/screens/vote_screen.dart';
import 'package:cat_app/state/app_state.dart';
import 'package:cat_app/state/navigation.dart';
import 'package:cat_app/widgets/floating_nav_bar.dart';

// Estrutura principal: 5 abas com a barra flutuante embaixo.
// Cada aba tem o seu próprio Navigator, assim a barra continua visível
// quando se abre o detalhe de uma raça.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final List<GlobalKey<NavigatorState>> _navKeys =
      List.generate(5, (_) => GlobalKey<NavigatorState>());

  // Só cria uma aba quando ela é aberta pela primeira vez
  // (evita gastar a cota de requisições da API logo no início).
  final Set<int> _visited = {0};

  @override
  void initState() {
    super.initState();
    currentTab.value = 0;
    // Carrega favoritos e votos do usuário (depois do primeiro frame, porque
    // o estado avisa os ouvintes e isso não pode acontecer durante o build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppState.instance.bootstrap();
    });
  }

  Widget _root(int i) {
    switch (i) {
      case 0:
        return const DiscoverScreen();
      case 1:
        return const BreedsScreen();
      case 2:
        return const VoteScreen();
      case 3:
        return const FavouritesScreen();
      default:
        return const ProfileScreen();
    }
  }

  Widget _tab(int i) {
    return HeroControllerScope.none(
      child: Navigator(
        key: _navKeys[i],
        onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => _root(i)),
      ),
    );
  }

  void _select(int i) {
    if (i == currentTab.value) {
      // tocar de novo na aba atual volta para a tela inicial dela
      _navKeys[i].currentState?.popUntil((r) => r.isFirst);
    } else {
      currentTab.value = i;
    }
  }

  // Botão "voltar" do Android: fecha telas internas, depois volta para
  // Descobrir, e só então sai do app.
  void _onBack(bool didPop, Object? result) {
    if (didPop) return;
    final nav = _navKeys[currentTab.value].currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    } else if (currentTab.value != 0) {
      currentTab.value = 0;
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onBack,
      child: ValueListenableBuilder<int>(
        valueListenable: currentTab,
        builder: (context, tab, _) {
          _visited.add(tab);
          return Scaffold(
            body: IndexedStack(
              index: tab,
              children: [
                for (var i = 0; i < 5; i++)
                  _visited.contains(i) ? _tab(i) : const SizedBox.shrink(),
              ],
            ),
            bottomNavigationBar: FloatingNavBar(index: tab, onTap: _select),
          );
        },
      ),
    );
  }
}
