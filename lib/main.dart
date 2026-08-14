import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moodie/constants/app_const.dart';
import 'package:moodie/constants/pages.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/firebase_options.dart';
import 'package:moodie/modules/dashboard/repositories/dashboard_repository.dart';
import 'package:moodie/modules/gamification/controllers/gamification_controller.dart';
import 'package:moodie/modules/hydrate/repositories/hydrate_repository.dart';
import 'package:moodie/modules/notification/repositories/notification_repository.dart';
import 'package:moodie/modules/record/controllers/record_controller.dart';
import 'package:moodie/modules/record/repositories/menstrual_log_repository.dart';
import 'package:moodie/modules/record/repositories/record_repository.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/utils/services/local_db_service.dart';
import 'package:moodie/utils/services/notifcation_service.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await LocalDbService().init();
    NotificationService().initializeNotification();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    runApp(const MyApp());
  }, (error, stack) {
    if (kDebugMode) {
      print('Uncaught error: $error\n$stack');
    }
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Background message received: ${message.messageId}');
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecordRepository>(() => RecordRepository(), fenix: true);
    Get.lazyPut<MenstrualLogRepository>(() => MenstrualLogRepository(),
        fenix: true);
    Get.lazyPut<DashboardRepository>(() => DashboardRepository(), fenix: true);
    Get.lazyPut<HydrateRepository>(() => HydrateRepository(), fenix: true);
    Get.lazyPut<NotificationRepository>(() => NotificationRepository(),
        fenix: true);

    Get.lazyPut<RecordController>(() => RecordController(), fenix: true);
    Get.lazyPut<GamificationController>(() => GamificationController(),
        fenix: true);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Moodie',
      theme: ThemeData(
        primarySwatch: generateMaterialColor(ThemeColor.primary),
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      initialBinding: InitialBinding(),
      getPages: Pages.getPages(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: Builder(
            builder: (innerContext) {
              ScreenUtil.init(
                innerContext,
                designSize: AppConst.to.designSize,
                minTextAdapt: true,
              );
              return child ?? const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}
