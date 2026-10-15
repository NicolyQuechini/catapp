import 'dart:convert';

import 'package:cat_app/config.dart';

// Exceção própria do app: guarda o código de status e o corpo da resposta
// (como pede a documentação) e já traduz o erro para o usuário.
class CatApiException implements Exception {
  final int? statusCode; // null quando foi falha de conexão
  final String body;

  CatApiException(this.statusCode, this.body);

  // Falha de rede (sem internet, tempo esgotado, etc.)
  CatApiException.network(Object error)
      : statusCode = null,
        body = error.toString();

  bool get isNetwork => statusCode == null;

  // Mensagem enviada pela própria API, quando o corpo é um JSON com "message".
  String? get _apiMessage {
    try {
      final d = json.decode(body);
      if (d is Map && d['message'] != null) return d['message'].toString();
    } catch (_) {}
    return null;
  }

  // Mostra o começo e o tamanho da chave que o app está usando, para achar
  // erro de digitação (a chave certa começa com "live_" e tem ~69 caracteres).
  String get _chaveEmUso {
    final k = AppConfig.apiKey;
    final inicio = k.length > 5 ? k.substring(0, 5) : k;
    return 'Chave em uso: $inicio... (${k.length} caracteres).';
  }

  // Mensagens específicas para 401, 403, 404, 429 e falhas de conectividade.
  String get message {
    switch (statusCode) {
      case null:
        return 'Sem conexão com a internet. Verifique sua rede e tente de novo.';
      case 401:
        return 'Chave da API ausente ou inválida. $_chaveEmUso';
      case 403:
        final m = _apiMessage;
        if (m != null && m.toLowerCase().contains('plan')) {
          return 'Este recurso não está disponível no plano Free da The Cat API.';
        }
        return m != null
            ? 'Acesso negado pela API: $m'
            : 'Acesso negado pela API (403). Confira a chave e o plano.';
      case 404:
        return 'Não encontramos o que você procurava.';
      case 429:
        return 'Limite de requisições da API atingido. Tente mais tarde.';
      default:
        final m = _apiMessage;
        return m != null
            ? 'Erro da The Cat API ($statusCode): $m'
            : 'Erro ao falar com a The Cat API (código $statusCode).';
    }
  }

  @override
  String toString() => 'CatApiException($statusCode): $body';
}

// Transforma qualquer erro em texto amigável.
String friendlyError(Object error) {
  if (error is CatApiException) return error.message;
  return 'Algo deu errado. Tente novamente.';
}