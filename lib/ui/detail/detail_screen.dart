import 'package:flutter/material.dart';
import 'package:simple_to_do_app/model/note.dart';
import 'package:simple_to_do_app/model/task.dart';

class DetailScreen extends StatefulWidget {
  final Note note;
  final void Function(Note updatedNote) onSave;
  const DetailScreen({required this.note, required this.onSave, super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController titleController;
  late List<TextEditingController> taskControllers;
  late List<bool> taskCompletedStatus;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.note.title);

    taskControllers = widget.note.tasks
        .map((task) => TextEditingController(text: task.title))
        .toList();

    taskCompletedStatus = widget.note.tasks
        .map((task) => task.isCompleted)
        .toList();
  }

  @override
  void dispose() {
    titleController.dispose();
    for (var i in taskControllers) {
      i.dispose();
    }
    super.dispose();
  }

  void _addTaskField() {
    setState(() {
      taskControllers.add(TextEditingController());
      taskCompletedStatus.add(false);
    });
  }

  void _removeTaskField(int index) {
    setState(() {
      taskControllers.removeAt(index);
      taskCompletedStatus.removeAt(index);
    });
  }

  void _updateNote() {
    final updatedTasks = List.generate(
      taskControllers.length,
      (index) => Task(
        title: taskControllers[index].text.trim(),
        isCompleted: taskCompletedStatus[index],
      ),
    ).where((value) => value.title.isNotEmpty).toList();

    final updatedNote = Note(
      title: titleController.text.trim(),
      tasks: updatedTasks,
      createdAt: widget.note.createdAt,
    );

    widget.onSave(updatedNote);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Note"),
        actions: [IconButton(onPressed: _updateNote, icon: Icon(Icons.save))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              itemCount: taskControllers.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextField(
                          controller: taskControllers[index],
                          decoration: const InputDecoration(labelText: "Task"),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeTaskField(index),
                    ),
                  ],
                );
              },
            ),
            TextButton.icon(
              onPressed: _addTaskField,
              icon: const Icon(Icons.add),
              label: const Text("Add Task"),
            ),
          ],
        ),
      ),
    );
  }
}
