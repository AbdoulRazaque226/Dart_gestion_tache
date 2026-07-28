import 'dart:io';

import 'package:test/test.dart';
import 'package:gestion_taches/models/priority.dart';
import 'package:gestion_taches/models/simple_tache.dart';
import 'package:gestion_taches/models/urgent_tache.dart';
import 'package:gestion_taches/exceptions/tache_exceptions.dart';
import 'package:gestion_taches/repository/json_tache_repository.dart';

void main() {
  late Directory tempDir;
  late String filePath;
  late JsonTaskRepository repo;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('gestion_taches_test_');
    filePath = '${tempDir.path}/tasks_test.json';
    repo = JsonTaskRepository(filePath: filePath);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('add puis getAll retourne bien la tâche ajoutée', () {
    final tache = SimpleTache(id: '1', titre: 'Test', priorite: Priority.medium);
    repo.add(tache);

    expect(repo.getAll().length, 1);
    expect(repo.getAll().first.titre, 'Test');
  });

  test('remove sur un id inexistant lève TaskNotFoundException', () {
    expect(() => repo.remove('inexistant'), throwsA(isA<TaskNotFoundException>()));
  });

  test('getById sur un id inexistant lève TaskNotFoundException', () {
    expect(() => repo.getById('fantome'), throwsA(isA<TaskNotFoundException>()));
  });

  test('tri par priorité place high avant medium avant low', () {
    repo.add(SimpleTache(id: '1', titre: 'Basse', priorite: Priority.low));
    repo.add(SimpleTache(id: '2', titre: 'Haute', priorite: Priority.high));
    repo.add(SimpleTache(id: '3', titre: 'Moyenne', priorite: Priority.medium));

    final triees = repo.trierParPriorite();

    expect(triees[0].priorite, Priority.high);
    expect(triees[1].priorite, Priority.medium);
    expect(triees[2].priorite, Priority.low);
  });

  test('tri par date place les échéances les plus proches en premier', () {
    repo.add(SimpleTache(
      id: '1',
      titre: 'Tard',
      priorite: Priority.low,
      dateLimite: DateTime(2026, 12, 1),
    ));
    repo.add(SimpleTache(
      id: '2',
      titre: 'Tôt',
      priorite: Priority.low,
      dateLimite: DateTime(2026, 8, 1),
    ));
    repo.add(SimpleTache(
      id: '3',
      titre: 'Sans échéance',
      priorite: Priority.low,
    ));

    final triees = repo.trierParDate();

    expect(triees[0].id, '2');
    expect(triees[1].id, '1');
    expect(triees[2].id, '3'); // sans date -> à la fin
  });

  test('la persistance JSON conserve les données après rechargement', () {
    repo.add(SimpleTache(id: '1', titre: 'Persistée', priorite: Priority.high));
    repo.add(UrgentTache(id: '2', titre: 'Urgente persistée'));

    // Nouveau repository pointant sur le même fichier : simule un redémarrage.
    final repoRecharge = JsonTaskRepository(filePath: filePath);

    expect(repoRecharge.getAll().length, 2);
    expect(repoRecharge.getById('1').titre, 'Persistée');
    expect(repoRecharge.getById('2'), isA<UrgentTache>());
  });

  test('UrgentTask force la priorité high et a un affichage distinct', () {
    final simple = SimpleTache(id: '1', titre: 'Normale', priorite: Priority.low);
    final urgente = UrgentTache(id: '2', titre: 'Urgente');

    expect(urgente.priorite, Priority.high);
    expect(simple.affichage.contains('URGENT'), isFalse);
    expect(urgente.affichage.contains('URGENT'), isTrue);
  });

  test('marquer une tâche comme terminée met à jour et persiste l\'état', () {
    repo.add(SimpleTache(id: '1', titre: 'À finir', priorite: Priority.medium));

    final tache = repo.getById('1');
    tache.terminee = true;
    repo.update(tache);

    final repoRecharge = JsonTaskRepository(filePath: filePath);
    expect(repoRecharge.getById('1').terminee, isTrue);
  });
}
