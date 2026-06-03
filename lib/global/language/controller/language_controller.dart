import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templete/global/language/arabic/arabic.dart';
import 'package:templete/global/language/eng/eng.dart';
import 'package:templete/helper/local_db/local_db.dart';
import 'package:templete/utils/app_const/app_const.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': english,
    'ar_SA': arabic,
  };
}

@Deprecated('Use AppTranslations instead.')
class Language extends AppTranslations {}

class LanguageController extends GetxController {
  static const Locale englishLocale = Locale('en', 'US');
  static const Locale arabicLocale = Locale('ar', 'SA');

  final List<String> languages = const ['English', 'Arabic'];
  final RxString selectedLanguage = 'English'.obs;
  final RxBool isEnglish = true.obs;

  Locale get currentLocale => isEnglish.value ? englishLocale : arabicLocale;

  Future<void> getLanguageType() => loadSavedLanguage();

  Future<void> loadSavedLanguage() async {
    isEnglish.value =
        await SharePrefsHelper.getBool(AppConstants.language) ?? true;
    selectedLanguage.value = isEnglish.value ? languages.first : languages.last;
    Get.updateLocale(currentLocale);
    update();
  }

  Future<void> changeLanguage({required bool english}) async {
    isEnglish.value = english;
    selectedLanguage.value = english ? languages.first : languages.last;
    await SharePrefsHelper.setBool(AppConstants.language, english);
    Get.updateLocale(currentLocale);
    update();
  }
}
