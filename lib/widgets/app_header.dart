import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showDate;

  const AppHeader({
    super.key,
    required this.title,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE dd MMMM yyyy');
    final formattedDate = dateFormat.format(now);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (showDate) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
