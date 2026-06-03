import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:templete/core/routes/route_path.dart';
import 'package:templete/helper/extension/base_extension.dart';
import 'package:templete/presentation/screens/splash_screen/splash_screen.dart';
import 'package:templete/presentation/widgets/error_screen/error_screen.dart';

class AppRouter {
  static final GoRouter initRoute = GoRouter(
    initialLocation: RoutePath.splashScreen.addBasePath,
    // navigatorKey: Get.key,
    debugLogDiagnostics: kDebugMode,
    routes: [
      ///======================= splash Route =======================
      GoRoute(
        name: RoutePath.splashScreen,
        path: RoutePath.splashScreen.addBasePath,
        builder: (context, state) => const SplashScreen(),
        // redirect: (context, state) {
        //   // Future.delayed(const Duration(seconds: 1), () {
        //   //   AppRouter.route.replaceNamed(RoutePath.chooseRole);
        //   // });
        //   // return null;
        // },
      ),
      GoRoute(
        name: RoutePath.errorScreen,
        path: RoutePath.errorScreen.addBasePath,
        builder: (context, state) => const ErrorPage(),
      ),
    ],
  );

  static GoRouter get route => initRoute;
}
