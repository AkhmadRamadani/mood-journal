import 'package:get/get.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/modules/auth/controllers/login_controller.dart';
import 'package:moodie/modules/auth/controllers/register_controller.dart';
import 'package:moodie/modules/auth/views/login_view.dart';
import 'package:moodie/modules/auth/views/on_boarding_view.dart';
import 'package:moodie/modules/auth/views/register_view.dart';
import 'package:moodie/modules/home/controllers/home_controller.dart';
import 'package:moodie/modules/home/pages/home_page.dart';
import 'package:moodie/modules/hydrate/controllers/hydrate_controller.dart';
import 'package:moodie/modules/hydrate/views/hydrate_view.dart';
import 'package:moodie/modules/profile/views/show_profile.dart';
import 'package:moodie/modules/profile/views/help_profile.dart';
import 'package:moodie/modules/profile/views/privacy_police.dart';
import 'package:moodie/modules/profile/views/term_service.dart';
import 'package:moodie/modules/record/views/add_mood_view.dart';
import 'package:moodie/modules/splash/controllers/splash_controller.dart';
import 'package:moodie/modules/splash/views/splash_view.dart';

class Pages {
  Pages._();

  static List<GetPage> getPages() {
    return [
      GetPage(
        name: Routes.splash,
        page: () => const SplashView(),
        binding: BindingsBuilder(() {
          Get.put(SplashController());
        }),
      ),
      GetPage(
        name: Routes.login,
        page: () => const LoginView(),
        binding: BindingsBuilder(() {
          Get.put(LoginController());
        }),
      ),
      GetPage(
        name: Routes.onBoarding,
        page: () => const OnBoardingView(),
        binding: BindingsBuilder(() {
          Get.put(LoginController());
        }),
      ),
      GetPage(
        name: Routes.register,
        page: () => const RegisterView(),
        binding: BindingsBuilder(() {
          Get.put(RegisterController());
        }),
      ),
      GetPage(
        name: Routes.home,
        page: () => const HomePage(),
        binding: BindingsBuilder(() {
          Get.put(HomeController());
        }),
      ),
      GetPage(
        name: Routes.showProfile,
        page: () => const ShowProfile(),
      ),
      GetPage(
        name: Routes.addMood,
        page: () => const AddMood(),
      ),
      GetPage(
        name: Routes.helpProfile,
        page: () => const HelpProfile(),
      ),
      GetPage(
        name: Routes.privacyPolice,
        page: () => const PrivacyPolice(),
      ),
      GetPage(
        name: Routes.termService,
        page: () => const TermService(),
      ),
      GetPage(
        name: Routes.hydrate,
        page: () => HydrateView(),
        binding: BindingsBuilder(() {
          Get.put(HydrateController());
        }),
      )
    ];
  }
}
