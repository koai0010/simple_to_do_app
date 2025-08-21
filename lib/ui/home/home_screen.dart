import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_to_do_app/model/todo.dart';
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
  List<Todo> _todos = [];
  final titleController = TextEditingController();
  final taskController = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _loadTodos();
    taskController.add(TextEditingController());
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('todos');

    if (data != null) {
      setState(() {
        _todos = Todo.decode(data);
      });
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('todos', Todo.encode(_todos));
  }

  void _addTodo(Todo todo) {
    setState(() {
      _todos.insert(0, todo);
    });
    _saveTodos();
  }

  void _toggleTask(Todo todo, Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
    _saveTodos();
  }

  Future<void> _deleteTodo(Todo todo) {
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
                  _todos.remove(todo);
                });
                _saveTodos();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Todo removed from your list.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  List<Todo> _filterTodos(Duration range) {
    final now = DateTime.now();
    return _todos
        .where((todo) => now.difference(todo.createdAt) <= range)
        .toList();
  }

  List<Todo> _filterOlder(Duration minRange) {
    final now = DateTime.now();
    return _todos
        .where((todo) => now.difference(todo.createdAt) > minRange)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final todayTodos = _filterTodos(const Duration(days: 1));
    final weekTodos = _filterTodos(const Duration(days: 7))
        .where(
          (value) => !_filterTodos(const Duration(days: 1)).contains(value),
        )
        .toList();
    final monthTodos = _filterOlder(const Duration(days: 7));

    return Scaffold(
      body: _todos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/background_no_data.png',
                    height: 200,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Start organizing your day! \nPress the ➕ button to create a new to-do.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ) 
            : ListView(
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
                if (todayTodos.isNotEmpty) ...[
                  const Text(
                    'Today',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  ...todayTodos.map(
                    (todo) => InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              todo: todo,
                              onSave: (update) {
                                setState(() {
                                  final index = _todos.indexOf(todo);
                                  _todos[index] = update;
                                });
                                _saveTodos();
                              },
                            ),
                          ),
                        );
                      },
                      child: TodoCard(
                        todo: todo,
                        onToggle: (task) => _toggleTask(todo, task),
                        onDelete: () => _deleteTodo(todo),
                      ),
                    ),
                  ),
                ],
                if (weekTodos.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Previous Week',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  ...weekTodos.map(
                    (todo) => InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              todo: todo,
                              onSave: (update) {
                                setState(() {
                                  final index = _todos.indexOf(todo);
                                  _todos[index] = update;
                                });
                                _saveTodos();
                              },
                            ),
                          ),
                        );
                      },
                      child: TodoCard(
                        todo: todo,
                        onToggle: (task) => _toggleTask(todo, task),
                        onDelete: () => _deleteTodo(todo),
                      ),
                    ),
                  ),
                ],
                if (monthTodos.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Months Ago',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  ...monthTodos.map(
                    (todo) => InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              todo: todo,
                              onSave: (update) {
                                setState(() {
                                  final index = _todos.indexOf(todo);
                                  _todos[index] = update;
                                });
                                _saveTodos();
                              },
                            ),
                          ),
                        );
                      },
                      child: TodoCard(
                        todo: todo,
                        onToggle: (task) => _toggleTask(todo, task),
                        onDelete: () => _deleteTodo(todo),
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
                                margin: const EdgeInsets.only(
                                  top: 24,
                                  bottom: 48,
                                ),
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
                                    taskControllers.add(
                                      TextEditingController(),
                                    );
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
                                    'Adding todo with title: $title and tasks: ${tasks.map((task) => task.title).join(', ')}',
                                  );

                                  if (title.isNotEmpty && tasks.isNotEmpty) {
                                    _addTodo(
                                      Todo(
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Todo added successfully',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.green[400],
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
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
