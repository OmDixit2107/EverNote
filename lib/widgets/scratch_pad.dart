import 'package:evernote/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScratchPad extends StatefulWidget {
  final String initialText;
  final VoidCallback onMoreOptions;

  const ScratchPad({
    super.key,
    this.initialText = 'Start writing...',
    required this.onMoreOptions,
  });

  @override
  State<ScratchPad> createState() => _ScratchPadState();
}

class _ScratchPadState extends State<ScratchPad> {
  late TextEditingController _textController;
  late String _scratchPadText;
  static const String _prefsKey = 'scratch_pad_text';

  @override
  void initState() {
    super.initState();
    _scratchPadText = widget.initialText;
    _textController = TextEditingController(text: '');
    _loadSavedText();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedText() async {
    final prefs = await SharedPreferences.getInstance();
    final savedText = prefs.getString(_prefsKey);

    if (savedText != null && savedText.isNotEmpty) {
      setState(() {
        _scratchPadText = savedText;
        _textController.text = savedText;
      });
    }
  }

  Future<void> _saveText(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, text);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Scratch Pad',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: widget.onMoreOptions,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16.0),
                hintText: _scratchPadText == widget.initialText
                    ? widget.initialText
                    : null,
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.black : Colors.grey,
                  fontSize: 16,
                ),
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              maxLines: 5,
              onChanged: (text) {
                _saveText(text);
              },
            ),
          ),
        ),
      ],
    );
  }
}
