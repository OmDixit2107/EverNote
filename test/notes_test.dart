import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:evernote/models/note.dart';
import 'package:evernote/providers/notes_provider.dart';
import 'package:evernote/pages/notes_page.dart';
import 'package:evernote/pages/note_edit_page.dart';

// Mock NotesProvider for testing
class MockNotesProvider extends ChangeNotifier implements NotesProvider {
  List<Note> _notes = [];
  Set<String> _categories = {'First Notebook', 'Personal', 'Work'};

  @override
  List<Note> get notes => _notes;

  @override
  Set<String> get categories => _categories;

  @override
  List<Note> get pinnedNotes => _notes.where((note) => note.isPinned).toList();

  @override
  List<Note> get unpinnedNotes =>
      _notes.where((note) => !note.isPinned).toList();

  @override
  List<Note> get deletedNotes => [];

  @override
  Future<void> addNote(
      {required String title,
      required String content,
      String? category}) async {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      category: category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPinned: false,
    );
    _notes.add(note);
    notifyListeners();
  }

  @override
  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }

  @override
  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  List<Note> searchNotes(String query) {
    final searchQuery = query.toLowerCase();
    return _notes
        .where((note) =>
            note.title.toLowerCase().contains(searchQuery) ||
            note.content.toLowerCase().contains(searchQuery))
        .toList();
  }

  @override
  Future<void> togglePinNote(String id) async {
    final noteIndex = _notes.indexWhere((note) => note.id == id);
    if (noteIndex != -1) {
      final note = _notes[noteIndex];
      _notes[noteIndex] = note.copyWith(isPinned: !note.isPinned);
      notifyListeners();
    }
  }

  // Additional required methods
  @override
  Future<void> permanentlyDeleteNote(String id) async {
    // Not needed for testing
  }

  @override
  Future<void> emptyTrash() async {
    // Not needed for testing
  }

  @override
  Future<void> restoreNote(String id) async {
    // Not needed for testing
  }

  @override
  Future<void> moveNoteToTrash(String id) async {
    // Not needed for testing
  }

  @override
  List<Note> get trashedNotes => [];
}

void main() {
  // Mock setup
  late MockNotesProvider mockNotesProvider;

  setUp(() {
    mockNotesProvider = MockNotesProvider();
  });

  // Test group 1: NotesProvider Unit Tests
  group('NotesProvider Tests', () {
    test('should add a new note', () async {
      // Arrange
      expect(mockNotesProvider.notes.length, 0);

      // Act
      await mockNotesProvider.addNote(
          title: 'Test Note', content: 'This is a test note');

      // Assert
      expect(mockNotesProvider.notes.length, 1);
      expect(mockNotesProvider.notes[0].title, 'Test Note');
      expect(mockNotesProvider.notes[0].content, 'This is a test note');
    });

    test('should update an existing note', () async {
      // Arrange
      await mockNotesProvider.addNote(
          title: 'Original Title', content: 'Original Content');
      final originalNote = mockNotesProvider.notes[0];

      // Act
      final updatedNote = originalNote.copyWith(
          title: 'Updated Title', content: 'Updated Content');
      await mockNotesProvider.updateNote(updatedNote);

      // Assert
      expect(mockNotesProvider.notes.length, 1);
      expect(mockNotesProvider.notes[0].title, 'Updated Title');
      expect(mockNotesProvider.notes[0].content, 'Updated Content');
    });

    test('should delete a note', () async {
      // Arrange
      await mockNotesProvider.addNote(
          title: 'Note to Delete', content: 'This note will be deleted');
      final noteId = mockNotesProvider.notes[0].id;
      expect(mockNotesProvider.notes.length, 1);

      // Act
      await mockNotesProvider.deleteNote(noteId);

      // Assert
      expect(mockNotesProvider.notes.length, 0);
    });

    test('should search notes correctly', () async {
      // Arrange
      await mockNotesProvider.addNote(
          title: 'Flutter Notes', content: 'Learning Flutter is fun');
      await mockNotesProvider.addNote(
          title: 'Dart Programming',
          content: 'Dart is the language used in Flutter');
      await mockNotesProvider.addNote(
          title: 'Shopping List', content: 'Milk, Eggs, Bread');

      // Act & Assert
      expect(mockNotesProvider.searchNotes('Flutter').length, 2);
      expect(mockNotesProvider.searchNotes('Shopping').length, 1);
      expect(mockNotesProvider.searchNotes('Java').length, 0);
    });

    test('should toggle note pin status', () async {
      // Arrange
      await mockNotesProvider.addNote(
          title: 'Pin Test Note', content: 'This note will be pinned');
      final noteId = mockNotesProvider.notes[0].id;
      expect(mockNotesProvider.notes[0].isPinned, false);

      // Act
      await mockNotesProvider.togglePinNote(noteId);

      // Assert
      expect(mockNotesProvider.notes[0].isPinned, true);

      // Act again
      await mockNotesProvider.togglePinNote(noteId);

      // Assert again
      expect(mockNotesProvider.notes[0].isPinned, false);
    });

    test('should handle non-existent note ID gracefully', () {
      // Act & Assert
      expect(mockNotesProvider.getNoteById('non-existent-id'), null);
    });
  });

  // Test group 2: Widget tests for the UI
  group('Notes UI Tests', () {
    testWidgets('NoteEditPage should allow creating a new note',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<NotesProvider>.value(
            value: mockNotesProvider,
            child: const NoteEditPage(),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField).first, 'New Note Title');
      await tester.enterText(find.byType(TextField).last, 'New Note Content');

      // Find and tap the save button (check icon)
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Assert
      expect(mockNotesProvider.notes.length, 1);
      expect(mockNotesProvider.notes[0].title, 'New Note Title');
      expect(mockNotesProvider.notes[0].content, 'New Note Content');
    });
  });
}
