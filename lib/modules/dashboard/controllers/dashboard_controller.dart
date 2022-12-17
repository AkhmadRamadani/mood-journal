import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:moodie/models/quore_response.dart';
import 'package:moodie/modules/dashboard/repositories/dashboard_repository.dart';
import 'package:moodie/shared/enum/mood_enum.dart';

class DashboardController extends GetxController {
  static DashboardController get to => Get.find();

  User? user = FirebaseAuth.instance.currentUser;

  QuoteResponse? quoteResponse;
  RxBool isLoading = false.obs;

  MoodConditions? latestMood;

  Map<MoodConditions, double>? biggestMood;

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

  Future<void> setLatestMood() async {
    latestMood = await DashboardRepository().getLatestMood();
    update(['latestMood']);
  }

  String latestMoodSubText() {
    if (latestMood == MoodConditions.sad) {
      return 'Call people you love and talk to them';
    } else if (latestMood == MoodConditions.happy) {
      return 'Keep it up';
    } else if (latestMood == MoodConditions.tired) {
      return 'Take a deep breath';
    } else if (latestMood == MoodConditions.excited) {
      return 'Keep it up';
    } else if (latestMood == MoodConditions.cheerful) {
      return 'Keep it up';
    }
    return '';
  }

  Future<void> setBiggestMood() async {
    biggestMood = await DashboardRepository().getWeeklyMood();
    update(['biggestMood']);
  }

  // biggestMood Text
  String biggestMoodPercentage() {
    return "${(biggestMood?.keys.first.name ?? "").toUpperCase()} ${((biggestMood?.values.first ?? 0) * 100).toStringAsFixed(0)}%";
  }

  String biggestMoodSubText() {
    if (biggestMood?.keys.first == MoodConditions.sad) {
      return 'Don\'t worry, it will be better. You can call people you love and talk to them or write down your feelings in a journal.';
    } else if (biggestMood?.keys.first == MoodConditions.happy) {
      return 'Keep it up';
    } else if (biggestMood?.keys.first == MoodConditions.tired) {
      return 'You have a tough week. Take a deep breath';
    } else if (biggestMood?.keys.first == MoodConditions.excited) {
      return 'Keep it up';
    } else if (biggestMood?.keys.first == MoodConditions.cheerful) {
      return 'Keep it up';
    }
    return '';
  }

  @override
  Future<void> refresh() async {
    setLatestMood();
    setBiggestMood();
  }

  @override
  void onInit() {
    setQuote();
    setLatestMood();
    setBiggestMood();
    super.onInit();
  }
}
