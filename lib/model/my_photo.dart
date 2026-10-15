// Situação de uma foto enviada pelo usuário, como mostrada no perfil.
enum PhotoStatus { approved, pending, rejected }

// Converte a situação devolvida por GET /images/{id}/status:
// to_be_reviewed (processando), clean (aprovada), unsafe (rejeitada),
// flagged (revisão manual), does_not_contain_species (rejeitada), labelled (pronta).
PhotoStatus photoStatusFromApi(String? status) {
  switch (status) {
    case 'clean':
    case 'labelled':
      return PhotoStatus.approved;
    case 'unsafe':
    case 'does_not_contain_species':
      return PhotoStatus.rejected;
    case 'to_be_reviewed':
    case 'flagged':
    default:
      return PhotoStatus.pending;
  }
}

class MyPhoto {
  final String id;
  final String? url;
  final PhotoStatus status;

  MyPhoto({required this.id, this.url, required this.status});

  String get statusLabel {
    switch (status) {
      case PhotoStatus.approved:
        return 'Aprovada';
      case PhotoStatus.rejected:
        return 'Recusada';
      case PhotoStatus.pending:
        return 'Em análise';
    }
  }
}
