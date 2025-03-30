import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';

class NoteEditPage extends StatefulWidget {
  final String? noteId;

  const NoteEditPage({super.key, this.noteId});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _titleFocus = FocusNode();
  final _contentFocus = FocusNode();
  String? _selectedNotebook;
  bool _isLoading = true;
  Note? _note;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;

  @override
  void initState() {
    super.initState();
    _loadNote();

    // Auto-focus on title for new notes
    if (widget.noteId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _titleFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    if (widget.noteId != null) {
      final notesProvider = Provider.of<NotesProvider>(context, listen: false);
      final note = notesProvider.getNoteById(widget.noteId!);
      if (note != null) {
        setState(() {
          _note = note;
          _titleController.text = note.title;
          _contentController.text = note.content;
          _selectedNotebook = note.category;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    try {
      if (_note != null) {
        final updatedNote = _note!.copyWith(
          title: title.isEmpty ? 'Untitled' : title,
          content: content,
          category: _selectedNotebook,
        );
        await notesProvider.updateNote(updatedNote);
      } else {
        await notesProvider.addNote(
          title: title.isEmpty ? 'Untitled' : title,
          content: content,
          category: _selectedNotebook,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_note != null ? 'Note updated' : 'Note created'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving note'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleFormat(String format) {
    setState(() {
      switch (format) {
        case 'bold':
          _isBold = !_isBold;
          break;
        case 'italic':
          _isItalic = !_isItalic;
          break;
        case 'underline':
          _isUnderline = !_isUnderline;
          break;
      }
    });
  }

  Widget _buildFormatButton({
    required IconData icon,
    bool isSelected = false,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : theme.iconTheme.color,
        size: 20,
      ),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, maxWidth: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => _saveNote(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _saveNote(),
            icon: Icon(Icons.check, color: theme.iconTheme.color),
            label: Text(
              'Save',
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Notebook selector
                InkWell(
                  onTap: () {
                    // Show notebook selection
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 20,
                          color: theme.iconTheme.color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedNotebook ?? 'First Notebook',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: theme.iconTheme.color,
                        ),
                      ],
                    ),
                  ),
                ),

                // Title field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _titleController,
                    focusNode: _titleFocus,
                    style: theme.textTheme.headlineSmall,
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.hintColor,
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) {
                      _contentFocus.requestFocus();
                    },
                  ),
                ),

                // Formatting toolbar
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : Colors.grey[100],
                    border: Border(
                      top: BorderSide(color: theme.dividerColor),
                      bottom: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        _buildFormatButton(
                          icon: Icons.format_bold,
                          isSelected: _isBold,
                          onPressed: () => _toggleFormat('bold'),
                        ),
                        _buildFormatButton(
                          icon: Icons.format_italic,
                          isSelected: _isItalic,
                          onPressed: () => _toggleFormat('italic'),
                        ),
                        _buildFormatButton(
                          icon: Icons.format_underline,
                          isSelected: _isUnderline,
                          onPressed: () => _toggleFormat('underline'),
                        ),
                        VerticalDivider(
                          indent: 8,
                          endIndent: 8,
                          color: theme.dividerColor,
                        ),
                        _buildFormatButton(
                          icon: Icons.format_list_bulleted,
                          onPressed: () {},
                        ),
                        _buildFormatButton(
                          icon: Icons.format_list_numbered,
                          onPressed: () {},
                        ),
                        _buildFormatButton(
                          icon: Icons.check_box_outlined,
                          onPressed: () {},
                        ),
                        VerticalDivider(
                          indent: 8,
                          endIndent: 8,
                          color: theme.dividerColor,
                        ),
                        _buildFormatButton(
                          icon: Icons.attach_file,
                          onPressed: () {},
                        ),
                        _buildFormatButton(
                          icon: Icons.image_outlined,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),

                // Content field
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    focusNode: _contentFocus,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                      fontStyle:
                          _isItalic ? FontStyle.italic : FontStyle.normal,
                      decoration:
                          _isUnderline ? TextDecoration.underline : null,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start writing...',
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.hintColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
