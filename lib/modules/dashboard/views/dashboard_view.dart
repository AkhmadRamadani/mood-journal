import 'package:flutter/material.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:moodie/shared/widgets/cards/absence_card.dart';
import 'package:moodie/shared/widgets/cards/page_header.dart';
import 'package:get/get.dart';
import 'package:moodie/shared/widgets/cards/summary_card.dart';
import 'package:moodie/utils/extensions/date_extension.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DashboardViewPage();
}

class _DashboardViewPage extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
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
                const PageHeader(
                  greet: true,
                  type: 'name',
                  name: 'Akhmad Ramadani',
                  image:
                      'https://i.pinimg.com/564x/06/63/f5/0663f52b4e6775adcd134a27853004b3.jpg',
                ),
                const SizedBox(height: Spacing.spacing * 3),
                AbsenceCard(
                  title: 'Its Holyday',
                  desc: 'Enjoy your holiday with your family at home',
                  date: DateTime.now().toHumanDate(),
                  type: 'info',
                  onPressed: (val) {},
                ),
                const SizedBox(height: Spacing.spacing * 3),
                Text(
                  'Summary',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
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
                          const SummaryCard(
                            theme: 'primary',
                            isChart: true,
                            chartVal: 0.72,
                            header: 'Weekly Mood',
                            contentTitle: '72%',
                            date: 'Week 1 of January 2022',
                          ),
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
                          SummaryCard(
                            theme: 'secondary',
                            isChart: false,
                            header: 'Mood',
                            contentTitle: 'You\'re Happy',
                            contentDesc: 'Keep it up',
                            date: DateTime.now().toHumanDateShort(),
                          ),
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
