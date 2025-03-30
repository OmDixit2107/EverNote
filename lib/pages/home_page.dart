import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/tasks_provider.dart';
import '../widgets/action_card.dart';
import '../widgets/app_bar.dart';
import '../widgets/app_header.dart';
import '../widgets/dialogs.dart';
import '../widgets/scratch_pad.dart';
import '../widgets/search_bar.dart';
import 'notes_page.dart';
import 'tasks_page.dart';
import 'settings_page.dart';
import 'note_edit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const NotesPage(),
    const TasksPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
            selectedItemColor: isDarkMode ? Colors.white : Colors.black,
            unselectedItemColor: isDarkMode ? Colors.grey : Colors.black54,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline), label: 'Create'),
              BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.check_box), label: 'Tasks'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz), label: 'More'),
            ],
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              heroTag: 'create_note_fab',
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.blue,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NoteEditPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(title: 'My Evernote'),
            const SizedBox(height: 20),
            AppSearchBar(
              onTap: () {
                showSearchDialog(context, onSearch: (query) {
                  if (query.trim().isNotEmpty) {
                    showFullSearchResults(context, query);
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: ActionCard(
                      title: 'New note',
                      icon: Icons.add,
                      color: isDarkMode ? Colors.green[400]! : Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NoteEditPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ActionCard(
                      title: 'New task',
                      icon: Icons.add,
                      color: isDarkMode ? Colors.purple[400]! : Colors.purple,
                      onTap: () {
                        Dialogs.showAddTaskDialog(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  ActionCard(
                    title: 'Event',
                    icon: Icons.calendar_today_outlined,
                    color: isDarkMode ? Colors.blue[400]! : Colors.blue,
                    isPrimary: false,
                    onTap: () {},
                  ),
                  ActionCard(
                    title: 'Notebook',
                    icon: Icons.menu_book_outlined,
                    color: isDarkMode ? Colors.orange[400]! : Colors.orange,
                    isPrimary: false,
                    onTap: () {},
                  ),
                  ActionCard(
                    title: 'Audio',
                    icon: Icons.mic_none_outlined,
                    color: isDarkMode ? Colors.red[400]! : Colors.red,
                    isPrimary: false,
                    onTap: () {},
                  ),
                  ActionCard(
                    title: 'Camera',
                    icon: Icons.camera_alt_outlined,
                    color: isDarkMode ? Colors.teal[400]! : Colors.teal,
                    isPrimary: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ScratchPad(
              onMoreOptions: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor:
                        isDarkMode ? Colors.grey[900] : Colors.white,
                    title: Text(
                      'Scratch Pad Options',
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.note_add,
                              color: isDarkMode ? Colors.white : Colors.black),
                          title: Text('Create note from scratch pad',
                              style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black)),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.delete,
                              color: isDarkMode ? Colors.red[300] : Colors.red),
                          title: Text('Clear scratch pad',
                              style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black)),
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('scratch_pad_text');
                            Navigator.pop(context);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Scratch pad cleared',
                                    style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.black
                                            : Colors.white),
                                  ),
                                  backgroundColor:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('CLOSE',
                            style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
