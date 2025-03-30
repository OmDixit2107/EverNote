import 'package:evernote/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    this.title = '',
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    return AppBar(
      backgroundColor: isDarkMode ? const Color(0xFF181404) : Colors.white,
      elevation: 0,
      title: Text(title),
      actions: actions ??
          [
            IconButton(
              icon: const Icon(Icons.bolt, color: Colors.orange),
              onPressed: () {
                // Premium feature action
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Notifications action
              },
            ),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
