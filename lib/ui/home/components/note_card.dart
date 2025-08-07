import 'package:flutter/material.dart';
import 'package:simple_to_do_app/model/note.dart';
import 'package:simple_to_do_app/model/task.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final void Function(Task task) onToggle;

  const NoteCard({super.key, required this.note, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...note.tasks.map(
              (task) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: task.isCompleted,
                onChanged: (_) => onToggle(task),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
