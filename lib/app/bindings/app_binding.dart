import 'package:get/get.dart';
import 'package:templete/global/app_status/app_status_controller.dart';
import 'package:templete/global/general_controller/general_controller.dart';
import 'package:templete/global/language/controller/language_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GeneralController>()) {
      Get.lazyPut<GeneralController>(() => GeneralController(), fenix: true);
    }

    if (!Get.isRegistered<LanguageController>()) {
      Get.put<LanguageController>(LanguageController(), permanent: true);
    }

    if (!Get.isRegistered<AppStatusController>()) {
      Get.put<AppStatusController>(AppStatusController(), permanent: true);
    }
  }
}
