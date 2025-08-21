import 'package:flutter/material.dart';
import 'package:simple_to_do_app/model/todo.dart';
import 'package:simple_to_do_app/model/task.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final void Function(Task task) onToggle;
  final Future<void> Function() onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      color: const Color(0xFFEBF0FF),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Expanded(
                child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  todo.title,
                  style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async => await onDelete(),
              ),
              ],
            ),
            ...todo.tasks.map(
              (task) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: task.isCompleted,
              onChanged: (_) => onToggle(task),
              title: Text(
                task.title,
                style: TextStyle(
                fontSize: 16,
                color: task.isCompleted ? Colors.grey : Colors.black,
                decoration: task.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
                ),
              ),
              dense: true,
              visualDensity: VisualDensity(vertical: -2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
