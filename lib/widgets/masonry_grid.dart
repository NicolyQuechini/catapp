import 'package:flutter/material.dart';

// Grade de duas colunas com alturas alternadas (como no wireframe).
// Os itens pares vão para a coluna da esquerda e os ímpares para a da direita.
class MasonryGrid extends StatelessWidget {
  const MasonryGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = 14,
  });

  final int itemCount;
  final double spacing;

  // Recebe o índice e a proporção (largura / altura) que o item deve ter.
  final Widget Function(BuildContext context, int index, double aspectRatio)
      itemBuilder;

  // esquerda: alto, baixo, alto... | direita: baixo, alto, baixo...
  static const List<double> _ratios = [0.95, 1.4, 1.4, 0.95];

  @override
  Widget build(BuildContext context) {
    final esquerda = <Widget>[];
    final direita = <Widget>[];
    for (var i = 0; i < itemCount; i++) {
      final item = Padding(
        padding: EdgeInsets.only(bottom: spacing),
        child: itemBuilder(context, i, _ratios[i % _ratios.length]),
      );
      (i.isEven ? esquerda : direita).add(item);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Column(children: esquerda)),
        SizedBox(width: spacing),
        Expanded(child: Column(children: direita)),
      ],
    );
  }
}
