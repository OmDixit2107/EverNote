import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/tasks_provider.dart';
import '../widgets/action_card.dart';
import '../widgets/app_header.dart';
import '../widgets/dialogs.dart';
import '../widgets/scratch_pad.dart';
import '../widgets/search_bar.dart';
import 'notes_page.dart';
import 'tasks_page.dart';
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
  ];

  void _onItemTapped(int index) {
    if (index == 3) {
      // Show More bottom sheet
      _showMoreBottomSheet();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showMoreBottomSheet() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Consumer<ThemeProvider>(builder: (context, themeProvider, _) {
            final isDarkMode = themeProvider.isDarkMode;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Wrap(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  _buildMoreOption(
                    icon: Icons.star_border,
                    title: 'Shortcuts',
                    isDarkMode: isDarkMode,
                  ),
                  _buildMoreOption(
                    icon: Icons.calendar_today_outlined,
                    title: 'Calendar',
                    isDarkMode: isDarkMode,
                  ),
                  _buildMoreOption(
                    icon: Icons.label_outline,
                    title: 'Tags',
                    isDarkMode: isDarkMode,
                  ),
                  _buildMoreOption(
                    icon: Icons.people_outline,
                    title: 'Shared',
                    isDarkMode: isDarkMode,
                  ),
                  _buildMoreOption(
                    icon: Icons.article_outlined,
                    title: 'Templates',
                    isDarkMode: isDarkMode,
                    hasLabel: true,
                    label: 'NEW',
                  ),
                  _buildMoreOption(
                    icon: Icons.apps_outlined,
                    title: 'Spaces',
                    isDarkMode: isDarkMode,
                    hasLabel: true,
                    label: 'BETA',
                  ),
                  _buildMoreOption(
                    icon: Icons.dashboard_customize_outlined,
                    title: 'My Widgets',
                    isDarkMode: isDarkMode,
                  ),
                  _buildMoreOption(
                    icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    title: isDarkMode ? 'Light Mode' : 'Dark Mode',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      themeProvider.toggleTheme();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          });
        });
  }

  Widget _buildMoreOption({
    required IconData icon,
    required String title,
    required bool isDarkMode,
    bool hasLabel = false,
    String label = '',
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ??
          () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title feature coming soon')));
          },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            if (hasLabel)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[300]! : Colors.grey[700]!,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        selectedItemColor: isDarkMode ? Colors.blue : const Color(0xFF1A873E),
        unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_outlined),
            activeIcon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined),
            activeIcon: Icon(Icons.check_box),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.blue : const Color(0xFF1A873E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: FloatingActionButton(
                heroTag: 'home_create_note_fab',
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
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          'Evernote',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
        ],
      ),
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
