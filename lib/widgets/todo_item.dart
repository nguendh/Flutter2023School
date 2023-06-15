import 'package:first_app/core/todo_database.dart';
import 'package:first_app/core/todo_entity.dart';
import 'package:flutter/material.dart';

import 'package:first_app/pages/create_todo_page.dart';
import 'package:first_app/common/utils.dart';

class TodoItem extends StatefulWidget {
  final TodoEntity todo;
  final bool showCompletedState;

  const TodoItem({
    Key? key,
    required this.todo,
    required this.showCompletedState,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  final database = TodoDatabase();

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.todo.id.toString()),
      secondaryBackground: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
      ),
      background: Container(
        color: Colors.green,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          /// Delete
          setState(
            () {
              database.removeTask(widget.todo);
            },
          );
          return true;
        } else {
          /// Complete
          setState(
            () {
              database.modifyTask(widget.todo, completed: true);
            },
          );
          if (widget.showCompletedState) return false;
          return true;
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: ListTile(
          title: Row(
            verticalDirection: VerticalDirection.up,
            children: [
              if (widget.todo.important == ImportanceType.high) ...[
                const Text(' !!  ',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    widget.todo.description,
                    maxLines: 3,
                    style: widget.todo.completed
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey)
                        : null,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (widget.todo.important == ImportanceType.low) ...[
                const Icon(Icons.arrow_downward),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    widget.todo.description,
                    maxLines: 3,
                    style: widget.todo.completed
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey)
                        : null,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (widget.todo.important == ImportanceType.no) ...[
                Text(
                  widget.todo.description,
                  maxLines: 3,
                  style: widget.todo.completed
                      ? const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey)
                      : null,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          subtitle: widget.todo.deadline != null
              ? Text(formatDateTime(widget.todo.deadline!),
                  style: TextStyle(
                      fontSize: 15, color: Color(hexStringToHexInt('#248dfc'))))
              : const Text(''),
          leading: Checkbox(
            side: widget.todo.important == ImportanceType.high
                ? MaterialStateBorderSide.resolveWith(
                    (states) => const BorderSide(color: Colors.red, width: 2),
                  )
                : null,
            fillColor: widget.todo.important == ImportanceType.high
                ? MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return null;
                    }
                    return Color(hexStringToHexInt("#FFE4E1"));
                  })
                : null,
            activeColor: widget.todo.important == ImportanceType.high
                ? Colors.red
                : Colors.green,
            value: widget.todo.completed,
            onChanged: (bool? value) {
              setState(() {
                database.modifyTask(widget.todo, completed: value);
              });
            },
          ),
          trailing: IconButton(
            onPressed: () async {
              final _ = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return CreateTodoPage(todo: widget.todo);
                  },
                ),
              );
            },
            icon: const Icon(
              Icons.info_outline,
            ),
          ),
        ),
      ),
    );
  }
}
