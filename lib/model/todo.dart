import 'dart:convert';

import 'package:simple_to_do_app/model/task.dart';

class Todo {
  String title;
  List<Task> tasks;
  DateTime createdAt;

  Todo({
    required this.title, 
    required this.tasks,
    required this.createdAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    title: json['title'],
    tasks: (json['tasks'] as List)
        .map((task) => Task.fromJson(task))
        .toList(),
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'tasks': tasks.map((task) => task.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  static String encode(List<Todo> todos) => json.encode(
    todos.map((todo) => todo.toJson()).toList(),
  );

  static List<Todo> decode(String data) =>
    (json.decode(data) as List)
        .map((item) => Todo.fromJson(item))
        .toList();
}