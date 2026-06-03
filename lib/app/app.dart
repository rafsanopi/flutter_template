import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:templete/app/bindings/app_binding.dart';
import 'package:templete/core/routes/routes.dart';
import 'package:templete/core/theme/light_theme.dart';
import 'package:templete/global/app_status/app_status_overlay.dart';
import 'package:templete/global/language/controller/language_controller.dart';

class TempleteApp extends StatelessWidget {
  const TempleteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return GetMaterialApp.router(
          debugShowCheckedModeBanner: false,
          initialBinding: AppBinding(),
          theme: lightTheme,
          routeInformationParser: AppRouter.route.routeInformationParser,
          routerDelegate: AppRouter.route.routerDelegate,
          routeInformationProvider: AppRouter.route.routeInformationProvider,
          fallbackLocale: LanguageController.englishLocale,
          translations: AppTranslations(),
          builder: (context, child) {
            return AppStatusOverlay(child: child ?? const SizedBox.shrink());
          },
        );
      },
    );
  }
}

class MyApp extends TempleteApp {
  const MyApp({super.key});
}
