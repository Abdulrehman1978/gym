import 'package:flutter/material.dart';
import 'package:ironlog/core/constants/color_constants.dart';

class ConnectivityDot extends StatelessWidget {
  final bool isOnline;

  const ConnectivityDot({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline ? AppColors.success : AppColors.grey,
      ),
    );
  }
}
