import 'package:flutter/material.dart';
import 'package:ironlog/core/constants/color_constants.dart';

class IronLogAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const IronLogAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      actions: actions,
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
