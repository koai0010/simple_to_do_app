import 'dart:convert';

import 'package:simple_to_do_app/model/task.dart';

class Note {
  String title;
  List<Task> tasks;
  DateTime createdAt;

  Note({
    required this.title, 
    required this.tasks,
    required this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
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

  static String encode(List<Note> notes) => json.encode(
    notes.map((note) => note.toJson()).toList(),
  );

  static List<Note> decode(String data) =>
    (json.decode(data) as List)
        .map((item) => Note.fromJson(item))
        .toList();
}