import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';

class TasksProvider with ChangeNotifier {
  static const String _boxName = 'tasks';
  final _uuid = const Uuid();
  Box<Task>? _box;
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks.where((task) => !task.isDeleted).toList();
  List<Task> get deletedTasks =>
      _tasks.where((task) => task.isDeleted).toList();

  TasksProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      _box = await Hive.openBox<Task>(_boxName);
      _loadTasks();
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
    }
  }

  void _loadTasks() {
    if (_box != null) {
      _tasks = _box!.values.toList();
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    if (_box != null) {
      await _box!.clear();
      await _box!.addAll(_tasks);
    }
  }

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    final now = DateTime.now();
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      createdAt: now,
      updatedAt: now,
      dueDate: dueDate,
    );

    _tasks.add(task);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> toggleTaskStatus(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isDeleted: true);
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> restoreTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isDeleted: false);
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> permanentlyDeleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> emptyTrash() async {
    _tasks.removeWhere((task) => task.isDeleted);
    await _saveTasks();
    notifyListeners();
  }

  List<Task> searchTasks(String query) {
    final lowercaseQuery = query.toLowerCase();
    return tasks.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery) ||
          (task.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  List<Task> get completedTasks =>
      tasks.where((task) => task.isCompleted).toList();
  List<Task> get incompleteTasks =>
      tasks.where((task) => !task.isCompleted).toList();

  // Get tasks with due date
  List<Task> getDueTasksForDate(DateTime date) {
    return tasks
        .where((task) =>
            task.dueDate != null &&
            task.dueDate!.year == date.year &&
            task.dueDate!.month == date.month &&
            task.dueDate!.day == date.day)
        .toList();
  }
}
