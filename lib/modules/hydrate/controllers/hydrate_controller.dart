import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/constants/asset_const.dart';
import 'package:moodie/modules/hydrate/models/cup_choice.dart';
import 'package:moodie/modules/hydrate/repositories/hydrate_repository.dart';
import 'package:moodie/utils/services/event_bus.dart';
import 'package:moodie/utils/services/local_db_service.dart';

class HydrateController extends GetxController {
  static HydrateController get to {
    if (!Get.isRegistered<HydrateController>()) {
      return Get.put(HydrateController());
    }
    return Get.find<HydrateController>();
  }

  RxInt currentWater = 0.obs;
  RxInt targetWater = 0.obs;
  RxInt waterPercentage = 0.obs;
  RxInt remainingWater = 0.obs;

  final HydrateRepository repository = Get.find<HydrateRepository>();
  TextEditingController targetController = TextEditingController();

  List<double> heightPercentages = [
    1.0,
    1.0,
  ];

  RxBool isLoading = false.obs;

  CupChoice? selectedCup;

  var box = LocalDbService().getBox(LocalDbService.waterBoxName);

  final List<CupChoice> cupChoices = [
    CupChoice(
      name: "Bottle",
      image: AssetConst.hydrateCup3,
      ml: 200,
      percentage: 90,
      color: const Color.fromRGBO(255, 248, 237, 1),
    ),
    CupChoice(
      name: "Glass",
      image: AssetConst.hydrateCup4,
      ml: 500,
      percentage: 90,
      color: const Color.fromRGBO(247, 233, 229, 1),
    ),
    CupChoice(
      name: "Cup",
      image: AssetConst.hydrateCup2,
      ml: 1000,
      percentage: 50,
      color: const Color.fromRGBO(248, 248, 247, 1),
    ),
    CupChoice(
      name: "Water",
      image: AssetConst.hydrateCup1,
      ml: 2000,
      percentage: 75,
      color: const Color.fromRGBO(238, 238, 255, 1),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    getTodayDrink();

    getTarget();

    selectedCup = cupChoices[0];
  }

  Future<void> addTarget() async {
    isLoading.value = true;
    update();
    int target = int.parse(targetController.text);
    bool isSuccess = await repository.addTarget(target).then((value) {
      if (value) {
        targetWater.value = target;
      }
      return value;
    });
    setRemainingWater();
    setPercentage();
    setHeightPercentages();
    if (isSuccess) {
      eventBus.fire(WaterIntakeUpdatedEvent(
        drinkAmount: currentWater.value,
        targetAmount: targetWater.value,
      ));
      Get.back();
    } else {
      Get.snackbar("Error", "Failed to add target");
    }

    isLoading.value = false;
    update();
  }

  Future<void> getTarget() async {
    isLoading.value = true;
    update([
      'wave',
      'percentage',
      'remaining',
      'loading',
    ]);
    int target = await repository.getTarget(
      onRefreshed: (fresh) {
        targetWater.value = fresh;
        setRemainingWater();
        setPercentage();
        setHeightPercentages();
        update();
      },
    );
    targetWater.value = target;
    setRemainingWater();
    setPercentage();
    setHeightPercentages();
    isLoading.value = false;
    update();
    update([
      'wave',
      'percentage',
      'remaining',
      'loading',
    ]);
  }

  Future<void> setRemainingWater() async {
    isLoading.value = true;
    update(['remaining']);
    remainingWater.value = targetWater.value - currentWater.value;
    isLoading.value = false;
    update(['remaining']);
  }

  Future<void> setPercentage() async {
    isLoading.value = true;
    update(['percentage']);
    waterPercentage.value =
        (currentWater.value / targetWater.value * 100).round();
    isLoading.value = false;
    update(['percentage']);
  }

  Future<void> setHeightPercentages() async {
    isLoading.value = true;
    update(['wave']);
    heightPercentages = [
      (1 - (currentWater.value / targetWater.value)) < 0
          ? 0.01
          : 1 - (currentWater.value / targetWater.value),
      (1 - (currentWater.value / targetWater.value)) < 0
          ? 0.01 + 0.01
          : 1 - (currentWater.value / targetWater.value) + 0.01,
    ];
    log(heightPercentages.toString());
    isLoading.value = false;
    update(['wave']);
  }

  Future<void> selectCup(CupChoice cup) async {
    selectedCup = cup;
    update(['cup']);
  }

  Future<void> addCurrentWater() async {
    if (targetWater.value == 0) {
      Get.snackbar("Error", "Please add target first");
    } else {
      currentWater.value += selectedCup!.ml;
      // await box.put('current', currentWater.value);
      await repository.addDrink(currentWater.value, targetWater.value);
      setRemainingWater();
      setPercentage();
      setHeightPercentages();
      eventBus.fire(WaterIntakeUpdatedEvent(
        drinkAmount: currentWater.value,
        targetAmount: targetWater.value,
      ));
      update();
    }
  }

  Future<void> setCurrentWater() async {
    int current = await box.get('current', defaultValue: 0);
    currentWater.value = current;
    update([
      'wave',
      'percentage',
    ]);
  }

  Future<void> getTodayDrink() async {
    isLoading.value = true;
    update([
      'wave',
      'percentage',
    ]);
    int current = await repository.getTodayDrink(
      onRefreshed: (fresh) {
        currentWater.value = fresh;
        setRemainingWater();
        setPercentage();
        setHeightPercentages();
        update();
      },
    );
    currentWater.value = current;
    setRemainingWater();
    setPercentage();
    setHeightPercentages();
    isLoading.value = false;
    update([
      'wave',
      'percentage',
    ]);
  }
}
