import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templete/core/routes/route_path.dart';
import 'package:templete/core/routes/routes.dart';
import 'package:templete/helper/tost_message/show_snackbar.dart';

void checkApi({required Response response, BuildContext? context}) async {
  if (response.statusCode == 401) {
    //await SharePrefsHelper.remove(AppConstants.bearerToken);
    AppRouter.route.replaceNamed(RoutePath.login);
  } else if (response.statusCode == 503 && context != null) {
    showSnackBar(
      context: context,
      content: response.statusText ?? "No internet connection",
    );
  } else if (context != null) {
    showSnackBar(context: context, content: response.body["message"]);
  }
}
