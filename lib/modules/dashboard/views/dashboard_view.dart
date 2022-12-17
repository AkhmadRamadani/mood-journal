import 'package:flutter/material.dart';
import 'package:moodie/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';
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
    return Scaffold(
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
                                  contentTitle: state.biggestMoodPercentage(),
                                  date: state.biggestMoodSubText(),
                                );
                              }),
                          const SizedBox(
                            height: Spacing.spacing * 3,
                          ),
                          SummaryCard(
                            theme: 'secondary',
                            isChart: false,
                            header: 'Last Mood',
                            contentTitle: 'Sad',
                            contentDesc:
                                'When you\'re sad, don\'t forget to take a break.',
                            date: DateTime.now()
                                .subtract(const Duration(days: 1))
                                .toHumanDateShort(),
                          ),
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
                          SummaryCard(
                            theme: 'secondary',
                            isChart: true,
                            chartVal: 0.2,
                            header: 'Drink Today',
                            contentTitle: '20%',
                            contentDesc: 'You\'re not drinking enough',
                            date: DateTime.now().toHumanDateShort(),
                          ),
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
    );
  }
}
