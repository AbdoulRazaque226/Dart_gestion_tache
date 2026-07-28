import 'dart:io';

import '../models/priority.dart';
import '../models/simple_tache.dart';
import '../models/urgent_tache.dart';
import '../models/tache.dart';
import '../exceptions/tache_exceptions.dart';
import '../repository/json_tache_repository.dart';


class TacheCli {
  final JsonTaskRepository repository;

  TacheCli({JsonTaskRepository? repository})
      : repository = repository ?? JsonTaskRepository();

  void afficherMenu() {
    print('\n Gestion de Tâches ');
    print('1. Ajouter une tâche');
    print('2. Lister les tâches');
    print('3. Marquer une tâche comme terminée');
    print('4. Supprimer une tâche');
    print('5. Quitter');
    stdout.write('Choix : ');
  }

  /// Boucle principale de l'application.
  void run() {
    var continuer = true;
    while (continuer) {
      afficherMenu();
      final choix = stdin.readLineSync()?.trim();

      switch (choix) {
        case '1':
          ajouterTache();
          break;
        case '2':
          listerTaches();
          break;
        case '3':
          marquerTerminee();
          break;
        case '4':
          supprimerTache();
          break;
        case '5':
          continuer = false;
          print('Au revoir !');
          break;
        default:
          print('Choix invalide, réessayez.');
      }
    }
  }

  void ajouterTache() {
    stdout.write('Titre de la tâche : ');
    final titre = stdin.readLineSync()?.trim() ?? '';
    if (titre.isEmpty) {
      print('Erreur : le titre ne peut pas être vide.');
      return;
    }

    stdout.write('Tâche urgente ? (o/n) : ');
    final urgentStr = (stdin.readLineSync() ?? '').trim().toLowerCase();
    final estUrgente = urgentStr == 'o' || urgentStr == 'oui';

    Priority priorite = Priority.medium;
    if (!estUrgente) {
      stdout.write('Priorité (low/medium/high) : ');
      final prioriteStr = stdin.readLineSync()?.trim() ?? 'medium';
      try {
        priorite = PriorityExtension.fromString(prioriteStr);
      } on ArgumentError catch (e) {
        print('Erreur : $e');
        return;
      }
    }

    stdout.write('Date limite (AAAA-MM-JJ, laisser vide si aucune) : ');
    final dateStr = stdin.readLineSync()?.trim() ?? '';

    try {
      final dateLimite = dateStr.isEmpty ? null : DateTime.parse(dateStr);
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      final Tache tache = estUrgente
          ? UrgentTache(id: id, titre: titre, dateLimite: dateLimite)
          : SimpleTache(
              id: id,
              titre: titre,
              priorite: priorite,
              dateLimite: dateLimite,
            );

      repository.add(tache);
      print('Tâche ajoutée avec succès (id : $id).');
    } on FormatException {
      print('Erreur : format de date invalide, attendu AAAA-MM-JJ.');
    } on TaskPersistenceException catch (e) {
      print('Erreur : $e');
    }
  }

  void listerTaches() {
    if (repository.getAll().isEmpty) {
      print('Aucune tâche enregistrée.');
      return;
    }

    stdout.write('Trier par (priorite/date/aucun) : ');
    final tri = (stdin.readLineSync() ?? '').trim().toLowerCase();

    late final List<Tache> taches;
    switch (tri) {
      case 'priorite':
        taches = repository.trierParPriorite();
        break;
      case 'date':
        taches = repository.trierParDate();
        break;
      default:
        taches = repository.getAll();
    }

    print('\n--- Liste des tâches ---');
    for (final t in taches) {
      print(t.affichage);
    }
  }

  void marquerTerminee() {
    stdout.write('Id de la tâche à marquer comme terminée : ');
    final id = stdin.readLineSync()?.trim() ?? '';
    try {
      final tache = repository.getById(id);
      tache.terminee = true;
      repository.update(tache);
      print('Tâche $id marquée comme terminée.');
    } on TaskNotFoundException catch (e) {
      print(e);
    }
  }

  void supprimerTache() {
    stdout.write('Id de la tâche à supprimer : ');
    final id = stdin.readLineSync()?.trim() ?? '';
    try {
      repository.remove(id);
      print('Tâche $id supprimée.');
    } on TaskNotFoundException catch (e) {
      print(e);
    }
  }
}
