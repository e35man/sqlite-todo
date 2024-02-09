import 'package:flutter/material.dart';
import 'package:sqlite_todo/database/todo_db.dart';
import 'package:sqlite_todo/model/todo.dart';
import 'package:sqlite_todo/widget/create_todo_widget.dart';
import 'package:intl/intl.dart';


class TodosPage extends StatefulWidget{
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  Future<List<Todo>>? futureTodos;
  final todoDB = TodoDB();

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  void fetchTodos() {
    setState(() {
      futureTodos = todoDB.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('ToDo List'),
    ),
    body: FutureBuilder<List<Todo>>(
      future: futureTodos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          final todos = snapshot.data!;
          return todos.isEmpty?
            const Center(
              child: Text('No Todos..')
            )
            :ListView.separated(
              separatorBuilder: (context, index) => 
                const SizedBox(height: 12),
                itemCount: todos.length,
                itemBuilder: (context, index){
                  final todo = todos[index];
                  final subtitle = DateFormat('yyyy/MM/dd').format(
                    DateTime.parse(todo.updatedAt ?? todo.createdAt)
                  );
                  return ListTile(
                    title: Text(todo.title),
                    subtitle: Text(subtitle),
                    trailing: IconButton(
                      onPressed: () async {
                        await todoDB.delete(todo.id);
                        fetchTodos();
                      },
                      icon: const Icon(Icons.delete),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => CreateToDoWidget(
                          todo: todo,
                          onSubmit: (title) async {
                            int count = await todoDB.update(todo.id, todo.title);
                            debugPrint("changes made: $count");
                            fetchTodos();
                            if(!mounted) return;
                            Navigator.of(context).pop();
                          }
                        )
                      );
                    },
                  );
                },
            );
        }
      }
    ),
    floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        showDialog(
        context: context,
        builder: (_) => CreateToDoWidget(
          onSubmit: (title) async {
            await todoDB.create(title: title);
            if(!mounted) return;
            fetchTodos();
            Navigator.of(context).pop();
          }
        )
        );
      }
    ),
  );
}