import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:moodie/models/badge_model.dart';
import 'package:moodie/models/challenge_model.dart';
import 'package:moodie/models/gamification_profile_model.dart';
import 'package:moodie/models/leaderboard_user_model.dart';
import 'package:moodie/services/gamification_service.dart';
import 'package:moodie/shared/widgets/dialogs/badge_unlocked_dialog.dart';
import 'package:moodie/shared/widgets/dialogs/level_up_dialog.dart';
import 'package:moodie/utils/services/event_bus.dart';

class GamificationController extends GetxController {
  static GamificationController get to {
    if (!Get.isRegistered<GamificationController>()) {
      return Get.put(GamificationController());
    }
    return Get.find<GamificationController>();
  }

  final GamificationService _service = GamificationService();

  final Rx<GamificationProfileModel?> profile =
      Rx<GamificationProfileModel?>(null);
  final RxList<BadgeModel> badges = <BadgeModel>[].obs;
  final RxList<ChallengeModel> challenges = <ChallengeModel>[].obs;
  final RxList<LeaderboardUserModel> leaderboard = <LeaderboardUserModel>[].obs;
  final RxBool isLoading = false.obs;

  StreamSubscription? _waterSub;
  StreamSubscription? _moodSub;
  StreamSubscription? _menstrualSub;

  @override
  void onInit() {
    super.onInit();
    loadGamificationData();

    _waterSub = eventBus.on<WaterIntakeUpdatedEvent>().listen((_) {
      refreshProfile();
    });
    _moodSub = eventBus.on<MoodLoggedEvent>().listen((_) {
      refreshProfile();
    });
    _menstrualSub = eventBus.on<MenstrualLogUpdatedEvent>().listen((_) {
      refreshProfile();
    });
  }

  @override
  void onClose() {
    _waterSub?.cancel();
    _moodSub?.cancel();
    _menstrualSub?.cancel();
    super.onClose();
  }

  Future<void> loadGamificationData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _service.fetchProfile(
          onRefreshed: (fresh) {
            checkLevelUpOrBadgeUnlock(profile.value, fresh);
            profile.value = fresh;
            eventBus.fire(GamificationUpdatedEvent(fresh));
          },
        ),
        _service.fetchBadges(
          onRefreshed: (fresh) => badges.value = fresh,
        ),
        _service.fetchChallenges(
          onRefreshed: (fresh) => challenges.value = fresh,
        ),
        _service.fetchLeaderboard(
          onRefreshed: (fresh) => leaderboard.value = fresh,
        ),
      ]);

      final newProfile = results[0] as GamificationProfileModel?;
      if (newProfile != null) {
        checkLevelUpOrBadgeUnlock(profile.value, newProfile);
        profile.value = newProfile;
        eventBus.fire(GamificationUpdatedEvent(newProfile));
      }
      if (results[1] != null) badges.value = results[1] as List<BadgeModel>;
      if (results[2] != null) {
        challenges.value = results[2] as List<ChallengeModel>;
      }
      if (results[3] != null) {
        leaderboard.value = results[3] as List<LeaderboardUserModel>;
      }
    } catch (e) {
      log('Error loading gamification data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await loadGamificationData();
  }

  void checkLevelUpOrBadgeUnlock(GamificationProfileModel? oldProfile,
      GamificationProfileModel newProfile) {
    if (oldProfile == null) return;

    if (newProfile.level > oldProfile.level) {
      LevelUpDialog.show(newProfile.level);
    } else if (newProfile.unlockedBadgesCount >
        oldProfile.unlockedBadgesCount) {
      BadgeUnlockedDialog.show(
        badgeName: 'New Badge Unlocked!',
        description: 'Check your achievements in the Gamification Hub.',
      );
    }
  }
}
