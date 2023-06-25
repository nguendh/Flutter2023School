import 'package:first_app/core/todo_entity.dart';
import 'package:first_app/pages/create_todo_page.dart';

import 'package:first_app/pages/todo_list_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:first_app/core/todo_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TodoDatabase database = TodoDatabase();
  await database.loadTasks();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    TodoListApp(prefs: prefs),
  );
}

class TodoListApp extends StatelessWidget {
  const TodoListApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo App',
      initialRoute: TodoListPage.route,
      routes: {
        TodoListPage.route: (_) => TodoListPage(prefs: prefs),
        CreateTodoPage.route: (_) =>
            CreateTodoPage(todo: TodoEntity(), newTask: true),
      },
    );
  }
}
