import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:templete/core/routes/route_path.dart';
import 'package:templete/core/routes/routes.dart';
import 'package:templete/global/app_status/app_error_info.dart';
import 'package:templete/helper/local_db/local_db.dart';
import 'package:templete/utils/app_colors/app_colors.dart';
import 'package:templete/utils/app_const/app_const.dart';

class AppStatusController extends GetxController {
  AppStatusController({
    InternetConnection? connection,
    bool monitorConnection = true,
  }) : _connection = connection ?? InternetConnection(),
       _monitorConnection = monitorConnection;

  final InternetConnection _connection;
  final bool _monitorConnection;
  final RxBool hasInternet = true.obs;
  final RxBool isCheckingConnection = false.obs;
  final Rxn<AppErrorInfo> activeError = Rxn<AppErrorInfo>();

  StreamSubscription<InternetStatus>? _connectionSubscription;
  bool _isMonitoring = false;

  @override
  void onInit() {
    super.onInit();
    if (_monitorConnection) {
      startMonitoring();
    }
  }

  Future<void> startMonitoring() async {
    if (_isMonitoring) {
      return;
    }

    _isMonitoring = true;
    await refreshConnection(showOnlineMessage: false);
    _connectionSubscription = _connection.onStatusChange.listen(
      _handleConnectionStatus,
    );
  }

  Future<bool> refreshConnection({bool showOnlineMessage = true}) async {
    isCheckingConnection.value = true;
    try {
      final isOnline = await _connection.hasInternetAccess;
      _setInternetStatus(isOnline, showOnlineMessage: showOnlineMessage);
      return isOnline;
    } finally {
      isCheckingConnection.value = false;
    }
  }

  Future<bool> ensureInternet() async {
    final isOnline = await refreshConnection(showOnlineMessage: false);
    if (!isOnline) {
      reportError(AppErrorInfo.noInternet(), showSnackbar: false);
    }

    return isOnline;
  }

  Future<void> handleApiResponse(
    Response<dynamic> response, {
    bool showSnackbar = true,
  }) async {
    final statusCode = response.statusCode;

    if (statusCode == null || statusCode < 400) {
      clearError();
      return;
    }

    final error = AppErrorInfo.fromResponse(response);

    if (error.type == AppErrorType.unauthorized) {
      await handleUnauthorized();
      return;
    }

    reportError(error, showSnackbar: showSnackbar);
  }

  Future<void> handleUnauthorized() async {
    await SharePrefsHelper.remove(AppConstants.token);
    reportError(AppErrorInfo.unauthorized());

    try {
      AppRouter.route.goNamed(RoutePath.login);
    } catch (_) {
      AppRouter.route.goNamed(RoutePath.splashScreen);
    }
  }

  void reportError(AppErrorInfo error, {bool showSnackbar = true}) {
    activeError.value = error;

    if (error.type == AppErrorType.noInternet) {
      hasInternet.value = false;
      return;
    }

    if (showSnackbar) {
      showErrorMessage(error.title, error.message);
    }
  }

  void showErrorMessage(String title, String message) {
    _showMessage(
      title: title,
      message: message,
      backgroundColor: AppColors.redColor,
    );
  }

  void showSuccessMessage(String title, String message) {
    _showMessage(
      title: title,
      message: message,
      backgroundColor: AppColors.greenColor,
    );
  }

  void clearError() {
    if (activeError.value?.blocksUi == true && !hasInternet.value) {
      return;
    }

    activeError.value = null;
  }

  void _handleConnectionStatus(InternetStatus status) {
    _setInternetStatus(
      status == InternetStatus.connected,
      showOnlineMessage: true,
    );
  }

  void _setInternetStatus(bool isOnline, {required bool showOnlineMessage}) {
    final wasOffline = !hasInternet.value;
    hasInternet.value = isOnline;

    if (isOnline) {
      if (activeError.value?.type == AppErrorType.noInternet) {
        activeError.value = null;
      }
      if (wasOffline && showOnlineMessage) {
        showSuccessMessage('Back online', 'Your internet connection is back.');
      }
      return;
    }

    reportError(AppErrorInfo.noInternet(), showSnackbar: false);
  }

  void _showMessage({
    required String title,
    required String message,
    required Color backgroundColor,
  }) {
    if (Get.context == null) {
      return;
    }

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor.withValues(alpha: 0.95),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    _connectionSubscription?.cancel();
    super.onClose();
  }
}
