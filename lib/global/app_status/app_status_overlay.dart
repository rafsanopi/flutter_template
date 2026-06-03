import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templete/global/app_status/app_error_info.dart';
import 'package:templete/global/app_status/app_status_controller.dart';
import 'package:templete/global/no_internet/no_internet.dart';

class AppStatusOverlay extends StatelessWidget {
  const AppStatusOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppStatusController>();

    return Obx(() {
      final error = controller.activeError.value;
      final showOffline =
          !controller.hasInternet.value ||
          error?.type == AppErrorType.noInternet;

      return Stack(
        children: [
          child,
          if (showOffline)
            Positioned.fill(
              child: NoInternetScreen(
                isLoading: controller.isCheckingConnection.value,
                onTap: () {
                  controller.refreshConnection();
                },
              ),
            ),
        ],
      );
    });
  }
}
