import 'tache.dart';
import 'priority.dart';

/// Tâche "classique" avec une priorité choisie librement par l'utilisateur.
class SimpleTache extends Tache {
  SimpleTache({
    required super.id,
    required super.titre,
    required super.priorite,
    super.dateLimite,
    super.terminee,
  });

  @override
  String get type => 'simple';

  @override
  String get affichage {
    final statut = terminee ? '✅' : '⬜';
    final echeance = dateLimite != null
        ? ' (échéance : ${_formatDate(dateLimite!)})'
        : '';
    return '$statut [$id] $titre — priorité : ${priorite.label}$echeance';
  }

  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;

  factory SimpleTache.fromJson(Map<String, dynamic> json) {
    return SimpleTache(
      id: json['id'] as String,
      titre: json['titre'] as String,
      priorite: PriorityExtension.fromString(json['priorite'] as String),
      dateLimite: json['dateLimite'] != null
          ? DateTime.parse(json['dateLimite'] as String)
          : null,
      terminee: json['terminee'] as bool? ?? false,
    );
  }
}
