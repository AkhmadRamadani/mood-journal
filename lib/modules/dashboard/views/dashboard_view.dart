import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moodie/constants/asset_const.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:moodie/modules/gamification/controllers/gamification_controller.dart';
import 'package:moodie/modules/home/controllers/home_controller.dart';
import 'package:moodie/modules/quick_log/views/quick_log_bar.dart';
import 'package:moodie/modules/record/views/add_menstrual_log_view.dart';
import 'package:moodie/modules/record/views/record_view.dart';
import 'package:moodie/modules/record/views/year_in_pixels_view.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:moodie/shared/widgets/cards/page_header.dart';
import 'package:moodie/shared/widgets/cards/summary_card.dart';
import 'package:moodie/utils/extensions/date_extension.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = DashboardController.to;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: ThemeColor.background,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AssetConst.signIn),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: Spacing.spacing * 5,
                horizontal: Spacing.spacing * 3,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  PageHeader(
                    greet: true,
                    type: 'name',
                    name: controller.user?.displayName ?? '',
                    image: controller.user?.photoURL ?? '',
                    showImage: false,
                  ),
                  const SizedBox(height: Spacing.spacing * 2),
                  const _StreakBanner(),
                  const SizedBox(height: Spacing.spacing * 3),
                  const QuickLogBar(),
                  const SizedBox(height: Spacing.spacing * 3),
                  _TodayCard(controller: controller),
                  const SizedBox(height: Spacing.spacing * 4),
                  const _SectionLabel('Quick Actions'),
                  const SizedBox(height: 12),
                  const _QuickActionsBar(),
                  const SizedBox(height: Spacing.spacing * 4),
                  const _SectionLabel('This Week'),
                  const SizedBox(height: 12),
                  _StatsRow(controller: controller),
                  // const SizedBox(height: Spacing.spacing * 4),
                  // const _ProgressCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: ThemeColor.neutral_600,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
    );
  }
}

// ── Prominent Top Streak Banner ──────────────────────────────────────────────

class _StreakBanner extends StatelessWidget {
  const _StreakBanner();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final gController = GamificationController.to;
      final profile = gController.profile.value;
      final streak = profile?.currentStreak ?? 0;
      final level = profile?.level ?? 1;
      final pct = (profile?.levelPercentage ?? 0.0).clamp(0.0, 1.0);

      return InkWell(
        onTap: () => Get.toNamed(Routes.gamification),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ThemeColor.primary,
                ThemeColor.primary.withValues(alpha: 0.85),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: ThemeColor.primary.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text('🔥', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$streak Day Streak',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        Text(
                          'Level $level',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearPercentIndicator(
                      lineHeight: 6.0,
                      percent: pct,
                      backgroundColor: Colors.white30,
                      progressColor: Colors.amber.shade300,
                      barRadius: const Radius.circular(3),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 15,
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── 1. PRIMARY: Today ────────────────────────────────────────────────────
// Quote/greeting and current mood used to be two separate cards competing
// for the same "first thing you see" slot. They answer the same question
// ("how am I doing today?"), so they're now one card with one clear CTA.

class _TodayCard extends StatelessWidget {
  final DashboardController controller;
  const _TodayCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColor.primary,
            ThemeColor.primary.withValues(alpha: 0.85)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ThemeColor.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: GetBuilder<DashboardController>(
        id: 'quote',
        builder: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateTime.now().toHumanDateShort(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.salute(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.quoteResponse?.content ?? 'How are you feeling today?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              if ((state.quoteResponse?.author ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '— ${state.quoteResponse!.author}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              _MoodRow(controller: controller),
            ],
          );
        },
      ),
    );
  }
}

class _MoodRow extends StatelessWidget {
  final DashboardController controller;
  const _MoodRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      id: 'latestMood',
      builder: (state) {
        final hasMood = state.latestMood != null;
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (Get.isRegistered<HomeController>()) {
              HomeController.to.setPageIndex(1);
            } else {
              Get.to(() => const RecordView());
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasMood
                            ? "You're feeling ${state.latestMood!.name}"
                            : "You haven't logged a mood yet",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasMood
                            ? state.latestMoodSubText()
                            : 'Tap to log how you feel',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white70, size: 14),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── 2. SECONDARY: Quick Actions ──────────────────────────────────────────
// Unchanged in intent — these are the app's core write actions, so they
// stay one tap away and immediately after the primary card.

class _QuickActionsBar extends StatelessWidget {
  const _QuickActionsBar();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _QuickActionButton(
            icon: Icons.edit_note_rounded,
            label: 'Log Mood',
            color: const Color(0xFF6C5CE7),
            onTap: () => Get.toNamed(Routes.addMood),
          ),
          const SizedBox(width: 18),
          _QuickActionButton(
            icon: Icons.fitness_center_rounded,
            label: 'AI Workout',
            color: const Color(0xFFE17055),
            onTap: () => Get.toNamed(Routes.workout),
          ),
          const SizedBox(width: 18),
          _QuickActionButton(
            icon: Icons.water_drop_rounded,
            label: 'Hydrate',
            color: const Color(0xFF00CEC9),
            onTap: () => Get.toNamed(Routes.hydrate),
          ),
          const SizedBox(width: 18),
          _QuickActionButton(
            icon: Icons.opacity_rounded,
            label: 'Period Log',
            color: const Color(0xFFFD79A8),
            onTap: () => Get.to(() => const AddMenstrualLogView()),
          ),
          const SizedBox(width: 18),
          _QuickActionButton(
            icon: Icons.history_rounded,
            label: 'History',
            color: const Color(0xFF00B894),
            onTap: () => Get.to(() => const YearInPixelsView()),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(60), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ThemeColor.neutral_700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 3. TERTIARY: Stats ───────────────────────────────────────────────────
// Weekly mood + hydration. These are glanceable trend data, not decisions —
// so they're smaller and lower-weight than the primary card by design,
// not by accident (they were previously the same visual weight as
// everything else on the page).

class _StatsRow extends StatelessWidget {
  final DashboardController controller;
  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GetBuilder<DashboardController>(
            id: 'biggestMood',
            builder: (state) {
              return SummaryCard(
                onTap: () {
                  if (Get.isRegistered<HomeController>()) {
                    HomeController.to.setPageIndex(1);
                  } else {
                    Get.to(() => const RecordView());
                  }
                },
                theme: 'primary',
                isChart: true,
                chartVal: state.biggestMood?.values.first ?? 0.0,
                header: 'Weekly Mood',
                contentTitle:
                    (state.biggestMood?.keys.first.name ?? '').toUpperCase(),
                chartSubTitle:
                    '${((state.biggestMood?.values.first ?? 0) * 100).toStringAsFixed(0)}%',
                date: state.biggestMoodSubText(),
              );
            },
          ),
        ),
        const SizedBox(width: (Spacing.spacing * 2) + 4),
        Expanded(
          child: GetBuilder<DashboardController>(
            id: 'water',
            builder: (state) {
              final pct = (state.waterPercentage.value / 100).isNaN
                  ? 0.0
                  : (state.waterPercentage.value / 100).clamp(0.0, 1.0);
              return SummaryCard(
                onTap: () async {
                  await Get.toNamed(Routes.hydrate);
                  state.refresh();
                },
                theme: 'secondary',
                isChart: true,
                chartVal: pct,
                header: 'Drink Today',
                contentTitle: '${(pct * 100).toStringAsFixed(0)}%',
                contentDesc: 'You\'re not drinking enough',
                date: state.drinkTodaySubText(),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── 4. SUPPORT: Progress (collapsed by default) ──────────────────────────
// Streak banner, daily quests, and badges strip used to be three separate
// elevated cards, each visually shouting as loud as the mood/quote card.
// Gamification exists to nudge logging behavior — it shouldn't outrank the
// behavior itself. Folded into one dismissible module, collapsed on load.

class _ProgressCard extends StatefulWidget {
  const _ProgressCard();

  @override
  State<_ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<_ProgressCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final g = GamificationController.to;
      final profile = g.profile.value;
      final streak = profile?.currentStreak ?? 0;
      final level = profile?.level ?? 1;
      final pct = (profile?.levelPercentage ?? 0.0).clamp(0.0, 1.0);
      final quests = g.challenges.take(2).toList();
      final badges = g.badges;
      final unlocked = badges.where((b) => b.isUnlocked).length;

      return Container(
        decoration: BoxDecoration(
          color: ThemeColor.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ThemeColor.primary.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ThemeColor.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🔥', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$streak day streak · Level $level',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: ThemeColor.neutral_900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          LinearPercentIndicator(
                            lineHeight: 5.0,
                            percent: pct,
                            backgroundColor: ThemeColor.neutral_200,
                            progressColor: ThemeColor.primary,
                            barRadius: const Radius.circular(3),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: ThemeColor.neutral_600,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (quests.isNotEmpty) ...[
                      const _MiniLabel('Daily Quests'),
                      const SizedBox(height: 8),
                      ...quests.map((q) => _QuestRow(quest: q)),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _MiniLabel('Badges ($unlocked/${badges.length})'),
                        GestureDetector(
                          onTap: () => Get.toNamed(Routes.gamification),
                          child: const Text(
                            'See all',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ThemeColor.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _BadgesStrip(badges: badges),
                  ],
                ),
              ),
              secondChild: const SizedBox(width: double.infinity),
            ),
          ],
        ),
      );
    });
  }
}

class _MiniLabel extends StatelessWidget {
  final String text;
  const _MiniLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: ThemeColor.neutral_900,
      ),
    );
  }
}

class _QuestRow extends StatelessWidget {
  final dynamic quest;
  const _QuestRow({required this.quest});

  @override
  Widget build(BuildContext context) {
    final pct = (quest.progressPercentage as double).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              quest.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12.5, color: ThemeColor.neutral_700),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 5,
                backgroundColor: ThemeColor.neutral_200,
                color: quest.isCompleted ? Colors.green : ThemeColor.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+${quest.xpReward}',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgesStrip extends StatelessWidget {
  final List<dynamic> badges;
  const _BadgesStrip({required this.badges});

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox();
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: badges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = badges[index];
          return Tooltip(
            message: item.name,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: item.isUnlocked
                    ? ThemeColor.primary.withAlpha(20)
                    : ThemeColor.neutral_100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isUnlocked
                      ? ThemeColor.primary.withAlpha(60)
                      : ThemeColor.neutral_200,
                ),
              ),
              child: Center(
                child: Text(
                  item.isUnlocked ? '🏆' : '🔒',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
