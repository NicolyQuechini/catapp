// Funções auxiliares para ler o JSON da API com segurança.
// A documentação recomenda tratar quase todos os campos como opcionais e
// converter números explicitamente (a API pode mandar int ou double).

int? asInt(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

String? asString(dynamic v) => v?.toString();

bool asBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  return v?.toString().toLowerCase() == 'true';
}

DateTime? asDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

// Converte uma lista dinâmica em lista de mapas (ignora o que não for mapa).
List<Map<String, dynamic>> asMapList(dynamic v) {
  if (v is! List) return const [];
  return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

List<String> asStringList(dynamic v) {
  if (v is! List) return const [];
  return v.map((e) => e.toString()).toList();
}
