import 'package:flutter/material.dart';
import 'package:templete/core/custom_assets/assets.gen.dart';
import 'package:templete/utils/app_colors/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(child: Assets.images.splashLogo.image()),
    );
  }
}
