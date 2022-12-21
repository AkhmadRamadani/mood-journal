import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moodie/models/daily_drink_model.dart';
import 'package:moodie/models/target_daily_drink_model.dart';
import 'package:moodie/utils/extensions/date_extension.dart';

class HydrateRepository {
  User? user = FirebaseAuth.instance.currentUser;

  CollectionReference dailyDrink =
      FirebaseFirestore.instance.collection('daily_drink');

  CollectionReference targetDrink =
      FirebaseFirestore.instance.collection('target_drink');

  Future<bool> addDrink(int drink, int target) async {
    bool isSuccess = false;

    /// set doc to user id + today
    DateTime now = DateTime.now();
    DateTime selectedDate =
        DateTime(now.year, now.month, now.day, 0, 0, 0, 0, 0);
    int today = selectedDate.millisecondsSinceEpoch;
    String docId = user!.uid + today.toString();
    await dailyDrink.doc(docId).set({
      'drink_amount': drink,
      'target_amount': target,
      'user_id': user!.uid,
      'created_at': DateTime.now(),
    }).then((value) => isSuccess = true);
    return isSuccess;
  }

  Future<int> getTodayDrink() async {
    int drink = 0;
    DateTime now = DateTime.now();
    DateTime selectedDate =
        DateTime(now.year, now.month, now.day, 0, 0, 0, 0, 0);
    int today = selectedDate.millisecondsSinceEpoch;
    String docId = user!.uid + today.toString();
    await dailyDrink.doc(docId).get().then((value) {
      Map<String, dynamic> data = {};
      if (value.exists) {
        data = value.data() as Map<String, dynamic>;
        DailyDrinkModel dailyDrinkModel = DailyDrinkModel.fromJson(data);
        drink = dailyDrinkModel.drinkAmount;
      } else {
        drink = 0;
      }
    });
    return drink;
  }

  Future<bool> addTarget(int target) async {
    bool isSuccess = false;
    await targetDrink.doc(user!.uid).set({
      'target_amount': target,
      'user_id': user!.uid,
      'created_at': DateTime.now(),
    }).then((value) => isSuccess = true);
    return isSuccess;
  }

  Future<int> getTarget() async {
    int target = 0;
    await targetDrink.doc(user!.uid).get().then((value) {
      Map<String, dynamic> data = {};
      if (value.exists) {
        data = value.data() as Map<String, dynamic>;
        TargetDailyDrinkModel targetDailyDrinkModel =
            TargetDailyDrinkModel.fromJson(data);
        target = targetDailyDrinkModel.targetAmount;
      } else {
        target = 0;
      }
    });
    return target;
  }
}
