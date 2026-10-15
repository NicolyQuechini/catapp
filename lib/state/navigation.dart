import 'package:flutter/foundation.dart';

// Aba selecionada na barra de baixo (0 = Descobrir ... 4 = Perfil).
// É global para que o avatar "G" do topo das telas consiga abrir o Perfil.
final ValueNotifier<int> currentTab = ValueNotifier<int>(0);
