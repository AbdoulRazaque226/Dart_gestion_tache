/// Représente le niveau de priorité d'une tâche.
enum Priority { low, medium, high }

/// Extension utilitaire pour convertir [Priority] vers/depuis une chaîne,
/// et obtenir un poids numérique utilisé pour le tri.
extension PriorityExtension on Priority {
  String get label {
    switch (this) {
      case Priority.low:
        return 'low';
      case Priority.medium:
        return 'medium';
      case Priority.high:
        return 'high';
    }
  }

  /// Poids utilisé pour le tri : high > medium > low.
  int get weight {
    switch (this) {
      case Priority.high:
        return 3;
      case Priority.medium:
        return 2;
      case Priority.low:
        return 1;
    }
  }

  static Priority fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'medium':
        return Priority.medium;
      case 'high':
        return Priority.high;
      default:
        throw ArgumentError(
          'Priorité inconnue : "$value" (attendu : low, medium ou high)',
        );
    }
  }
}
