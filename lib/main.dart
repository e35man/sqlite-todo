import 'package:flutter/material.dart';
import 'package:sqlite_todo/pages/todos_pages.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TodosPage()
    );
  }
}
