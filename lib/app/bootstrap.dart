import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templete/app/app.dart';
import 'package:templete/app/bindings/app_binding.dart';
import 'package:templete/global/app_status/app_error_info.dart';
import 'package:templete/global/app_status/app_status_controller.dart';
import 'package:templete/global/language/controller/language_controller.dart';
import 'package:templete/service/socket_service.dart';
import 'package:templete/utils/system_utils/system_utils.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemUtil.setStatusBarColor(color: Colors.transparent);

  AppBinding().dependencies();
  _registerGlobalErrorHandlers();
  await Get.find<LanguageController>().getLanguageType();
  await SocketApi.init();

  runApp(const MyApp());
}

void _registerGlobalErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _reportUnhandledError(details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    _reportUnhandledError(error, stackTrace);
    return true;
  };
}

void _reportUnhandledError(Object error, StackTrace? stackTrace) {
  debugPrint('Unhandled app error: $error');

  if (!Get.isRegistered<AppStatusController>()) {
    return;
  }

  Get.find<AppStatusController>().reportError(
    AppErrorInfo.unknown(error: error, stackTrace: stackTrace),
    showSnackbar: false,
  );
}
