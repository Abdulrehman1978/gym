import 'package:flutter/material.dart';
import 'package:ironlog/core/constants/color_constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final results = snapshot.data ?? [ConnectivityResult.none];
        final isOffline = results.contains(ConnectivityResult.none) && snapshot.connectionState == ConnectionState.active;

        if (!isOffline) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.primary.withAlpha(25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 8),
              const Text(
                'Offline — data will sync when connected',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
