import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../widgets/search_bar.dart';
import 'note_edit_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final notesProvider = Provider.of<NotesProvider>(context);
    final notes = _searchQuery.isEmpty
        ? notesProvider.notes
        : notesProvider.searchNotes(_searchQuery);

    return Scaffold(
      backgroundColor:
          isDarkMode ? Colors.black : theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          'Notes',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          AppSearchBar(
            onTap: () {
              showSearchDialog(context, onSearch: (query) {
                setState(() {
                  _searchQuery = query;
                });
              });
            },
            hintText: 'Search notes...',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: notes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: theme.cardColor,
                        child: ListTile(
                          title: Text(
                            note.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            note.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                          leading: Icon(
                            Icons.note,
                            color: theme.iconTheme.color,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  note.isPinned
                                      ? Icons.push_pin
                                      : Icons.push_pin_outlined,
                                  color: theme.iconTheme.color,
                                ),
                                onPressed: () {
                                  // Toggle pin status
                                  notesProvider.togglePinNote(note.id);
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: theme.iconTheme.color,
                                ),
                                onPressed: () async {
                                  await notesProvider.deleteNote(note.id);
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NoteEditPage(noteId: note.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.blue : const Color(0xFF1A873E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton(
          heroTag: 'notes_create_note_fab',
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NoteEditPage(),
              ),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_outlined,
            size: 64,
            color: theme.hintColor,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No notes yet\nTap + to create one'
                : 'No notes found for "$_searchQuery"',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
