import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templete/global/language/arabic/arabic.dart';
import 'package:templete/global/language/eng/eng.dart';
import 'package:templete/helper/local_db/local_db.dart';
import 'package:templete/utils/app_const/app_const.dart';

class Language extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    "en_US": english,
    "ar_SA": arabic,
  };
}

class LanguageController extends GetxController {
  final List<String> languages = ["English", "Arabic"];
  RxString selectedLanguage = "English".obs;

  RxBool isEnglish = true.obs;
  getLanguageType() async {
    isEnglish.value =
        await SharePrefsHelper.getBool(AppConstants.language) ?? true;

    debugPrint("Choosed Language===============>>>>>>>>>>>$isEnglish");

    if (isEnglish.value) {
      Get.updateLocale(const Locale("en", "US"));
      update();
    } else {
      Get.updateLocale(const Locale("ar", "SA"));
      update();
    }
  }
}
