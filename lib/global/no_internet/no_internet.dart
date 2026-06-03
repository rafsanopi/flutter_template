import 'package:flutter/material.dart';
import 'package:templete/global/widgets/app_status_screen.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppStatusScreen(
      icon: Icons.wifi_off_rounded,
      title: 'No internet connection',
      message: 'Please check your connection and try again.',
      actionLabel: 'Try Again',
      onAction: onTap,
      isLoading: isLoading,
    );
  }
}
