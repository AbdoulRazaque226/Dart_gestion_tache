import 'dart:convert';
import 'dart:io';

import '../models/tache.dart';
import '../exceptions/tache_exceptions.dart';
import 'repository.dart';

/// Repository de tâches persistant les données dans un fichier JSON local.
///
/// Implémente le [Repository] générique spécialisé pour [Task].
class JsonTaskRepository implements Repository<Tache> {
  final String filePath;
  final List<Tache> _taches = [];

  JsonTaskRepository({this.filePath = 'data/tasks.json'}) {
    _charger();
  }

  void _charger() {
    final file = File(filePath);
    if (!file.existsSync()) {
      return;
    }
    try {
      final contenu = file.readAsStringSync();
      if (contenu.trim().isEmpty) return;
      final List<dynamic> liste = jsonDecode(contenu) as List<dynamic>;
      _taches
        ..clear()
        ..addAll(liste.map((e) => Tache.fromJson(e as Map<String, dynamic>)));
    } catch (e) {
      throw TaskPersistenceException('Impossible de lire $filePath : $e');
    }
  }

  void _sauvegarder() {
    try {
      final file = File(filePath);
      file.parent.createSync(recursive: true);
      final liste = _taches.map((t) => t.toJson()).toList();
      file.writeAsStringSync(jsonEncode(liste));
    } catch (e) {
      throw TaskPersistenceException("Impossible d'écrire $filePath : $e");
    }
  }

  @override
  void add(Tache item) {
    _taches.add(item);
    _sauvegarder();
  }

  @override
  void remove(String id) {
    final index = _taches.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw TaskNotFoundException(id);
    }
    _taches.removeAt(index);
    _sauvegarder();
  }

  @override
  Tache getById(String id) {
    for (final t in _taches) {
      if (t.id == id) return t;
    }
    throw TaskNotFoundException(id);
  }

  @override
  List<Tache> getAll() => List.unmodifiable(_taches);

  @override
  void update(Tache item) {
    final index = _taches.indexWhere((t) => t.id == item.id);
    if (index == -1) {
      throw TaskNotFoundException(item.id);
    }
    _taches[index] = item;
    _sauvegarder();
  }

  /// Retourne une copie triée par priorité décroissante (high → low).
  List<Tache> trierParPriorite() {
    final copie = List<Tache>.from(_taches);
    copie.sort();
    return copie;
  }

  /// Retourne une copie triée par date limite croissante
  /// (les tâches sans date sont placées à la fin).
  List<Tache> trierParDate() {
    final copie = List<Tache>.from(_taches);
    copie.sort((a, b) => a.compareByDate(b));
    return copie;
  }
}
