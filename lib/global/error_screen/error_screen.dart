import 'package:flutter/material.dart';
import 'package:templete/global/widgets/app_status_screen.dart';

class GeneralErrorScreen extends StatelessWidget {
  const GeneralErrorScreen({
    super.key,
    required this.onTap,
    this.title = 'Something went wrong',
    this.message = 'Please try again in a moment.',
    this.isLoading = false,
  });

  final VoidCallback onTap;
  final String title;
  final String message;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AppStatusScreen(
      icon: Icons.error_outline_rounded,
      title: title,
      message: message,
      actionLabel: 'Try Again',
      onAction: onTap,
      isLoading: isLoading,
    );
  }
}
