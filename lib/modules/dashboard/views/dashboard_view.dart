import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:moodie/controllers/gamification_controller.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:moodie/shared/widgets/cards/absence_card.dart';
import 'package:moodie/shared/widgets/cards/page_header.dart';
import 'package:get/get.dart';
import 'package:moodie/shared/widgets/cards/summary_card.dart';
import 'package:moodie/utils/extensions/date_extension.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    DashboardController controller = Get.put(DashboardController());
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: ThemeColor.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
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
                  Obx(() {
                    final gController = GamificationController.to;
                    final profile = gController.profile.value;
                    final streak = profile?.currentStreak ?? 0;
                    final level = profile?.level ?? 1;
                    final pct =
                        (profile?.levelPercentage ?? 0.0).clamp(0.0, 1.0);

                    return InkWell(
                      onTap: () => Get.toNamed(Routes.gamification),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ThemeColor.primary,
                              ThemeColor.primary.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeColor.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
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
                              child: const Text('🔥',
                                  style: TextStyle(fontSize: 20)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Streak: $streak Days',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
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
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: Spacing.spacing * 3),
                  GetBuilder<DashboardController>(
                      id: 'quote',
                      builder: (state) {
                        return AbsenceCard(
                          title: state.salute(),
                          desc: state.quoteResponse?.content ?? "How are you?",
                          date: state.quoteResponse?.author ?? "",
                          type: 'info',
                          isLoading: state.isLoading.value,
                          onPressed: (val) {},
                          image: state.user?.photoURL ?? '',
                        );
                      }),
                  const SizedBox(height: Spacing.spacing * 3),
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: ThemeColor.neutral_900,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: Spacing.spacing * 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            GetBuilder<DashboardController>(
                                id: 'biggestMood',
                                builder: (state) {
                                  return SummaryCard(
                                    theme: 'primary',
                                    isChart: true,
                                    chartVal:
                                        state.biggestMood?.values.first ?? 0.0,
                                    header: 'Weekly Mood',
                                    contentTitle:
                                        (state.biggestMood?.keys.first.name ??
                                                '')
                                            .toUpperCase(),
                                    chartSubTitle:
                                        '${((state.biggestMood?.values.first ?? 0) * 100).toStringAsFixed(0)}%',
                                    date: state.biggestMoodSubText(),
                                  );
                                }),
                            const SizedBox(
                              height: Spacing.spacing * 3,
                            ),
                            GetBuilder<DashboardController>(
                                id: 'water',
                                builder: (state) {
                                  return SummaryCard(
                                    theme: 'secondary',
                                    isChart: false,
                                    header: 'Average Daily Drink',
                                    contentTitle:
                                        '${state.dailyDrinkMean.value.toStringAsFixed(2)} L',
                                    contentDesc:
                                        "This is your average daily drink",
                                    date: 'In Last 7 Days',
                                  );
                                }),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: (Spacing.spacing * 2) + 4,
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            GetBuilder<DashboardController>(
                                id: 'latestMood',
                                builder: (state) {
                                  return SummaryCard(
                                    theme: 'secondary',
                                    isChart: false,
                                    header: 'Mood',
                                    contentTitle:
                                        'You\'re ${(state.latestMood?.name ?? "not adding any mood yet")}',
                                    contentDesc: state.latestMoodSubText(),
                                    date: DateTime.now().toHumanDateShort(),
                                  );
                                }),
                            const SizedBox(
                              height: Spacing.spacing * 3,
                            ),
                            GetBuilder<DashboardController>(
                                id: 'water',
                                builder: (state) {
                                  return SummaryCard(
                                    onTap: () async {
                                      await Get.toNamed(Routes.hydrate);
                                      state.refresh();
                                    },
                                    theme: 'secondary',
                                    isChart: true,
                                    chartVal:
                                        (state.waterPercentage.value / 100) > 1
                                            ? 1
                                            : (state.waterPercentage.value /
                                                100),
                                    header: 'Drink Today',
                                    contentTitle: (state.waterPercentage.value /
                                                100) >
                                            1
                                        ? '100%'
                                        : '${(state.waterPercentage.value.isNaN ? 0 : state.waterPercentage.value).toStringAsFixed(0)}%',
                                    contentDesc: 'You\'re not drinking enough',
                                    date: state.drinkTodaySubText(),
                                  );
                                }),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
