import 'package:get/get.dart';
import 'package:templete/global/general_controller/general_controller.dart';

void initGetx() {
  // ================== Global Controller ==================
  Get.lazyPut(() => GeneralController(), fenix: true);
}
