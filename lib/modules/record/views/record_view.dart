import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodie/modules/record/controllers/menstrual_log_controller.dart';
import 'package:moodie/modules/record/controllers/record_controller.dart';
import 'package:moodie/modules/record/views/add_menstrual_log_view.dart';
import 'package:moodie/modules/record/views/mood_detail_view.dart';
import 'package:moodie/modules/record/views/mood_wizard_view.dart';
import 'package:moodie/modules/record/views/year_in_pixels_view.dart';
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
    Get.put(RecordController());
    return Scaffold(
      backgroundColor: ThemeColor.primary,
      body: SafeArea(
        bottom: false,
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
                image: '',
                showImage: false,
                suffixIcon: Icons.calendar_month_rounded,
                onSuffixPressed: (_) => Get.to(() => const YearInPixelsView()),
              ),
            ),
            GetBuilder<RecordController>(
                id: 'calendar',
                builder: (state) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.spacing * 2),
                    child: TableCalendar(
                      key: ValueKey(
                          '${state.selectedDate.year}_${state.selectedDate.month}_${state.selectedDate.day}'),
                      focusedDay: state.selectedDate,
                      firstDay: DateTime(2020, 1, 1),
                      lastDay: DateTime.now(),
                      calendarFormat: CalendarFormat.week,
                      selectedDayPredicate: (day) {
                        return isSameDay(state.selectedDate, day);
                      },
                      enabledDayPredicate: (day) {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final target = DateTime(day.year, day.month, day.day);
                        return !target.isAfter(today);
                      },
                      onPageChanged: (focusedDay) async {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final target = DateTime(
                            focusedDay.year, focusedDay.month, focusedDay.day);
                        final dateToSet =
                            target.isAfter(today) ? today : focusedDay;
                        state.selectedDate = dateToSet;
                        await state.getMoodByDate();
                        state.update(['record', 'calendar']);
                      },
                      onHeaderTapped: (focusedDay) async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: state.selectedDate.isAfter(now)
                              ? now
                              : state.selectedDate,
                          firstDate: DateTime(2020, 1, 1),
                          lastDate: now,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: ThemeColor.primary,
                                  onPrimary: Colors.white,
                                  surface: ThemeColor.white,
                                  onSurface: ThemeColor.neutral_900,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null) {
                          state.selectedDate = picked;
                          await state.getMoodByDate();
                          state.update(['record', 'calendar']);
                        }
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
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                date.day.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color: ThemeColor.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              if (state.weeklyMoods.any((m) =>
                                      m.menstrualLog != null &&
                                      isSameDay(m.createdAt, date)) ||
                                  state.listMood.any((m) =>
                                      m != null &&
                                      m.menstrualLog != null &&
                                      isSameDay(m.createdAt, date)))
                                const Positioned(
                                  bottom: 2,
                                  child: Icon(
                                    Icons.water_drop,
                                    size: 10,
                                    color: ThemeColor.purple_400,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        todayBuilder: (context, date, events) => Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ThemeColor.background
                                .withAlpha((0.5 * 255).toInt()),
                            borderRadius: BorderRadius.circular(
                                CustomRadius.defaultRadius * 5),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                date.day.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color: ThemeColor.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              if (state.weeklyMoods.any((m) =>
                                      m.menstrualLog != null &&
                                      isSameDay(m.createdAt, date)) ||
                                  state.listMood.any((m) =>
                                      m != null &&
                                      m.menstrualLog != null &&
                                      isSameDay(m.createdAt, date)))
                                const Positioned(
                                  bottom: 2,
                                  child: Icon(
                                    Icons.water_drop,
                                    size: 10,
                                    color: ThemeColor.purple_400,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        defaultBuilder: (context, date, events) {
                          final hasMenstrual = state.weeklyMoods.any((m) =>
                                  m.menstrualLog != null &&
                                  isSameDay(m.createdAt, date)) ||
                              state.listMood.any((m) =>
                                  m != null &&
                                  m.menstrualLog != null &&
                                  isSameDay(m.createdAt, date));
                          if (hasMenstrual) {
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    date.day.toString(),
                                    style: const TextStyle(
                                      color: ThemeColor.white,
                                    ),
                                  ),
                                  const Positioned(
                                    bottom: 2,
                                    child: Icon(
                                      Icons.water_drop,
                                      size: 10,
                                      color: ThemeColor.secondary_200,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextFormatter: (date, locale) =>
                            '${DateFormat.yMMMM(locale).format(date)} ▾',
                        titleTextStyle: const TextStyle(
                          color: ThemeColor.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        leftChevronIcon: const Icon(
                          Icons.arrow_back_ios,
                          color: ThemeColor.white,
                          size: 15,
                        ),
                        rightChevronIcon: const Icon(
                          Icons.arrow_forward_ios,
                          color: ThemeColor.white,
                          size: 15,
                        ),
                      ),
                      onDaySelected: (selectedDay, focusedDay) async {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final target = DateTime(selectedDay.year,
                            selectedDay.month, selectedDay.day);
                        if (target.isAfter(today)) return;

                        state.selectedDate = selectedDay;
                        await state.getMoodByDate();
                        state.update(['record', 'calendar']);
                      },
                      calendarStyle: CalendarStyle(
                        disabledTextStyle: TextStyle(
                          color: ThemeColor.white.withAlpha(80),
                        ),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.spacing * 3,
                    vertical: Spacing.spacing * 0.5),
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
                            const SizedBox(height: Spacing.spacing * 2),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    state.selectedDate.day == DateTime.now().day
                                        ? 'Today\'s Record'.tr
                                        : state.selectedDate.toHumanDateShort(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                          color: ThemeColor.neutral_900,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    RecordController.to.selectedDate =
                                        state.selectedDate;
                                    Get.to(() => const MoodWizardView());
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: ThemeColor.primary.withAlpha(20),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.add_rounded,
                                            size: 14,
                                            color: ThemeColor.primary),
                                        SizedBox(width: 3),
                                        Text(
                                          'Mood',
                                          style: TextStyle(
                                            color: ThemeColor.primary,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    final menstrualCtrl = Get.isRegistered<
                                            MenstrualLogController>()
                                        ? Get.find<MenstrualLogController>()
                                        : Get.put(MenstrualLogController());
                                    menstrualCtrl.selectedDate =
                                        state.selectedDate;
                                    Get.to(() => AddMenstrualLogView(
                                        initialDate: state.selectedDate));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: ThemeColor.secondary_400
                                          .withAlpha(20),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      children: [
                                        Text('💧',
                                            style: TextStyle(fontSize: 11)),
                                        SizedBox(width: 4),
                                        Text(
                                          'Period',
                                          style: TextStyle(
                                            color: ThemeColor.secondary_400,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
                            if (state.isLoading.value) ...[
                              for (var _ in [1, 2, 3]) ...[
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
                                    onTap: () {
                                      if (record != null) {
                                        Get.to(() =>
                                            MoodDetailView(record: record));
                                      }
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
                                      menstrualLog: record?.menstrualLog,
                                      onTap: () {
                                        if (record != null) {
                                          Get.to(() =>
                                              MoodDetailView(record: record));
                                        }
                                      },
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
