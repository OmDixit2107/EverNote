import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors
  static const Color primaryLight = Color(0xFF1A73E8);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color errorLight = Color(0xFFB00020);
  static const Color textPrimaryLight = Color(0xFF202124);
  static const Color textSecondaryLight = Color(0xFF5F6368);

  // Dark theme colors
  static const Color primaryDark = Color(0xFF8AB4F8);
  static const Color backgroundDark = Color(0xFF202124);
  static const Color surfaceDark = Color(0xFF303134);
  static const Color errorDark = Color(0xFFCF6679);
  static const Color textPrimaryDark = Color(0xFFE8EAED);
  static const Color textSecondaryDark = Color(0xFF9AA0A6);

  // Note card colors
  static const List<Color> noteCardColors = [
    Color(0xFFFFFFFF), // Default white
    Color(0xFFF28B82), // Red
    Color(0xFFFBBC04), // Yellow
    Color(0xFFFFF475), // Light yellow
    Color(0xFFCBFF90), // Green
    Color(0xFFA7FFEB), // Teal
    Color(0xFFCBF0F8), // Light blue
    Color(0xFFAECBFA), // Blue
    Color(0xFFD7AEFB), // Purple
    Color(0xFFFDCFE8), // Pink
  ];

  // Note categories with icons and colors
  static final Map<String, Map<String, dynamic>> noteCategories = {
    'Personal': {
      'icon': Icons.person,
      'color': const Color(0xFFF28B82),
    },
    'Work': {
      'icon': Icons.work,
      'color': const Color(0xFFFBBC04),
    },
    'Ideas': {
      'icon': Icons.lightbulb,
      'color': const Color(0xFFCBFF90),
    },
    'To-do': {
      'icon': Icons.check_circle,
      'color': const Color(0xFFAECBFA),
    },
    'Important': {
      'icon': Icons.star,
      'color': const Color(0xFFD7AEFB),
    },
  };
}

class AppConstants {
  static const String appName = 'My Evernote';
  static const String appVersion = '1.0.0';
  static const String emptyNotesList =
      'No notes yet. Create a note to get started!';
  static const String emptyTasksList =
      'No tasks yet. Add a task to get started!';
  static const String searchHint = 'Search notes and tasks';
}
