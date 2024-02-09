import 'package:sqflite/sqflite.dart';
import 'package:sqlite_todo/database/database_service.dart';
import 'package:sqlite_todo/model/todo.dart';

class TodoDB {
  final tableName = 'todos';

  //
  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName(
      "id" INTEGER NOT NULL,
      "title" TEXT NOT NULL,
      "created_at" INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as int)),
      "updated_at" INTEGER,
      PRIMARY KEY("id" AUTOINCREMENT)
    );""");
  }

  Future<int> create({required String title}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (title, created_at) VALUES (?,?)''',
      [title, DateTime.now().millisecondsSinceEpoch],
    );
  }

  Future<List<Todo>> fetchAll() async {
    final database = await DatabaseService().database;
    final todos = await database.rawQuery(
      '''SELECT * from $tableName ORDER BY COALESCE(updated_at,created_at);'''
    );
    return todos.map((todo) => Todo.fromSqfliteDatabase(todo)).toList();
  }

  Future<Todo> fetchById(int id) async {
    final database = await DatabaseService().database;
    final todo = await database
      .rawQuery('''SELECT * from $tableName WHERE id = ?''', [id]);
    return Todo.fromSqfliteDatabase(todo.first);
  }

  Future<int> delete(int id) async {
    final database = await DatabaseService().database;
    final int changes = await database.rawDelete('''DELETE from $tableName WHERE id = ?''', [id]);
    return changes;
  }

  //needs debugging
  Future<int> update(int id, String? title) async {
    try {
      final database = await DatabaseService().database;
      int count =await database.rawUpdate('''UPDATE $tableName SET title = ? WHERE id = ?''', [title, id]);
      print('Update successful');
      return count;
    } catch (e) {
      print('Error updating title: $e');
    }
    return 0;
  }
}
