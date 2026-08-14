import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:moodie/modules/gamification/controllers/gamification_controller.dart';
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        final profile = controller.profile.value;

        return RefreshIndicator(
          onRefresh: () async => await controller.loadGamificationData(),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: _buildHeader(context, profile, controller.badges),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  child: _buildTabBar(),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildQuestsTab(controller.challenges),
                _buildBadgesTab(controller.badges),
                _buildLeaderboardTab(controller.leaderboard),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------

  Widget _buildHeader(
    BuildContext context,
    GamificationProfileModel? profile,
    List<BadgeModel> badges,
  ) {
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColor.primary,
            ThemeColor.primary.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColor.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.spacing * 2,
            Spacing.spacing,
            Spacing.spacing * 2,
            Spacing.spacing * 3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Your Journey',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  _StreakPill(streak: streak),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Get.find<GamificationController>()
                        .loadGamificationData(),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.refresh, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Ring + XP summary
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularPercentIndicator(
                    radius: 44,
                    lineWidth: 7,
                    percent: levelPercentage,
                    animation: true,
                    animationDuration: 700,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    progressColor: Colors.amber.shade300,
                    circularStrokeCap: CircularStrokeCap.round,
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$level',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            height: 1,
                          ),
                        ),
                        const Text(
                          'LEVEL',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$xp Total XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearPercentIndicator(
                                  lineHeight: 8,
                                  percent: levelPercentage,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.25),
                                  progressColor: Colors.amber.shade300,
                                  barRadius: const Radius.circular(6),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$xpInLevel / $xpNeeded XP to next level',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Stat chips row
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      icon: Icons.local_fire_department,
                      label: 'Best Streak',
                      value: '$longestStreak Days',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.emoji_events,
                      label: 'Badges',
                      value: '$unlockedBadges / $totalBadges',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: ThemeColor.background,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: ThemeColor.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(4),
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: ThemeColor.neutral_600,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Quests'),
            Tab(text: 'Badges'),
            Tab(text: 'Leaderboard'),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // QUESTS TAB
  // ---------------------------------------------------------------------

  Widget _buildQuestsTab(List<ChallengeModel> challenges) {
    if (challenges.isEmpty) {
      return _buildEmptyState(
        icon: Icons.flag_outlined,
        message: 'No active quests available at the moment.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final item = challenges[index];
        final progressPct = item.progressPercentage.clamp(0.0, 1.0);
        final accent = item.isCompleted ? Colors.green : ThemeColor.primary;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 96,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item.isCompleted
                                  ? Icons.check_circle
                                  : Icons.bolt,
                              color: accent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
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
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ThemeColor.neutral_600,
                            fontSize: 12.5,
                            height: 1.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearPercentIndicator(
                                lineHeight: 7,
                                percent: progressPct,
                                backgroundColor: ThemeColor.neutral_200,
                                progressColor: accent,
                                barRadius: const Radius.circular(4),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${item.progress}/${item.targetCount}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // BADGES TAB
  // ---------------------------------------------------------------------

  Widget _buildBadgesTab(List<BadgeModel> badges) {
    if (badges.isEmpty) {
      return _buildEmptyState(
        icon: Icons.emoji_events_outlined,
        message: 'No badges found.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final unlocked = badge.isUnlocked;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: unlocked
                ? Border.all(color: Colors.amber.shade200, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: unlocked
                            ? LinearGradient(
                                colors: [
                                  Colors.amber.shade200,
                                  Colors.amber.shade400,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: unlocked ? null : ThemeColor.neutral_200,
                      ),
                      child: Icon(
                        unlocked ? Icons.emoji_events : Icons.lock_outline,
                        size: 28,
                        color: unlocked ? Colors.white : ThemeColor.neutral_500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  badge.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: unlocked
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
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? Colors.green.shade50
                        : ThemeColor.neutral_200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unlocked ? 'Unlocked' : 'Locked',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: unlocked
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

  // ---------------------------------------------------------------------
  // LEADERBOARD TAB
  // ---------------------------------------------------------------------

  Widget _buildLeaderboardTab(List<LeaderboardUserModel> leaderboard) {
    if (leaderboard.isEmpty) {
      return _buildEmptyState(
        icon: Icons.leaderboard_outlined,
        message: 'Leaderboard is currently empty.',
      );
    }

    final top3 = leaderboard.take(3).toList();
    final rest = leaderboard.length > 3
        ? leaderboard.sublist(3)
        : <LeaderboardUserModel>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (top3.isNotEmpty) _buildPodium(top3),
        const SizedBox(height: 16),
        ...rest.asMap().entries.map((entry) {
          final rank = entry.key + 4;
          final user = entry.value;
          return _buildLeaderboardRow(rank, user);
        }),
      ],
    );
  }

  Widget _buildPodium(List<LeaderboardUserModel> top3) {
    // order: 2nd, 1st, 3rd for visual podium layout
    Widget? first = top3.isNotEmpty ? _podiumSlot(top3[0], 1) : null;
    Widget? second = top3.length > 1 ? _podiumSlot(top3[1], 2) : null;
    Widget? third = top3.length > 2 ? _podiumSlot(top3[2], 3) : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (second != null) second,
          if (first != null) first,
          if (third != null) third,
        ],
      ),
    );
  }

  Widget _podiumSlot(LeaderboardUserModel user, int rank) {
    final isFirst = rank == 1;
    final medal = rank == 1 ? '🥇' : (rank == 2 ? '🥈' : '🥉');
    final size = isFirst ? 64.0 : 52.0;
    final podiumHeight = isFirst ? 54.0 : (rank == 2 ? 38.0 : 26.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(medal, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 6),
        CircleAvatar(
          radius: size / 2,
          backgroundColor: isFirst
              ? Colors.amber.shade100
              : ThemeColor.primary.withValues(alpha: 0.1),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isFirst ? 22 : 18,
              color: isFirst ? Colors.amber.shade800 : ThemeColor.primary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 76,
          child: Text(
            user.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: ThemeColor.neutral_900,
            ),
          ),
        ),
        Text(
          '${user.xp} XP',
          style: const TextStyle(
            fontSize: 11,
            color: ThemeColor.neutral_600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 56,
          height: podiumHeight,
          decoration: BoxDecoration(
            color: isFirst
                ? Colors.amber.shade300
                : ThemeColor.primary.withValues(alpha: 0.35),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$rank',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(int rank, LeaderboardUserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: ThemeColor.neutral_500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: ThemeColor.primary.withValues(alpha: 0.1),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: ThemeColor.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Lvl ${user.level}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: ThemeColor.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '🔥 ${user.currentStreak}d',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: ThemeColor.neutral_600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${user.xp} XP',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: ThemeColor.neutral_900,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // SHARED
  // ---------------------------------------------------------------------

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: ThemeColor.neutral_300),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ThemeColor.neutral_500,
                fontSize: 14,
              ),
            ),
          ],
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
              height: 210,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (_, __) => Container(
                  height: 96,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
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

// ---------------------------------------------------------------------
// SMALL HELPER WIDGETS
// ---------------------------------------------------------------------

class _StreakPill extends StatelessWidget {
  final int streak;
  const _StreakPill({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.shade400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 10.5),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 68;
  @override
  double get maxExtent => 68;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) => false;
}
