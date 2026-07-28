/// Interface générique définissant les opérations CRUD de base
/// pour n'importe quel type d'entité [T] possédant un identifiant.
abstract class Repository<T> {
  void add(T item);
  void remove(String id);
  T getById(String id);
  List<T> getAll();
  void update(T item);
}
