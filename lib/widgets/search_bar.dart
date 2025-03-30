import 'package:evernote/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../providers/tasks_provider.dart';
import '../models/note.dart';
import '../models/task.dart';

class AppSearchBar extends StatelessWidget {
  final VoidCallback onTap;
  final String hintText;

  const AppSearchBar({
    super.key,
    required this.onTap,
    this.hintText = 'Find any note, task or document',
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
        ),
        onTap: onTap,
        readOnly: true,
      ),
    );
  }
}

void showSearchDialog(BuildContext context,
    {required Function(String) onSearch}) {
  showDialog(
    context: context,
    builder: (context) {
      String searchQuery = '';
      return AlertDialog(
        title: const Text('Search'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter search term...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            searchQuery = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onSearch(searchQuery);
            },
            child: const Text('SEARCH'),
          ),
        ],
      );
    },
  );
}

void showFullSearchResults(BuildContext context, String query) {
  final notesProvider = Provider.of<NotesProvider>(context, listen: false);
  final tasksProvider = Provider.of<TasksProvider>(context, listen: false);

  final List<Note> matchedNotes = notesProvider.searchNotes(query);
  final List<Task> matchedTasks = tasksProvider.searchTasks(query);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SearchResultsView(
            query: query,
            notes: matchedNotes,
            tasks: matchedTasks,
            scrollController: scrollController,
          );
        },
      );
    },
  );
}

class SearchResultsView extends StatelessWidget {
  final String query;
  final List<Note> notes;
  final List<Task> tasks;
  final ScrollController scrollController;

  const SearchResultsView({
    super.key,
    required this.query,
    required this.notes,
    required this.tasks,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasNotes = notes.isNotEmpty;
    final bool hasTasks = tasks.isNotEmpty;
    final bool hasResults = hasNotes || hasTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.search, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Results for "$query"',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (!hasResults)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No results found for "$query"',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                if (hasNotes) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...notes.map((note) => _buildNoteItem(context, note)),
                  const SizedBox(height: 24),
                ],
                if (hasTasks) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...tasks.map((task) => _buildTaskItem(context, task)),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNoteItem(BuildContext context, Note note) {
    final truncatedContent = note.content.length > 100
        ? '${note.content.substring(0, 100)}...'
        : note.content;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          note.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          truncatedContent,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        leading: const Icon(Icons.note),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/note-detail', arguments: note.id);
        },
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: task.dueDate != null
            ? Text('Due: ${_formatDate(task.dueDate!)}')
            : null,
        leading: Icon(
          task.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
        ),
        onTap: () {
          Navigator.pop(context);
          final tasksProvider =
              Provider.of<TasksProvider>(context, listen: false);
          tasksProvider.toggleTaskStatus(task.id);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
