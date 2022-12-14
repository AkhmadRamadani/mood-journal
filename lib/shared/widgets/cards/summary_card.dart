import 'package:flutter/material.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SummaryCard extends StatelessWidget {
  final String header, contentTitle, date, theme;
  final double? chartVal;
  final String? contentDesc;
  final bool isChart;

  const SummaryCard({
    Key? key,
    required this.theme,
    required this.isChart,
    required this.header,
    required this.contentTitle,
    this.contentDesc,
    this.chartVal,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme == "primary" ? ThemeColor.primary : ThemeColor.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(CustomRadius.defaultRadius),
        ),
      ),
      padding: const EdgeInsets.all(Spacing.spacing * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                header,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: theme == "primary"
                          ? ThemeColor.white
                          : ThemeColor.neutral_900,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme == "primary"
                    ? ThemeColor.white
                    : ThemeColor.neutral_900,
              )
            ],
          ),
          const SizedBox(
            height: Spacing.spacing * 2,
          ),

          // Chart
          Visibility(
            visible: isChart,
            child: SizedBox(
              height: Spacing.spacing * 16,
              child: CircularPercentIndicator(
                radius: Spacing.spacing * 8,
                lineWidth: Spacing.spacing,
                animation: true,
                percent: chartVal ?? 0.0,
                center: Text(
                  contentTitle,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: theme == 'primary'
                            ? ThemeColor.white
                            : ThemeColor.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: ThemeColor.background,
                backgroundWidth: Spacing.spacing / 2,
                progressColor:
                    theme == 'primary' ? ThemeColor.white : ThemeColor.primary,
              ),
            ),
          ),
          Visibility(
            visible: !isChart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contentTitle,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: theme == 'primary'
                            ? ThemeColor.white
                            : ThemeColor.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  contentDesc ?? 'null',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: theme == 'primary'
                            ? ThemeColor.white
                            : ThemeColor.neutral_900,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: Spacing.spacing * 2,
          ),
          Text(
            date,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: theme == 'primary'
                      ? ThemeColor.white
                      : ThemeColor.neutral_500,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
