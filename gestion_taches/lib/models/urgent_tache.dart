import 'tache.dart';
import 'priority.dart';

/// Tâche urgente : priorité toujours forcée à [Priority.high] et affichage
/// distinct pour attirer l'attention de l'utilisateur.
class UrgentTache extends Tache {
  /// Indique si la tâche doit être signalée/escaladée (ex. notification).
  final bool escalade;

  UrgentTache({
    required String id,
    required String titre,
    DateTime? dateLimite,
    bool terminee = false,
    this.escalade = true,
  }) : super(
          id: id,
          titre: titre,
          priorite: Priority.high,
          dateLimite: dateLimite,
          terminee: terminee,
        );

  @override
  String get type => 'urgent';

  @override
  String get affichage {
    final statut = terminee ? '' : '';
    final echeance = dateLimite != null
        ? ' (échéance : ${_formatDate(dateLimite!)})'
        : ' (aucune échéance définie !)';
    return '$statut  URGENT [$id] $titre$echeance';
  }

  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['escalade'] = escalade;
    return json;
  }

  factory UrgentTache.fromJson(Map<String, dynamic> json) {
    return UrgentTache(
      id: json['id'] as String,
      titre: json['titre'] as String,
      dateLimite: json['dateLimite'] != null
          ? DateTime.parse(json['dateLimite'] as String)
          : null,
      terminee: json['terminee'] as bool? ?? false,
      escalade: json['escalade'] as bool? ?? true,
    );
  }
}
