import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:moodie/controllers/gamification_controller.dart';
import 'package:moodie/models/badge_model.dart';
import 'package:moodie/models/gamification_profile_model.dart';
import 'package:moodie/models/challenge_model.dart';
import 'package:moodie/models/leaderboard_user_model.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({Key? key}) : super(key: key);

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GamificationController>();

    return Scaffold(
      backgroundColor: ThemeColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeColor.neutral_900),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Gamification Hub',
          style: TextStyle(
            color: ThemeColor.neutral_900,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: ThemeColor.primary),
            onPressed: () => controller.loadGamificationData(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        final profile = controller.profile.value;

        return RefreshIndicator(
          onRefresh: () async => await controller.loadGamificationData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Level & XP Progress Card
                _buildProfileSummaryCard(profile, controller.badges),
                const SizedBox(height: 12),

                // Tabs Navigation
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: ThemeColor.primary,
                    unselectedLabelColor: ThemeColor.neutral_600,
                    indicatorColor: ThemeColor.primary,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Quests'),
                      Tab(text: 'Badges'),
                      Tab(text: 'Leaderboard'),
                    ],
                  ),
                ),

                // Tab Content Views
                SizedBox(
                  height: MediaQuery.of(context).size.height - 300,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildQuestsTab(controller.challenges),
                      _buildBadgesTab(controller.badges),
                      _buildLeaderboardTab(controller.leaderboard),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileSummaryCard(
      GamificationProfileModel? profile, List<BadgeModel> badges) {
    final level = profile?.level ?? 1;
    final xp = profile?.xp ?? 0;
    final xpInLevel = profile?.xpInLevel ?? 0;
    final xpNeeded = (profile?.xpNeeded != null && profile!.xpNeeded > 0)
        ? profile.xpNeeded
        : 100;

    double levelPercentage = profile?.levelPercentage ?? 0.0;
    if (levelPercentage == 0.0 && xpInLevel > 0 && xpNeeded > 0) {
      levelPercentage = xpInLevel / xpNeeded;
    }
    levelPercentage = levelPercentage.clamp(0.0, 1.0);

    final streak = profile?.currentStreak ?? 0;
    final longestStreak = profile?.longestStreak ?? 0;

    final unlockedBadges = (profile?.unlockedBadgesCount != null &&
            profile!.unlockedBadgesCount > 0)
        ? profile.unlockedBadgesCount
        : badges.where((b) => b.isUnlocked).length;

    final totalBadges =
        (profile?.totalBadgesCount != null && profile!.totalBadgesCount > 0)
            ? profile.totalBadgesCount
            : badges.length;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(Spacing.spacing * 2),
      padding: const EdgeInsets.all(Spacing.spacing * 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColor.primary,
            ThemeColor.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeColor.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'Level $level',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ThemeColor.neutral_900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$xp Total XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('🔥 ', style: TextStyle(fontSize: 14)),
                    Text(
                      '$streak Days',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Level Progress',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$xpInLevel / $xpNeeded XP',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 10.0,
            percent: levelPercentage,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            progressColor: Colors.amber.shade300,
            barRadius: const Radius.circular(5),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Best Streak', '$longestStreak Days',
                  Icons.local_fire_department),
              Container(height: 24, width: 1, color: Colors.white30),
              _buildStatItem('Badges', '$unlockedBadges / $totalBadges',
                  Icons.emoji_events),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildQuestsTab(List<ChallengeModel> challenges) {
    if (challenges.isEmpty) {
      return _buildEmptyState('No active quests available at the moment.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(Spacing.spacing * 2),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final item = challenges[index];
        final progressPct = item.progressPercentage.clamp(0.0, 1.0);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: ThemeColor.neutral_900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ThemeColor.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${item.xpReward} XP',
                        style: const TextStyle(
                          color: ThemeColor.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: ThemeColor.neutral_600,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearPercentIndicator(
                        lineHeight: 8.0,
                        percent: progressPct,
                        backgroundColor: ThemeColor.neutral_200,
                        progressColor: item.isCompleted
                            ? Colors.green
                            : ThemeColor.primary,
                        barRadius: const Radius.circular(4),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${item.progress}/${item.targetCount}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: item.isCompleted
                            ? Colors.green
                            : ThemeColor.neutral_700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgesTab(List<BadgeModel> badges) {
    if (badges.isEmpty) {
      return _buildEmptyState('No badges found.');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(Spacing.spacing * 2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: badge.isUnlocked
                      ? Colors.amber.shade100
                      : ThemeColor.neutral_200,
                  child: Icon(
                    badge.isUnlocked ? Icons.emoji_events : Icons.lock,
                    size: 30,
                    color: badge.isUnlocked
                        ? Colors.amber.shade800
                        : ThemeColor.neutral_500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  badge.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: badge.isUnlocked
                        ? ThemeColor.neutral_900
                        : ThemeColor.neutral_500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  badge.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: ThemeColor.neutral_600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badge.isUnlocked
                        ? Colors.green.shade50
                        : ThemeColor.neutral_200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge.isUnlocked ? 'Unlocked' : 'Locked',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: badge.isUnlocked
                          ? Colors.green.shade700
                          : ThemeColor.neutral_600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardTab(List<LeaderboardUserModel> leaderboard) {
    if (leaderboard.isEmpty) {
      return _buildEmptyState('Leaderboard is currently empty.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(Spacing.spacing * 2),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final user = leaderboard[index];
        final rank = index + 1;

        Widget rankBadge;
        if (rank == 1) {
          rankBadge = const Text('🥇', style: TextStyle(fontSize: 22));
        } else if (rank == 2) {
          rankBadge = const Text('🥈', style: TextStyle(fontSize: 22));
        } else if (rank == 3) {
          rankBadge = const Text('🥉', style: TextStyle(fontSize: 22));
        } else {
          rankBadge = CircleAvatar(
            radius: 14,
            backgroundColor: ThemeColor.neutral_200,
            child: Text(
              '$rank',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ThemeColor.neutral_700,
              ),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0.5,
          child: ListTile(
            leading: SizedBox(
              width: 36,
              child: Center(child: rankBadge),
            ),
            title: Text(
              user.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Row(
              children: [
                Text(
                  'Lvl ${user.level}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: ThemeColor.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '🔥 ${user.currentStreak}d',
                  style: const TextStyle(
                    fontSize: 12,
                    color: ThemeColor.neutral_600,
                  ),
                ),
              ],
            ),
            trailing: Text(
              '${user.xp} XP',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: ThemeColor.neutral_900,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: ThemeColor.neutral_500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 40,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (_, __) => Container(
                  height: 70,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
