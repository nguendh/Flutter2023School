import 'package:first_app/core/todo_database.dart';
import 'package:first_app/core/todo_entity.dart';
import 'package:first_app/pages/todo_list_page.dart';
import 'package:flutter/material.dart';
import 'package:first_app/common/utils.dart';

class CreateTodoPage extends StatefulWidget {
  static const route = '/add_edit_task_screen';

  final TodoEntity todo;
  final bool newTask;

  const CreateTodoPage({super.key, required this.todo, this.newTask = false});

  @override
  _CreateTodoPageState createState() => _CreateTodoPageState();
}

class _CreateTodoPageState extends State<CreateTodoPage> {
  // Widget important = Text('Нет');
  ImportanceType _selectedItem = ImportanceType.no;
  DateTime? deadline;

  late TextEditingController descriptionTextController;
  final database = TodoDatabase();

  void _saveTask() {
    widget.todo.description = descriptionTextController.text;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: "",
      // locale: const Locale("ru", "RU"),
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != deadline) {
      setState(() {
        deadline = picked;
        widget.todo.deadline = deadline;
        widget.todo.hasDeadline = true;
      });
    }
  }

  @override
  void initState() {
    descriptionTextController = TextEditingController(
      text: widget.todo.description,
    );
    deadline = widget.todo.deadline;
    _selectedItem = widget.todo.important;
    super.initState();
  }

  Text toTextWidget(ImportanceType type) {
    if (type == ImportanceType.no) return const Text("Нет");
    if (type == ImportanceType.low) return const Text("Низкий");
    return Text('!! Высокий',
        style: TextStyle(color: Color(hexStringToHexInt('#FF3B30'))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            backgroundColor: Color(hexStringToHexInt('#F7F6F2')),
            leading: IconButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, TodoListPage.route);
              },
              icon: const Icon(
                Icons.close,
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  _saveTask();
                  if (widget.newTask) {
                    database.addTask(widget.todo);
                  } else {
                    database.modifyTask(widget.todo);
                  }

                  Navigator.popAndPushNamed(context, TodoListPage.route);
                },
                child: const Text(
                  "СОХРАНИТЬ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textScaleFactor: 1.2,
                ),
              )
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            sliver: SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      child: TextField(
                        textAlignVertical: TextAlignVertical.top,
                        maxLines: null,
                        minLines: 5,
                        controller: descriptionTextController,
                        decoration: InputDecoration(
                          hintText: 'Что надо делать...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    PopupMenuButton<ImportanceType>(
                      initialValue: ImportanceType.no,
                      onSelected: (ImportanceType value) {
                        setState(
                          () {
                            _selectedItem = value;
                            widget.todo.important = value;
                          },
                        );
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem<ImportanceType>(
                            value: ImportanceType.no,
                            child: Text('Нет'),
                          ),
                          const PopupMenuItem<ImportanceType>(
                            value: ImportanceType.low,
                            child: Text('Низкий'),
                          ),
                          PopupMenuItem<ImportanceType>(
                            value: ImportanceType.high,
                            child: Text('!! Высокий',
                                style: TextStyle(
                                    color:
                                        Color(hexStringToHexInt('#FF3B30')))),
                          ),
                        ];
                      },
                      child: ListTile(
                        title: const Text('Важность',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                        subtitle: toTextWidget(_selectedItem),
                        trailing: null,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    SwitchListTile(
                      title: const Text('Сделать до',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500)),
                      subtitle: deadline != null
                          ? Text(formatDateTime(deadline!),
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color(hexStringToHexInt('#248dfc'))))
                          : const Text(''),
                      value: widget.todo.hasDeadline,
                      onChanged: (value) {
                        setState(() {
                          widget.todo.hasDeadline = value;
                          if (!value) {
                            deadline = null;
                          } else {
                            _selectDate(context);
                          }
                        });
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 40.0),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: FloatingActionButton.extended(
                        label: Text(
                          'Удалять',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: Color(
                              hexStringToHexInt('#FF3B30'),
                            ),
                          ),
                        ),
                        backgroundColor: Colors.white.withOpacity(1),

                        // <YOUR CODE HERE>
                        onPressed: widget.newTask
                            ? null
                            : () {
                                database.removeTask(widget.todo);
                                Navigator.popAndPushNamed(
                                    context, TodoListPage.route);
                                setState(() {});
                              },
                        icon: Icon(
                          Icons.delete,
                          size: 24.0,
                          color: Color(hexStringToHexInt('#FF3B30')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
