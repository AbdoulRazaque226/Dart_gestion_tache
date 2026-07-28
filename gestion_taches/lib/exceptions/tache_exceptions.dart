/// Levée lorsqu'une tâche recherchée par son id n'existe pas.
class TaskNotFoundException implements Exception {
  final String id;
  TaskNotFoundException(this.id);

  @override
  String toString() => 'Tâche introuvable : $id';
}

/// Levée lorsque des données fournies pour créer/modifier une tâche
/// sont invalides (titre vide, priorité inconnue, etc.).
class InvalidTaskDataException implements Exception {
  final String message;
  InvalidTaskDataException(this.message);

  @override
  String toString() => 'Données de tâche invalides : $message';
}

/// Levée en cas d'erreur de lecture/écriture du fichier JSON de persistance.
class TaskPersistenceException implements Exception {
  final String message;
  TaskPersistenceException(this.message);

  @override
  String toString() => 'Erreur de persistance : $message';
}
