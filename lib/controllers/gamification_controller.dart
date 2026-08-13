import 'dart:developer';

import 'package:get/get.dart';
import 'package:moodie/models/badge_model.dart';
import 'package:moodie/models/challenge_model.dart';
import 'package:moodie/models/gamification_profile_model.dart';
import 'package:moodie/models/leaderboard_user_model.dart';
import 'package:moodie/services/gamification_service.dart';
import 'package:moodie/shared/widgets/dialogs/badge_unlocked_dialog.dart';
import 'package:moodie/shared/widgets/dialogs/level_up_dialog.dart';

class GamificationController extends GetxController {
  static GamificationController get to => Get.find<GamificationController>();

  final GamificationService _service = GamificationService();

  final Rx<GamificationProfileModel?> profile =
      Rx<GamificationProfileModel?>(null);
  final RxList<BadgeModel> badges = <BadgeModel>[].obs;
  final RxList<ChallengeModel> challenges = <ChallengeModel>[].obs;
  final RxList<LeaderboardUserModel> leaderboard = <LeaderboardUserModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadGamificationData();
  }

  Future<void> loadGamificationData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _service.fetchProfile(
          onRefreshed: (fresh) {
            checkLevelUpOrBadgeUnlock(profile.value, fresh);
            profile.value = fresh;
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
      }
      badges.value = results[1] as List<BadgeModel>;
      challenges.value = results[2] as List<ChallengeModel>;
      leaderboard.value = results[3] as List<LeaderboardUserModel>;
    } catch (e) {
      log('Error loading gamification data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      final newProfile = await _service.fetchProfile();
      checkLevelUpOrBadgeUnlock(profile.value, newProfile);
      profile.value = newProfile;

      // Also refresh challenges and badges in background
      _service.fetchBadges().then((b) => badges.value = b);
      _service.fetchChallenges().then((c) => challenges.value = c);
      _service.fetchLeaderboard().then((l) => leaderboard.value = l);
    } catch (e) {
      log('Error refreshing gamification profile: $e');
    }
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
