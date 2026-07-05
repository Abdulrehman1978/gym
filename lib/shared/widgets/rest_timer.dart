import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ironlog/core/constants/color_constants.dart';
import 'package:vibration/vibration.dart';

class RestTimer extends StatefulWidget {
  final int secondsRemaining;
  final VoidCallback onSkip;

  const RestTimer({super.key, required this.secondsRemaining, required this.onSkip});

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> {
  late int _remaining;
  late Timer _timer;
  late int _total;

  @override
  void initState() {
    super.initState();
    _remaining = widget.secondsRemaining;
    _total = widget.secondsRemaining > 0 ? widget.secondsRemaining : 1;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _timer.cancel();
        Vibration.vibrate(duration: 500);
        setState(() => _remaining = 0);
        return;
      }
      setState(() => _remaining--);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formatted {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _total > 0 ? _remaining / _total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
                Text(
                  _formatted,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Rest',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: widget.onSkip,
            child: const Text('Skip', style: TextStyle(color: AppColors.primaryLight)),
          ),
        ],
      ),
    );
  }
}
