import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_to_do_app/model/note.dart';
import 'package:simple_to_do_app/model/task.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white12,
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

  void _showAddNoteDialog() {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        List<TextEditingController> taskControllers = [
          TextEditingController()
        ];

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Note Title'),
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
                      onPressed: () {
                        final title = titleController.text;
                        final tasks = taskControllers.map((value) => Task(title: value.text)).toList();

                        if (title.isNotEmpty && tasks.isNotEmpty) {
                          _addNote(Note(
                            title: title,
                            tasks: tasks,
                            createdAt: DateTime.now(),
                          ));
                        Navigator.pop(context);
                        }
                      },
                      child: const Text('Save Note'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNoteCard(Note note) => Card(
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
              onChanged: (_) => _toggleTask(note, task),
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
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(radius: 16),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: _showAddNoteDialog,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Search notes...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          if (todayNotes.isNotEmpty) ...[
            const Text('Today', style: TextStyle(fontSize: 18)),
            ...todayNotes.map(_buildNoteCard)
          ],
          if (weekNotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Previous Week', style: TextStyle(fontSize: 18)), 
            ...weekNotes.map(_buildNoteCard)
          ],
          if (monthNotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Months Ago', style: TextStyle(fontSize: 18)),
            ...monthNotes.map(_buildNoteCard)
          ]
        ],
      ),
    );
  }
}
