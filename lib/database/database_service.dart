import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqlite_todo/database/todo_db.dart';

class DatabaseService{
  //can hold Database obj or can be null
  Database? _database;

  //getter for database
  Future<Database> get database async {
    if(_database != null) {
      return _database!;
    }
    else {
    _database = await _initialize();
    return _database!;
    }
  }

  //helper function to get path of database
  Future<String> get fullPath async{
    const name = 'todo.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  Future<Database> _initialize() async {
    final path = await fullPath;
    final database = await openDatabase(
      path,
      version: 1,
      onCreate: create,
      singleInstance: true,
    );
    return database;
  }

  //create table in database
  Future<void> create(Database database, int version) async => 
    await TodoDB().createTable(database);
}