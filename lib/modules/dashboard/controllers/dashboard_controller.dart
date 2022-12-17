import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:moodie/models/quore_response.dart';
import 'package:moodie/modules/dashboard/repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  static DashboardController get to => Get.find();

  User? user = FirebaseAuth.instance.currentUser;

  QuoteResponse? quoteResponse;
  RxBool isLoading = false.obs;

  String salute() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Future<void> setQuote() async {
    isLoading.value = true;
    update(['quote']);
    quoteResponse = await DashboardRepository().getQuote();
    isLoading.value = false;
    update(['quote']);
  }

  @override
  void onInit() {
    setQuote();
    super.onInit();
  }
}
