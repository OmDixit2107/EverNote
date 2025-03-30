import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';

class NotesProvider with ChangeNotifier {
  static const String _boxName = 'notes';
  final _uuid = const Uuid();
  Box<Note>? _box;
  List<Note> _notes = [];

  List<Note> get notes => _notes.where((note) => !note.isDeleted).toList();
  List<Note> get deletedNotes =>
      _notes.where((note) => note.isDeleted).toList();

  NotesProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      _box = await Hive.openBox<Note>(_boxName);
      _loadNotes();
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
    }
  }

  void _loadNotes() {
    if (_box != null) {
      _notes = _box!.values.toList();
      notifyListeners();
    }
  }

  Future<void> _saveNotes() async {
    if (_box != null) {
      await _box!.clear();
      await _box!.addAll(_notes);
    }
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addNote({
    required String title,
    required String content,
    String? category,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      category: category,
    );

    _notes.add(note);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      await _saveNotes();
      notifyListeners();
    }
  }

  Future<void> togglePinNote(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      final note = _notes[index];
      _notes[index] = note.copyWith(isPinned: !note.isPinned);
      await _saveNotes();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(isDeleted: true);
      await _saveNotes();
      notifyListeners();
    }
  }

  Future<void> restoreNote(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(isDeleted: false);
      await _saveNotes();
      notifyListeners();
    }
  }

  Future<void> permanentlyDeleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> emptyTrash() async {
    _notes.removeWhere((note) => note.isDeleted);
    await _saveNotes();
    notifyListeners();
  }

  List<Note> searchNotes(String query) {
    final lowercaseQuery = query.toLowerCase();
    return notes.where((note) {
      return note.title.toLowerCase().contains(lowercaseQuery) ||
          note.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Set<String> get categories {
    return notes
        .where((note) => note.category != null)
        .map((note) => note.category!)
        .toSet();
  }

  List<Note> get pinnedNotes => notes.where((note) => note.isPinned).toList();
  List<Note> get unpinnedNotes =>
      notes.where((note) => !note.isPinned).toList();
}
