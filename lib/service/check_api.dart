import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templete/global/app_status/app_error_info.dart';
import 'package:templete/global/app_status/app_status_controller.dart';
import 'package:templete/helper/tost_message/show_snackbar.dart';

Future<void> checkApi({
  required Response<dynamic> response,
  BuildContext? context,
}) async {
  if (Get.isRegistered<AppStatusController>()) {
    await Get.find<AppStatusController>().handleApiResponse(response);
    return;
  }

  if (context == null ||
      response.statusCode == null ||
      response.statusCode! < 400) {
    return;
  }

  final error = AppErrorInfo.fromResponse(response);
  showSnackBar(context: context, content: error.message);
}
