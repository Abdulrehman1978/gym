import 'package:flutter/material.dart';
import 'package:ironlog/core/constants/color_constants.dart';

class RpeSelector extends StatefulWidget {
  final Function(int rpe) onSelected;

  const RpeSelector({super.key, required this.onSelected});

  @override
  State<RpeSelector> createState() => _RpeSelectorState();
}

class _RpeSelectorState extends State<RpeSelector> {
  int? _selectedRpe;

  static const _options = [
    (emoji: '😐', label: 'Easy', rpe: '5-6', value: 6),
    (emoji: '💪', label: 'Just Right', rpe: '7-8', value: 8),
    (emoji: '😤', label: 'Hard', rpe: '9', value: 9),
    (emoji: '💀', label: 'Too Heavy', rpe: '10', value: 10),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _options.map((opt) {
            final selected = _selectedRpe == opt.value;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedRpe = opt.value);
                widget.onSelected(opt.value);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.surfaceLight,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(opt.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 4),
                    Text(opt.label,
                      style: TextStyle(
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedRpe != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'RPE $_selectedRpe',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
