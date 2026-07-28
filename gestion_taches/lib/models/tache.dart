import 'priority.dart';
import 'simple_tache.dart';
import 'urgent_tache.dart';

/// Classe abstraite représentant une tâche.
///
/// Implémente [Comparable] pour permettre le tri par priorité.
/// Les sous-classes concrètes sont [SimpleTask] et [UrgentTask].
abstract class Tache implements Comparable<Tache> {
  final String id;
  String titre;
  Priority priorite;
  DateTime? dateLimite;
  bool terminee;

  Tache({
    required this.id,
    required this.titre,
    required this.priorite,
    this.dateLimite,
    this.terminee = false,
  });

  /// Identifiant du type concret, utilisé pour la (dé)sérialisation JSON.
  String get type;

  /// Représentation textuelle affichée dans la CLI.
  /// Chaque sous-classe doit fournir sa propre implémentation.
  String get affichage;

  /// Sérialisation de base commune à toutes les tâches.
  /// Les sous-classes peuvent l'étendre (voir [UrgentTask.toJson]).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'priorite': priorite.label,
      'dateLimite': dateLimite?.toIso8601String(),
      'terminee': terminee,
      'type': type,
    };
  }

  /// Fabrique polymorphe : instancie la bonne sous-classe selon le champ
  /// "type" du JSON.
  factory Tache.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'simple';
    switch (type) {
      case 'urgent':
        return UrgentTache.fromJson(json);
      case 'simple':
      default:
        return SimpleTache.fromJson(json);
    }
  }

  /// Tri par priorité décroissante (high en premier).
  @override
  int compareTo(Tache other) {
    return other.priorite.weight.compareTo(priorite.weight);
  }

  /// Tri par date limite croissante. Les tâches sans date sont placées
  /// à la fin.
  int compareByDate(Tache other) {
    if (dateLimite == null && other.dateLimite == null) return 0;
    if (dateLimite == null) return 1;
    if (other.dateLimite == null) return -1;
    return dateLimite!.compareTo(other.dateLimite!);
  }
}
