import 'package:get/get.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/modules/auth/views/login_view.dart';
import 'package:moodie/modules/auth/views/on_boarding_view.dart';
import 'package:moodie/modules/auth/views/register_view.dart';
import 'package:moodie/modules/home/controllers/home_controller.dart';
import 'package:moodie/modules/home/pages/home_page.dart';
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
      ),
      GetPage(
        name: Routes.onBoarding,
        page: () => const OnBoardingView(),
      ),
      GetPage(
        name: Routes.register,
        page: () => const RegisterView(),
      ),
      GetPage(
        name: Routes.home,
        page: () => const HomePage(),
        binding: BindingsBuilder(() {
          Get.put(HomeController());
        }),
      )
    ];
  }
}
