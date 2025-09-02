# Flutter To-Do App

[![Flutter](https://img.shields.io/badge/Flutter-3.35.2-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.0-blue?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A simple and minimalist **to-do list-app** built with **Flutter**.
This project is designed to demonstrates clean UI and local persistences.

## ✨ Features

- ➕ Add new todos  
- ✏️ Edit todos  
- ❌ Delete todos (with confirmation dialog + snackbar feedback)  
- 📌 Mark todos as done
- 💾 Persistent storage with `SharedPreferences`

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.x)  
- Dart (>=3.x)  
- Android Studio / VS Code with Flutter plugin  
- Emulator or physical device

### Installation

1. Clone the repo:
   ```bash
   git clone https://github.com/your-username/flutter-todo-app.git
   cd flutter-todo-app

2. Install dependencies:
   ```bash
   flutter pub get
   
3. Run the app:
   ```bash
   flutter run

## 🏗 Project Structure
lib/
├── model/
│   ├── task.dart
│   └── todo.dart
│
├── ui/
│   ├── detail/
│   │   └── detail_screen.dart
│   │
│   └── home/
│       ├── components/
│       │   └── todo_card.dart
│       │
│       └── home_screen.dart
│
└── main.dart
