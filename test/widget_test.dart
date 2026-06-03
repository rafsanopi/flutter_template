import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:templete/global/app_status/app_status_controller.dart';
import 'package:templete/main.dart';
import 'package:templete/presentation/screens/splash_screen/splash_screen.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('renders the splash screen', (tester) async {
    Get.put<AppStatusController>(
      AppStatusController(monitorConnection: false),
      permanent: true,
    );

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
