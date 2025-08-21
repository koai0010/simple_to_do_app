import 'package:flutter/material.dart';
import 'package:simple_to_do_app/model/todo.dart';
import 'package:simple_to_do_app/model/task.dart';

class DetailScreen extends StatefulWidget {
  final Todo todo;
  final void Function(Todo updatedTodo) onSave;
  const DetailScreen({required this.todo, required this.onSave, super.key});

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

    titleController = TextEditingController(text: widget.todo.title);

    taskControllers = widget.todo.tasks
        .map((task) => TextEditingController(text: task.title))
        .toList();

    taskCompletedStatus = widget.todo.tasks
        .map((task) => task.isCompleted)
        .toList();
  }

  @override
  void dispose() {
    titleController.dispose();
    for (var controller in taskControllers) {
      controller.dispose();
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

  void _updateTodo() {
    final updatedTasks = List.generate(
      taskControllers.length,
      (index) => Task(
        title: taskControllers[index].text.trim(),
        isCompleted: taskCompletedStatus[index],
      ),
    ).where((value) => value.title.isNotEmpty).toList();

    final updatedTodo = Todo(
      title: titleController.text.trim(),
      tasks: updatedTasks,
      createdAt: widget.todo.createdAt,
    );

    widget.onSave(updatedTodo);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Todo"),
        actions: [IconButton(onPressed: _updateTodo, icon: Icon(Icons.save))],
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
