import 'package:flutter/material.dart';
import 'package:moodie/modules/record/controllers/record_controller.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:moodie/shared/widgets/cards/page_header.dart';
import 'package:moodie/shared/widgets/cards/record_card.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import 'package:moodie/utils/extensions/date_extension.dart';

class RecordView extends StatefulWidget {
  const RecordView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RecordController controller = Get.put(RecordController());
    return Scaffold(
      backgroundColor: ThemeColor.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: Spacing.spacing * 5,
                bottom: Spacing.spacing * 1,
                left: Spacing.spacing * 3,
                right: Spacing.spacing * 3,
              ),
              child: PageHeader(
                greet: false,
                isDark: true,
                type: 'heading',
                name: 'Record'.tr,
                image: controller.user?.photoURL ?? '',
              ),
            ),
            GetBuilder<RecordController>(
                id: 'calendar',
                builder: (state) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.spacing * 2),
                    child: TableCalendar(
                      focusedDay: state.selectedDate,
                      firstDay: DateTime.utc(
                          state.selectedDate.year, state.selectedDate.month, 1),
                      lastDay: DateTime.utc(state.selectedDate.year,
                          state.selectedDate.month + 1, 0),
                      calendarFormat: CalendarFormat.week,
                      selectedDayPredicate: (day) {
                        return isSameDay(state.selectedDate, day);
                      },
                      calendarBuilders: CalendarBuilders(
                        selectedBuilder: (context, date, events) => Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ThemeColor.white,
                            borderRadius: BorderRadius.circular(
                                CustomRadius.defaultRadius * 5),
                          ),
                          child: Text(
                            date.day.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: ThemeColor.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        todayBuilder: (context, date, events) => Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ThemeColor.background.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(
                                CustomRadius.defaultRadius * 5),
                          ),
                          child: Text(
                            date.day.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: ThemeColor.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle: TextStyle(
                          color: ThemeColor.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        leftChevronIcon: Icon(
                          Icons.arrow_back_ios,
                          color: ThemeColor.white,
                          size: 15,
                        ),
                        rightChevronIcon: Icon(
                          Icons.arrow_forward_ios,
                          color: ThemeColor.white,
                          size: 15,
                        ),
                      ),
                      onDaySelected: (selectedDay, focusedDay) async {
                        state.selectedDate = selectedDay;
                        await state.getMoodByDate();
                        state.update(['record', 'calendar']);
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: ThemeColor.white,
                          borderRadius: BorderRadius.circular(
                              CustomRadius.defaultRadius * 5),
                        ),
                        todayTextStyle:
                            const TextStyle(color: ThemeColor.primary),
                        weekendTextStyle: const TextStyle(
                          color: ThemeColor.white,
                        ),
                        defaultTextStyle:
                            const TextStyle(color: ThemeColor.white),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: ThemeColor.white),
                        weekendStyle: TextStyle(color: ThemeColor.appBar),
                      ),
                    ),
                  );
                }),
            const SizedBox(
              height: Spacing.spacing * 3,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(Spacing.spacing * 3),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: ThemeColor.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(CustomRadius.defaultRadius),
                    topRight: Radius.circular(CustomRadius.defaultRadius),
                  ),
                ),
                child: SingleChildScrollView(
                  child: GetBuilder<RecordController>(
                      id: 'record',
                      builder: (state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.selectedDate.day ==
                                DateTime.now().day) ...[
                              Text(
                                'Today\'s Record'.tr,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color: ThemeColor.neutral_900,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ] else ...[
                              Text(
                                state.selectedDate.toHumanDateShort(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color: ThemeColor.neutral_900,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                            const SizedBox(height: Spacing.spacing * 3),
                            if (state.isLoading.value) ...[
                              for (var record in [1, 2, 3]) ...[
                                RecordCard(
                                  type: 0,
                                  isLoading: state.isLoading.value,
                                ),
                                const SizedBox(height: Spacing.spacing * 3),
                              ],
                            ] else ...[
                              if (state.listMood.isEmpty) ...[
                                Center(
                                  child: Text(
                                    'No Record'.tr,
                                    style: const TextStyle(
                                      color: ThemeColor.neutral_600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                for (var record in state.listMood) ...[
                                  GestureDetector(
                                    onLongPress: () {
                                      Get.bottomSheet(
                                        Container(
                                          padding: const EdgeInsets.all(
                                              Spacing.spacing * 3),
                                          decoration: const BoxDecoration(
                                            color: ThemeColor.background,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(
                                                  CustomRadius.defaultRadius),
                                              topRight: Radius.circular(
                                                  CustomRadius.defaultRadius),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Delete Record'.tr,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                      color: ThemeColor
                                                          .neutral_900,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(
                                                  height: Spacing.spacing * 3),
                                              Text(
                                                'Are you sure you want to delete this record?'
                                                    .tr,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1!
                                                    .copyWith(
                                                      color: ThemeColor
                                                          .neutral_600,
                                                    ),
                                              ),
                                              const SizedBox(
                                                  height: Spacing.spacing * 3),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Get.back();
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              horizontal: Spacing
                                                                      .spacing *
                                                                  2,
                                                              vertical: Spacing
                                                                  .spacing),
                                                      decoration: BoxDecoration(
                                                        color: ThemeColor
                                                            .neutral_200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          CustomRadius
                                                              .defaultRadius,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Cancel'.tr,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1!
                                                            .copyWith(
                                                              color: ThemeColor
                                                                  .neutral_600,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      Get.back();
                                                      await state
                                                          .deleteMood(record!);
                                                      state.update(['record']);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              horizontal: Spacing
                                                                      .spacing *
                                                                  2,
                                                              vertical: Spacing
                                                                  .spacing),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            ThemeColor.primary,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          CustomRadius
                                                              .defaultRadius,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Delete'.tr,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1!
                                                            .copyWith(
                                                              color: ThemeColor
                                                                  .neutral_200,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: Spacing.spacing * 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    child: RecordCard(
                                      type: 0,
                                      isLoading: state.isLoading.value,
                                      emotions: record?.emotions ?? '',
                                      date: record?.createdAt.toString(),
                                      title: record?.title ?? '',
                                      desc: record?.note ?? '',
                                      mood: record?.mood,
                                      time: record?.createdAt.toTimeString(),
                                    ),
                                  ),
                                  const SizedBox(height: Spacing.spacing * 3),
                                ],
                              ],
                            ]
                          ],
                        );
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
