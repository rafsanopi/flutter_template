import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:templete/core/routes/route_path.dart';
import 'package:templete/global/error_screen/error_screen.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GeneralErrorScreen(
      onTap: () {
        if (context.canPop()) {
          context.pop();
          return;
        }

        context.goNamed(RoutePath.splashScreen);
      },
    );
  }
}
