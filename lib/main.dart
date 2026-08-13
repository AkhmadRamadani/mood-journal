import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moodie/constants/app_const.dart';
import 'package:moodie/constants/pages.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/controllers/gamification_controller.dart';
import 'package:moodie/firebase_options.dart';
import 'package:moodie/modules/dashboard/repositories/dashboard_repository.dart';
import 'package:moodie/modules/hydrate/repositories/hydrate_repository.dart';
import 'package:moodie/modules/notification/repositories/notification_repository.dart';
import 'package:moodie/modules/record/controllers/record_controller.dart';
import 'package:moodie/modules/record/repositories/menstrual_log_repository.dart';
import 'package:moodie/modules/record/repositories/record_repository.dart';
import 'package:moodie/utils/services/local_db_service.dart';
import 'package:moodie/utils/services/notifcation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ⚠️ Must init Hive FIRST before any service/controller reads from it
  await LocalDbService().init();

  NotificationService().initializeNotification();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  Get.lazyPut<RecordRepository>(() => RecordRepository(), fenix: true);
  Get.lazyPut<MenstrualLogRepository>(() => MenstrualLogRepository(),
      fenix: true);
  Get.lazyPut<DashboardRepository>(() => DashboardRepository(), fenix: true);
  Get.lazyPut<HydrateRepository>(() => HydrateRepository(), fenix: true);
  Get.lazyPut<NotificationRepository>(() => NotificationRepository(),
      fenix: true);

  Get.lazyPut<RecordController>(() => RecordController());
  Get.put<GamificationController>(GamificationController(), permanent: true);
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('A Background message just showed up :  ${message.messageId}');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      getPages: Pages.getPages(),
      builder: (context, child) {
        ScreenUtil.init(
          context,
          designSize: AppConst.to.designSize,
          minTextAdapt: true,
        );

        return MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
    );
  }
}
