import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';
import '../models/task.dart';

class StorageService {
  static const String notesBoxName = 'notes';
  static const String tasksBoxName = 'tasks';

  late Box<String> _notesBox;
  late Box<String> _tasksBox;

  // Initialize Hive and open boxes
  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    _notesBox = await Hive.openBox<String>(notesBoxName);
    _tasksBox = await Hive.openBox<String>(tasksBoxName);
  }

  // Notes methods
  List<Note> getAllNotes() {
    final noteJsonStrings = _notesBox.values.toList();
    return noteJsonStrings
        .map((jsonStr) => Note.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  Future<void> saveNote(Note note) async {
    await _notesBox.put(note.id, jsonEncode(note.toJson()));
  }

  Future<void> saveAllNotes(List<Note> notes) async {
    final notesMap = {
      for (var note in notes) note.id: jsonEncode(note.toJson())
    };
    await _notesBox.putAll(notesMap);
  }

  Future<void> deleteNotesPermanently(List<String> ids) async {
    await _notesBox.deleteAll(ids);
  }

  // Tasks methods
  List<Task> getAllTasks() {
    final taskJsonStrings = _tasksBox.values.toList();
    return taskJsonStrings
        .map((jsonStr) => Task.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  Future<void> saveTask(Task task) async {
    await _tasksBox.put(task.id, jsonEncode(task.toJson()));
  }

  Future<void> saveAllTasks(List<Task> tasks) async {
    final tasksMap = {
      for (var task in tasks) task.id: jsonEncode(task.toJson())
    };
    await _tasksBox.putAll(tasksMap);
  }

  Future<void> deleteTasksPermanently(List<String> ids) async {
    await _tasksBox.deleteAll(ids);
  }

  // Close boxes when app is closed
  Future<void> close() async {
    await _notesBox.close();
    await _tasksBox.close();
  }
}
