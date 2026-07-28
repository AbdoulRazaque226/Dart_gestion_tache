# Gestion de Tâches — CLI Dart

Application en ligne de commande de gestion de tâches, écrite en **Dart pur**
(sans Flutter).

## Fonctionnalités

- Ajouter une tâche (titre, priorité `low`/`medium`/`high`, date limite optionnelle)
- Marquer une tâche comme urgente à la création (priorité forcée à `high`)
- Lister toutes les tâches, avec tri par priorité ou par date
- Marquer une tâche comme terminée
- Supprimer une tâche
- Persistance automatique dans un fichier JSON local (`data/tasks.json`)

## Architecture

```
lib/
├── models/
│   ├── priority.dart      # enum Priority + extension
│   ├── task.dart          # classe abstraite Task (implements Comparable)
│   ├── simple_task.dart   # sous-classe concrète standard
│   └── urgent_task.dart   # sous-classe concrète (héritage spécialisé)
├── exceptions/
│   └── task_exceptions.dart  # TaskNotFoundException, InvalidTaskDataException, TaskPersistenceException
├── repository/
│   ├── repository.dart          # interface générique Repository<T>
│   └── json_task_repository.dart # implémentation avec persistance JSON
└── cli/
    └── task_cli.dart       # logique du menu / interactions console
bin/
└── main.dart               # point d'entrée
test/
└── repository_test.dart    # tests unitaires (8 tests)
```

### Choix techniques

- **Héritage** : `Task` est une classe abstraite héritée par `SimpleTask` et
  `UrgentTask`. Chacune redéfinit `affichage` et `type`.
- **Interface** : `Task implements Comparable<Task>` (tri par priorité) et
  `JsonTaskRepository implements Repository<Task>`.
- **Générique** : `Repository<T>` définit un contrat CRUD réutilisable pour
  n'importe quelle entité.
- **Exceptions personnalisées** : `TaskNotFoundException`,
  `InvalidTaskDataException`, `TaskPersistenceException`.
- **Persistance** : lecture/écriture JSON via `dart:convert` et `dart:io`,
  avec une fabrique polymorphe `Task.fromJson` qui instancie la bonne
  sous-classe selon un champ `"type"`.

## Prérequis

- [Dart SDK](https://dart.dev/get-dart) ≥ 3.0

## Installation

```bash
git clone <url-du-repo>
cd gestion_taches
dart pub get
```

## Lancer l'application

```bash
dart run bin/main.dart
```

Un menu s'affiche dans le terminal :

```
=== Gestion de Tâches ===
1. Ajouter une tâche
2. Lister les tâches
3. Marquer une tâche comme terminée
4. Supprimer une tâche
5. Quitter
```

Les données sont automatiquement sauvegardées dans `data/tasks.json` à
chaque modification, et rechargées au démarrage suivant.

## Lancer les tests

```bash
dart test
```

Les tests utilisent un répertoire temporaire pour ne jamais toucher au
fichier `data/tasks.json` réel.

## Exemple d'utilisation

```
Choix : 1
Titre de la tâche : Préparer la présentation
Tâche urgente ? (o/n) : n
Priorité (low/medium/high) : high
Date limite (AAAA-MM-JJ, laisser vide si aucune) : 2026-08-15
Tâche ajoutée avec succès (id : 1735...).

Choix : 2
Trier par (priorite/date/aucun) : priorite

--- Liste des tâches ---
⬜ [1735...] Préparer la présentation — priorité : high (échéance : 2026-08-15)
```
