import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_to_do_app/model/note.dart';
import 'package:simple_to_do_app/model/task.dart';
import 'package:simple_to_do_app/ui/detail/detail_screen.dart';
import 'package:simple_to_do_app/ui/home/components/todo_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      debugShowCheckedModeBanner: kDebugMode,
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
      ),
      home: const TodoHome(),
    );
  }
}

class TodoHome extends StatefulWidget {
  const TodoHome({super.key});

  @override
  State<TodoHome> createState() => _TodoHomeState();
}

class _TodoHomeState extends State<TodoHome> {
  List<Note> _notes = [];
  final titleController = TextEditingController();
  final taskController = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _loadNotes();
    taskController.add(TextEditingController());
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notes');

    if (data != null) {
      setState(() {
        _notes = Note.decode(data);
      });
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', Note.encode(_notes));
  }

  void _addNote(Note note) {
    setState(() {
      _notes.insert(0, note);
    });
    _saveNotes();
  }

  void _toggleTask(Note note, Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
    _saveNotes();
  }

  Future<void> _deleteNote(Note note) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Todo'),
          content: const Text('Are you sure you want to delete this todo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _notes.remove(note);
                });
                _saveNotes();
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  List<Note> _filterNotes(Duration range) {
    final now = DateTime.now();
    return _notes
        .where((note) => now.difference(note.createdAt) <= range)
        .toList();
  }

  List<Note> _filterOlder(Duration minRange) {
    final now = DateTime.now();
    return _notes
        .where((note) => now.difference(note.createdAt) > minRange)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final todayNotes = _filterNotes(const Duration(days: 1));
    final weekNotes = _filterNotes(const Duration(days: 7))
        .where(
          (value) => !_filterNotes(const Duration(days: 1)).contains(value),
        )
        .toList();
    final monthNotes = _filterOlder(const Duration(days: 7));

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 32,
          left: 24,
          right: 24,
          bottom: 24,
        ),
        children: [
          Text(
            'TO-DO',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Color(0xFF414141),
            ),
          ),
          Divider(color: Colors.grey[500]),
          const SizedBox(height: 8),
          if (todayNotes.isNotEmpty) ...[
            const Text(
              'Today',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            ...todayNotes.map(
              (note) => InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(
                        note: note,
                        onSave: (update) {
                          setState(() {
                            final index = _notes.indexOf(note);
                            _notes[index] = update;
                          });
                          _saveNotes();
                        },
                      ),
                    ),
                  );
                },
                child: TodoCard(
                  note: note,
                  onToggle: (task) => _toggleTask(note, task),
                  onDelete: () => _deleteNote(note),
                ),
              ),
            ),
          ],
          if (weekNotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Previous Week',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            ...weekNotes.map(
              (note) => InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(
                        note: note,
                        onSave: (update) {
                          setState(() {
                            final index = _notes.indexOf(note);
                            _notes[index] = update;
                          });
                          _saveNotes();
                        },
                      ),
                    ),
                  );
                },
                child: TodoCard(
                  note: note,
                  onToggle: (task) => _toggleTask(note, task),
                  onDelete: () => _deleteNote(note),
                ),
              ),
            ),
          ],
          if (monthNotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Months Ago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            ...monthNotes.map(
              (note) => InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(
                        note: note,
                        onSave: (update) {
                          setState(() {
                            final index = _notes.indexOf(note);
                            _notes[index] = update;
                          });
                          _saveNotes();
                        },
                      ),
                    ),
                  );
                },
                child: TodoCard(
                  note: note,
                  onToggle: (task) => _toggleTask(note, task),
                  onDelete: () => _deleteNote(note),
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          titleController.clear();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              List<TextEditingController> taskControllers = [
                TextEditingController(),
              ];

              return StatefulBuilder(
                builder: (context, setModalState) {
                  return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: 48,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 4,
                                margin: const EdgeInsets.only(top: 24, bottom: 48),
                                decoration: BoxDecoration(
                                  color: Colors.grey[600],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Add Todo',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF414141),
                                ),
                              ),
                              Container(
                                width: 200,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...taskControllers.map((controller) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: TextField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                      labelText: 'Task',
                                    ),
                                  ),
                                );
                              }),
                              TextButton.icon(
                                onPressed: () {
                                  setModalState(() {
                                    taskControllers.add(TextEditingController());
                                  });
                                },
                                icon: const Icon(Icons.add),
                                label: const Text("Add Task"),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                onPressed: () {
                                  final title = titleController.text;
                                  final tasks = taskControllers
                                      .map((value) => Task(title: value.text))
                                      .toList();
                          
                                  log(
                                    'Adding note with title: $title and tasks: ${tasks.map((task) => task.title).join(', ')}',
                                  );
                          
                                  if (title.isNotEmpty && tasks.isNotEmpty) {
                                    _addNote(
                                      Note(
                                        title: title,
                                        tasks: tasks,
                                        createdAt: DateTime.now(),
                                      ),
                                    );
                                    Navigator.pop(context);
                                    titleController.clear();
                                    taskControllers.removeRange(
                                      1,
                                      taskControllers.length,
                                    );
                                    taskControllers[0].clear();
                                  }
                                },
                                child: const Text('Save Todo'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
