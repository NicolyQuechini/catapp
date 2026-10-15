// Configurações gerais do app.
class AppConfig {
  // Nome do app (troque aqui e muda em todas as telas).
  static const String appName = 'Miaudex';

  // URL base indicada na documentação (exemplos do site).
  static const String apiBaseUrl = 'https://api.thecatapi.com/v1';

  // Chave da API.
  // Para testar: cole a sua chave no lugar de COLE_SUA_CHAVE_AQUI, entre as
  // aspas simples, sem espaços. ANTES DE SUBIR PARA O GITHUB, volte para 'DEMO-API-KEY'.
  // Se rodar com --dart-define=CAT_API_KEY=..., o valor do comando vence este.
  static final String apiKey = _limpar(
    const String.fromEnvironment(
      'CAT_API_KEY',
      defaultValue: 'DEMO-API-KEY',
    ),
  );

  // Remove espaços e aspas que sobrarem na chave.
  static String _limpar(String v) =>
      v.trim().replaceAll('"', '').replaceAll("'", '');

  // Endereço público das imagens (usado quando a API só devolve o id da imagem).
  static const String imageCdn = 'https://cdn2.thecatapi.com/images';
}