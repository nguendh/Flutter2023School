import 'dart:math';

import 'package:first_app/common/utils.dart';
import 'package:first_app/core/todo_database.dart';
import 'package:first_app/pages/create_todo_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/todo_entity.dart';
import '../widgets/todo_item.dart';
// import 'create_todo_page.dart';

class TodoListPage extends StatefulWidget {
  static const String route = '/TodoListPage';

  final SharedPreferences prefs;

  const TodoListPage({
    Key? key,
    required this.prefs,
  }) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0;

  final database = TodoDatabase();
  late bool _showCompleteTasks = true;
  late List<TodoEntity> tasks;

  _scrollListener() {
    setState(() {
      _scrollPosition = _scrollController.position.pixels;
    });
  }

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    tasks = _showCompleteTasks ? database.tasks : database.uncompletedTasks;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverPersistentHeader(
            pinned: true,
            delegate: _AppBarDelegate(
              database: database,
              scrollPosition: _scrollPosition,
              showCompleted: _showCompleteTasks,
              onPressed: () {
                setState(() {
                  _showCompleteTasks = !_showCompleteTasks;
                  if (_showCompleteTasks) {
                    tasks = database.tasks;
                  } else {
                    tasks = database.uncompletedTasks;
                  }
                });
              },
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return TodoItem(
                  todo: tasks[index],
                  showCompletedState: _showCompleteTasks,
                );
              },
              childCount: tasks.length,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: TextButton(
                  onPressed: () async {
                    Navigator.popAndPushNamed(context, CreateTodoPage.route);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 57),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Новое',
                            style: TextStyle(
                              color: Color(
                                hexStringToHexInt('#D1D1D6'),
                              ),
                            ),
                          ),
                        ]),
                  ),
                ),
              )
            ]),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.popAndPushNamed(context, CreateTodoPage.route);
        },
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AppBarDelegate extends SliverPersistentHeaderDelegate {
  final double scrollPosition;
  final bool showCompleted;

  final TodoDatabase database;
  final VoidCallback onPressed;

  _AppBarDelegate({
    required this.database,
    required this.scrollPosition,
    required this.showCompleted,
    required this.onPressed,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return StreamBuilder<int>(
      stream: database.completedStream,
      builder: (context, snapshot) {
        final completedTask = snapshot.data ?? 0;
        return Stack(
          children: [
            Container(
              color: Color(hexStringToHexInt('#F7F6F2')),
              padding: EdgeInsets.only(left: max(75 - scrollPosition, 10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 0),
                    title: Text(
                      'Мои дела'.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                      ),
                    ),
                    subtitle: scrollPosition != 0
                        ? null
                        : Text(
                            'Выполнено - $completedTask',
                            style: TextStyle(
                              color: Color(hexStringToHexInt('#D1D1D6')),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                onPressed: onPressed,
                icon: showCompleted
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off),
                color: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  double get maxExtent => 160.0;

  @override
  double get minExtent => 80.0;

  @override
  bool shouldRebuild(_AppBarDelegate oldDelegate) {
    return true;
  }
}
