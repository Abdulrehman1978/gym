import 'package:flutter/material.dart';
import 'package:ironlog/core/constants/color_constants.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNav({super.key, required this.currentIndex, this.onTap});

  void _handleDefaultTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    if (onTap != null) {
      onTap!(index);
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        int day = DateTime.now().weekday;
        if (day > 6) day = 1; // Fallback to day 1 (Push) on Sundays
        Navigator.pushNamed(context, '/workout', arguments: day);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/library');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/progress');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _handleDefaultTap(context, index),
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Exercises'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
      ],
    );
  }
}
