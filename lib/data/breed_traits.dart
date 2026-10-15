// Notas de 1 a 5 usadas quando a API não envia as características da raça.
// A conta Free recebe o formato simples de raça, sem esses campos.
// Os valores da tabela são aproximados (não vêm da API).
class BreedTraits {
  final int affection;
  final int energy;
  final int intelligence;
  final int social;
  const BreedTraits(this.affection, this.energy, this.intelligence, this.social);
}

// id da raça -> (afeto, energia, inteligência, sociabilidade)
const Map<String, BreedTraits> _tabela = {
  'abys': BreedTraits(5, 5, 5, 5),
  'aege': BreedTraits(5, 5, 5, 5),
  'amau': BreedTraits(4, 5, 4, 4),
  'asho': BreedTraits(4, 3, 3, 3),
  'beng': BreedTraits(5, 5, 5, 5),
  'birm': BreedTraits(5, 3, 3, 5),
  'bomb': BreedTraits(5, 3, 3, 5),
  'bsho': BreedTraits(4, 2, 3, 3),
  'bslo': BreedTraits(4, 2, 3, 3),
  'bure': BreedTraits(5, 4, 5, 5),
  'chau': BreedTraits(3, 5, 5, 3),
  'cymr': BreedTraits(4, 3, 3, 4),
  'ebur': BreedTraits(5, 4, 5, 5),
  'esho': BreedTraits(5, 2, 3, 4),
  'hima': BreedTraits(5, 2, 3, 3),
  'java': BreedTraits(5, 4, 4, 5),
  'khao': BreedTraits(5, 4, 5, 5),
  'mcoo': BreedTraits(5, 3, 5, 5),
  'manx': BreedTraits(5, 4, 4, 4),
  'norw': BreedTraits(4, 3, 4, 4),
  'ocic': BreedTraits(5, 5, 5, 5),
  'orie': BreedTraits(5, 5, 5, 5),
  'pers': BreedTraits(5, 1, 3, 3),
  'ragd': BreedTraits(5, 2, 3, 5),
  'rblu': BreedTraits(3, 3, 5, 3),
  'sava': BreedTraits(5, 5, 5, 4),
  'sfol': BreedTraits(5, 2, 3, 5),
  'sibe': BreedTraits(5, 4, 4, 4),
  'siam': BreedTraits(5, 5, 5, 5),
  'sing': BreedTraits(5, 5, 5, 5),
  'sphy': BreedTraits(5, 3, 4, 5),
  'srex': BreedTraits(5, 3, 3, 5),
  'tonk': BreedTraits(5, 5, 5, 5),
};

// Busca na tabela; se a raça não estiver, estima pelo temperamento.
BreedTraits? traitsFor(String id, String? temperament) {
  final t = _tabela[id];
  if (t != null) return t;
  return _porTemperamento(temperament);
}

BreedTraits? _porTemperamento(String? temperamento) {
  final t = (temperamento ?? '').toLowerCase();
  if (t.trim().isEmpty) return null;

  int nota(List<String> mais, List<String> menos) {
    var n = 3;
    for (final p in mais) {
      if (t.contains(p)) n++;
    }
    for (final p in menos) {
      if (t.contains(p)) n--;
    }
    return n.clamp(1, 5).toInt();
  }

  return BreedTraits(
    nota(
      ['affectionate', 'loving', 'devoted', 'sweet', 'loyal', 'gentle', 'cuddly', 'people-oriented'],
      ['independent', 'reserved', 'aloof', 'shy'],
    ),
    nota(
      ['active', 'energetic', 'playful', 'agile', 'lively', 'athletic', 'curious'],
      ['calm', 'gentle', 'quiet', 'relaxed', 'placid', 'docile', 'laid-back'],
    ),
    nota(
      ['intelligent', 'clever', 'smart', 'curious', 'alert', 'inquisitive', 'quick'],
      [],
    ),
    nota(
      ['social', 'sociable', 'friendly', 'outgoing', 'playful', 'affectionate', 'loving', 'people-oriented'],
      ['reserved', 'aloof', 'shy', 'independent', 'timid'],
    ),
  );
}