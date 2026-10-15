import 'package:flutter/material.dart';
import 'package:cat_app/theme/app_theme.dart';

class _NavItem {
  const _NavItem(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// Barra de navegação branca "flutuante". A aba ativa vira uma pílula roxa
// com ícone + nome.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key, required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const List<_NavItem> _items = [
    _NavItem(Icons.explore_outlined, Icons.explore, 'Descobrir'),
    _NavItem(Icons.menu, Icons.menu, 'Raças'),
    _NavItem(Icons.star_border, Icons.star, 'Votar'),
    _NavItem(Icons.favorite_border, Icons.favorite, 'Favoritos'),
    _NavItem(Icons.person_outline, Icons.person, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(34),
            boxShadow: softShadow(0.14),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const larguraInativo = 44.0;
              // a aba ativa ocupa o espaço que sobra
              final larguraAtivo =
                  constraints.maxWidth - larguraInativo * (_items.length - 1);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < _items.length; i++)
                    _buildItem(i, i == index ? larguraAtivo : larguraInativo),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int i, double largura) {
    final item = _items[i];
    final ativo = i == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: largura,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ativo ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: ativo
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.activeIcon, color: Colors.white, size: 22),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              )
            : Icon(item.icon, color: AppColors.muted, size: 26),
      ),
    );
  }
}
