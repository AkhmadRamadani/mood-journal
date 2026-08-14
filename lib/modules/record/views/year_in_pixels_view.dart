import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moodie/models/menstrual_log_model.dart';
import 'package:moodie/modules/record/controllers/menstrual_log_controller.dart';
import 'package:moodie/modules/record/controllers/record_controller.dart';
import 'package:moodie/modules/record/controllers/year_in_pixels_controller.dart';
import 'package:moodie/modules/record/views/add_menstrual_log_view.dart';
import 'package:moodie/modules/record/views/mood_detail_view.dart';
import 'package:moodie/modules/record/views/mood_wizard_view.dart';
import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';

class YearInPixelsView extends StatefulWidget {
  const YearInPixelsView({Key? key}) : super(key: key);

  // ── Color mapping ────────────────────────────────────────────────────────
  static final Map<MoodConditions, Color> _moodColors = {
    for (var m in MoodConditions.values) m: m.color,
  };

  static final Map<MoodConditions, String> _moodLabels = {
    for (var m in MoodConditions.values) m: m.label,
  };

  static const _emptyColor = Color(0xFFE2E8F0);
  static const _periodOnlyColor = Color(0xFFF8BBD0); // Soft Rose Pink

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _shortMonths = [
    'J',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D',
  ];

  @override
  State<YearInPixelsView> createState() => _YearInPixelsViewState();
}

class _YearInPixelsViewState extends State<YearInPixelsView> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(YearInPixelsController());

    return Scaffold(
      backgroundColor: ThemeColor.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(controller: controller),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: ThemeColor.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: ThemeColor.primary),
                    );
                  }

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // 1. Stats & Analytics Header
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          Spacing.spacing * 2,
                          Spacing.spacing * 2,
                          Spacing.spacing * 2,
                          Spacing.spacing * 1,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: GetBuilder<YearInPixelsController>(
                            builder: (state) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _StatsStrip(
                                  currentStreak: state.currentStreak,
                                  longestStreak: state.longestStreak,
                                  totalLogged: state.totalDaysLogged,
                                  totalPeriodDays: state.totalPeriodDays,
                                ),
                                const SizedBox(height: Spacing.spacing * 2),
                                _AnalyticsSection(controller: state),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 2. Sticky Legend Header
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickyLegendDelegate(
                          controller: controller,
                          moodColors: YearInPixelsView._moodColors,
                          moodLabels: YearInPixelsView._moodLabels,
                          emptyColor: YearInPixelsView._emptyColor,
                        ),
                      ),

                      // 3. Main Display (Month Sections vs 365 Canvas Grid)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          Spacing.spacing * 2,
                          Spacing.spacing * 1,
                          Spacing.spacing * 2,
                          Spacing.spacing * 4,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: GetBuilder<YearInPixelsController>(
                            builder: (state) {
                              if (state.isCanvasView.value) {
                                return _CanvasMatrixGrid(controller: state);
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _buildMonthSections(state),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMonthSections(YearInPixelsController state) {
    final widgets = <Widget>[];
    final year = state.selectedYear.value;
    final now = DateTime.now();

    final maxMonth = year == now.year ? now.month : 12;
    final visibleMonths = <int>[
      for (int m = 1; m <= maxMonth; m++) m,
    ];

    for (int i = 0; i < visibleMonths.length; i++) {
      final month = visibleMonths[i];

      widgets.add(_MonthSection(
        controller: state,
        year: year,
        month: month,
        monthName: YearInPixelsView._months[month - 1],
        pixelMap: state.pixelMap,
        periodMap: state.periodMap,
        moodColors: YearInPixelsView._moodColors,
        emptyColor: YearInPixelsView._emptyColor,
        now: now,
        isLast: i == visibleMonths.length - 1,
      ));
    }
    return widgets;
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final YearInPixelsController controller;

  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.spacing,
        Spacing.spacing,
        Spacing.spacing * 1.5,
        Spacing.spacing * 1.5,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: ThemeColor.white, size: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YEAR IN PIXELS',
                  style: TextStyle(
                    color: ThemeColor.white.withAlpha(160),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(() => Text(
                      '${controller.selectedYear.value}',
                      style: const TextStyle(
                        color: ThemeColor.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    )),
              ],
            ),
          ),

          // View mode toggle button
          Obx(() {
            final isCanvas = controller.isCanvasView.value;
            return GestureDetector(
              onTap: controller.toggleViewMode,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: ThemeColor.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ThemeColor.white.withAlpha(60)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCanvas
                          ? Icons.calendar_view_month_rounded
                          : Icons.grid_on_rounded,
                      color: ThemeColor.white,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isCanvas ? 'Months' : '365 Grid',
                      style: const TextStyle(
                        color: ThemeColor.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(width: 8),

          // Year switcher
          Obx(() {
            final year = controller.selectedYear.value;
            final isCurrentYear = year >= DateTime.now().year;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: ThemeColor.white.withAlpha(28),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => controller.changeYear(year - 1),
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: ThemeColor.white, size: 20),
                  ),
                  Container(
                      width: 1,
                      height: 14,
                      color: ThemeColor.white.withAlpha(60)),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: isCurrentYear
                        ? null
                        : () => controller.changeYear(year + 1),
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: isCurrentYear
                          ? ThemeColor.white.withAlpha(70)
                          : ThemeColor.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Stats Strip ──────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final int totalLogged;
  final int totalPeriodDays;

  const _StatsStrip({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalLogged,
    required this.totalPeriodDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: ThemeColor.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ThemeColor.primary.withAlpha(18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatItem(
              icon: '🔥',
              value: '$currentStreak',
              label: 'Streak',
              accent: const Color(0xFFFF6B35)),
          _divider(),
          _StatItem(
              icon: '🏆',
              value: '$longestStreak',
              label: 'Best',
              accent: const Color(0xFFFFB300)),
          _divider(),
          _StatItem(
              icon: '📅',
              value: '$totalLogged',
              label: 'Days',
              accent: ThemeColor.primary),
          _divider(),
          _StatItem(
              icon: '💧',
              value: '$totalPeriodDays',
              label: 'Period',
              accent: ThemeColor.secondary_400),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 34, color: ThemeColor.neutral_100);
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color accent;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: accent,
                height: 1),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
                fontSize: 10.5,
                color: ThemeColor.neutral_400,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ── Analytics Section ────────────────────────────────────────────────────────

class _AnalyticsSection extends StatelessWidget {
  final YearInPixelsController controller;

  const _AnalyticsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.totalEntriesLogged == 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(Spacing.spacing * 2),
      decoration: BoxDecoration(
        color: ThemeColor.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeColor.primary.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'EMOTIONAL BALANCE',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: ThemeColor.neutral_400,
                ),
              ),
              const Spacer(),
              Text(
                '${controller.totalEntriesLogged} logs recorded',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ThemeColor.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Segmented progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: MoodConditions.values.map((m) {
                  final flex = (controller.moodCounts[m] ?? 0);
                  if (flex == 0) return const SizedBox();
                  return Expanded(
                    flex: flex,
                    child: Container(color: m.color),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Mood percentage breakdown chips
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: MoodConditions.values.map((m) {
              final count = controller.moodCounts[m] ?? 0;
              if (count == 0) return const SizedBox();
              final pct =
                  ((count / controller.totalEntriesLogged) * 100).round();

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: m.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${m.label} $pct%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ThemeColor.neutral_600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

          if (controller.healthInsight.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ThemeColor.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ThemeColor.primary.withAlpha(40),
                ),
              ),
              child: Text(
                controller.healthInsight,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: ThemeColor.primaryColorDark,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Sticky Legend Header Delegate ────────────────────────────────────────────

class _StickyLegendDelegate extends SliverPersistentHeaderDelegate {
  final YearInPixelsController controller;
  final Map<MoodConditions, Color> moodColors;
  final Map<MoodConditions, String> moodLabels;
  final Color emptyColor;

  _StickyLegendDelegate({
    required this.controller,
    required this.moodColors,
    required this.moodLabels,
    required this.emptyColor,
  });

  @override
  double get minExtent => 46;
  @override
  double get maxExtent => 46;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: ThemeColor.background,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Obx(() {
            final activeMood = controller.activeMoodFilter.value;
            final isPeriodActive = controller.filterPeriodOnly.value;

            return Row(
              children: [
                if (activeMood != null || isPeriodActive) ...[
                  GestureDetector(
                    onTap: controller.clearFilters,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: ThemeColor.neutral_900,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.close_rounded,
                              color: Colors.white, size: 12),
                          SizedBox(width: 3),
                          Text('Clear',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
                ...moodColors.entries.map((e) {
                  final isSelected = activeMood == e.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => controller.toggleMoodFilter(e.key),
                      child: _LegendChip(
                        color: e.value,
                        label: moodLabels[e.key]!,
                        isSelected: isSelected,
                      ),
                    ),
                  );
                }),
                GestureDetector(
                  onTap: controller.togglePeriodFilter,
                  child: _LegendChip(
                    marker: const _PeriodDot(isStart: true, size: 8),
                    label: 'Period',
                    isSelected: isPeriodActive,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyLegendDelegate oldDelegate) => true;
}

class _LegendChip extends StatelessWidget {
  final Color? color;
  final Widget? marker;
  final String label;
  final bool isSelected;

  const _LegendChip({
    this.color,
    this.marker,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? ThemeColor.primary : ThemeColor.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? ThemeColor.primary : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColor.primary.withAlpha(12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (color != null)
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 1.2)
                    : null,
              ),
            )
          else
            marker!,
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: isSelected ? Colors.white : ThemeColor.neutral_600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Period Dot ───────────────────────────────────────────────────────────────

class _PeriodDot extends StatelessWidget {
  final bool isStart;
  final double size;

  const _PeriodDot({required this.isStart, this.size = 6});

  @override
  Widget build(BuildContext context) {
    if (!isStart) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: ThemeColor.secondary_400,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: size * 0.18),
        ),
      );
    }
    return Container(
      width: size * 1.15,
      height: size * 1.15,
      decoration: BoxDecoration(
        color: ThemeColor.secondary_400,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: size * 0.22),
        boxShadow: [
          BoxShadow(
            color: ThemeColor.secondary_400.withAlpha(140),
            blurRadius: size * 0.6,
          ),
        ],
      ),
    );
  }
}

// ── Month Section ────────────────────────────────────────────────────────────

class _MonthSection extends StatelessWidget {
  final YearInPixelsController controller;
  final int year;
  final int month;
  final String monthName;
  final Map<String, MoodConditions> pixelMap;
  final Map<String, MenstrualLogModel> periodMap;
  final Map<MoodConditions, Color> moodColors;
  final Color emptyColor;
  final DateTime now;
  final bool isLast;

  const _MonthSection({
    Key? key,
    required this.controller,
    required this.year,
    required this.month,
    required this.monthName,
    required this.pixelMap,
    required this.periodMap,
    required this.moodColors,
    required this.emptyColor,
    required this.now,
    required this.isLast,
  }) : super(key: key);

  String _key(int y, int m, int d) =>
      '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final loggedDays = List.generate(daysInMonth, (i) => i + 1)
        .where((d) => pixelMap.containsKey(_key(year, month, d)))
        .length;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : Spacing.spacing * 2.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(monthName,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.neutral_900)),
              const Spacer(),
              Text(
                loggedDays > 0 ? '$loggedDays logged' : 'No logs',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: loggedDays > 0
                      ? ThemeColor.neutral_400
                      : ThemeColor.neutral_300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MonthGrid(
            controller: controller,
            year: year,
            month: month,
            pixelMap: pixelMap,
            periodMap: periodMap,
            moodColors: moodColors,
            emptyColor: emptyColor,
            now: now,
          ),
          if (!isLast) ...[
            const SizedBox(height: Spacing.spacing * 2.5),
            Container(height: 1, color: ThemeColor.neutral_100),
          ],
        ],
      ),
    );
  }
}

// ── Month Grid ───────────────────────────────────────────────────────────────

class _MonthGrid extends StatelessWidget {
  final YearInPixelsController controller;
  final int year;
  final int month;
  final Map<String, MoodConditions> pixelMap;
  final Map<String, MenstrualLogModel> periodMap;
  final Map<MoodConditions, Color> moodColors;
  final Color emptyColor;
  final DateTime now;

  const _MonthGrid({
    required this.controller,
    required this.year,
    required this.month,
    required this.pixelMap,
    required this.periodMap,
    required this.moodColors,
    required this.emptyColor,
    required this.now,
  });

  String _key(int y, int m, int d) =>
      '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

  void _inspectDay(BuildContext context, DateTime date) {
    _showDayInspectBottomSheet(context, date, controller);
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstWeekday = DateTime(year, month, 1).weekday; // 1=Mon…7=Sun
    final offset = firstWeekday - 1;
    final totalCells = offset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Obx(() {
      final activeFilter = controller.activeMoodFilter.value;
      final filterPeriod = controller.filterPeriodOnly.value;

      return Column(
        children: [
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => Expanded(
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: ThemeColor.neutral_300),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          for (int row = 0; row < rows; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: List.generate(7, (col) {
                  final cellIndex = row * 7 + col;
                  final dayNum = cellIndex - offset + 1;

                  if (dayNum < 1 || dayNum > daysInMonth) {
                    return const Expanded(child: SizedBox());
                  }

                  final date = DateTime(year, month, dayNum);
                  final isFuture = date.isAfter(now);
                  final key = _key(year, month, dayNum);

                  final periodLog = periodMap[key];
                  final dayMoods = controller.dailyMoodsMap[key] ?? [];

                  final isToday = date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;

                  // Filter check
                  bool isDimmed = false;
                  if (activeFilter != null &&
                      !dayMoods.any((m) => m.mood == activeFilter)) {
                    isDimmed = true;
                  }
                  if (filterPeriod && periodLog == null) {
                    isDimmed = true;
                  }

                  // Render mood dots chronologically for up to 3 logged moods
                  final dots = <Widget>[];
                  if (dayMoods.isNotEmpty) {
                    for (int i = 0; i < dayMoods.length && i < 3; i++) {
                      dots.add(
                        Container(
                          width: 4.5,
                          height: 4.5,
                          decoration: BoxDecoration(
                              color: moodColors[dayMoods[i].mood],
                              shape: BoxShape.circle),
                        ),
                      );
                    }
                  }
                  if (periodLog != null) {
                    dots.add(_PeriodDot(
                        isStart: periodLog.isPeriodStart, size: 4.5));
                  }

                  return Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: GestureDetector(
                        onTap:
                            isFuture ? null : () => _inspectDay(context, date),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isDimmed ? 0.2 : 1.0,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.all(1.5),
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? YearInPixelsView._periodOnlyColor
                                          .withAlpha(90)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isToday
                                      ? Border.all(
                                          color: ThemeColor.primary, width: 1.4)
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$dayNum',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isToday
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isFuture
                                            ? ThemeColor.neutral_300
                                            : ThemeColor.neutral_900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    SizedBox(
                                      height: 5,
                                      child: (dots.isNotEmpty && !isFuture)
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                for (int i = 0;
                                                    i < dots.length;
                                                    i++) ...[
                                                  if (i > 0)
                                                    const SizedBox(width: 2),
                                                  dots[i],
                                                ],
                                              ],
                                            )
                                          : const SizedBox(height: 5),
                                    ),
                                  ],
                                ),
                              ),

                              // Multi-log indicator badge (+) if 2+ logs exist
                              if (dayMoods.length > 1)
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(1),
                                    decoration: const BoxDecoration(
                                      color: ThemeColor.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 7,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      );
    });
  }
}

// ── 365 Full Canvas Grid ─────────────────────────────────────────────────────

class _CanvasMatrixGrid extends StatelessWidget {
  final YearInPixelsController controller;

  const _CanvasMatrixGrid({required this.controller});

  String _key(int y, int m, int d) =>
      '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final year = controller.selectedYear.value;
    final now = DateTime.now();

    return Obx(() {
      final activeFilter = controller.activeMoodFilter.value;
      final filterPeriod = controller.filterPeriodOnly.value;

      return Container(
        padding: const EdgeInsets.all(Spacing.spacing * 2),
        decoration: BoxDecoration(
          color: ThemeColor.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: ThemeColor.primary.withAlpha(14),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '365-DAY PIXEL CANVAS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: ThemeColor.neutral_900,
                  ),
                ),
                const Spacer(),
                Text(
                  'Year $year',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ThemeColor.neutral_400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Column Month Headers (Jan..Dec)
            Row(
              children: List.generate(12, (index) {
                return Expanded(
                  child: Text(
                    YearInPixelsView._shortMonths[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.neutral_400,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),

            // 31 Rows (Days) x 12 Columns (Months)
            Column(
              children: List.generate(31, (rowDayIndex) {
                final dayNum = rowDayIndex + 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2.5),
                  child: Row(
                    children: List.generate(12, (colMonthIndex) {
                      final monthNum = colMonthIndex + 1;
                      final daysInMonth =
                          DateUtils.getDaysInMonth(year, monthNum);

                      if (dayNum > daysInMonth) {
                        return const Expanded(child: SizedBox());
                      }

                      final date = DateTime(year, monthNum, dayNum);
                      final isFuture = date.isAfter(now);
                      final key = _key(year, monthNum, dayNum);

                      final mood = controller.pixelMap[key];
                      final periodLog = controller.periodMap[key];
                      final dayMoods = controller.dailyMoodsMap[key] ?? [];

                      final color = isFuture
                          ? Colors.transparent
                          : mood != null
                              ? mood.color
                              : (periodLog != null
                                  ? YearInPixelsView._periodOnlyColor
                                  : YearInPixelsView._emptyColor);

                      // Filter check
                      bool isDimmed = false;
                      if (activeFilter != null &&
                          !dayMoods.any((m) => m.mood == activeFilter)) {
                        isDimmed = true;
                      }
                      if (filterPeriod && periodLog == null) {
                        isDimmed = true;
                      }

                      return Expanded(
                        child: GestureDetector(
                          onTap: isFuture
                              ? null
                              : () => _showDayInspectBottomSheet(
                                  context, date, controller),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isDimmed ? 0.2 : 1.0,
                            child: Stack(
                              children: [
                                Container(
                                  height: 14,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                if (dayMoods.length > 1)
                                  Positioned(
                                    top: 1,
                                    right: 2,
                                    child: Container(
                                      width: 3,
                                      height: 3,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}

// ── Day Inspect Bottom Sheet (Chronological Timeline) ─────────────────────────

void _showDayInspectBottomSheet(
  BuildContext context,
  DateTime date,
  YearInPixelsController controller,
) {
  final key =
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  final moodList = controller.dailyMoodsMap[key] ?? [];
  final periodModel = controller.periodMap[key];

  final dateFormatted =
      '${date.day} ${YearInPixelsView._months[date.month - 1]} ${date.year}';

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(Spacing.spacing * 3),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: ThemeColor.neutral_200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Date Header & Log Count
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 18, color: ThemeColor.primary),
              const SizedBox(width: 8),
              Text(
                dateFormatted,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeColor.neutral_900,
                ),
              ),
              const Spacer(),
              if (moodList.isNotEmpty || periodModel != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ThemeColor.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    moodList.length > 1
                        ? '${moodList.length} Entries'
                        : 'Recorded',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (moodList.isEmpty && periodModel == null) ...[
                    const Center(
                      child: Column(
                        children: [
                          Text('✏️', style: TextStyle(fontSize: 32)),
                          SizedBox(height: 8),
                          Text(
                            'No mood logged for this day',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ThemeColor.neutral_600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.back();
                              RecordController.to.selectedDate = date;
                              Get.to(() => const MoodWizardView());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeColor.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded,
                                color: Colors.white, size: 18),
                            label: const Text(
                              'Log Mood ✨',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Get.back();
                              final menstrualCtrl =
                                  Get.isRegistered<MenstrualLogController>()
                                      ? Get.find<MenstrualLogController>()
                                      : Get.put(MenstrualLogController());
                              menstrualCtrl.selectedDate = date;
                              Get.to(
                                  () => AddMenstrualLogView(initialDate: date));
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(
                                  color: ThemeColor.secondary_400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Text('💧',
                                style: TextStyle(fontSize: 14)),
                            label: const Text(
                              'Log Period 🩸',
                              style: TextStyle(
                                color: ThemeColor.secondary_400,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Chronological Mood Timeline
                    if (moodList.isNotEmpty) ...[
                      const Text(
                        'DAILY MOOD TIMELINE',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: ThemeColor.neutral_400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: moodList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final mood = moodList[index];
                          final timeStr =
                              DateFormat('hh:mm a').format(mood.createdAt);

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: ThemeColor.neutral_50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: mood.mood.color.withAlpha(50),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: mood.mood.color.withAlpha(25),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        timeStr,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: mood.mood.color,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        Get.back();
                                        Get.to(
                                            () => MoodDetailView(record: mood));
                                      },
                                      child: const Row(
                                        children: [
                                          Text(
                                            'View Details',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: ThemeColor.primary,
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            size: 16,
                                            color: ThemeColor.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      _getEmojiForMood(mood.mood),
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mood.mood.label,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: mood.mood.color,
                                          ),
                                        ),
                                        if (mood.title.isNotEmpty)
                                          Text(
                                            mood.title,
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: ThemeColor.neutral_900,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (mood.emotions.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Feeling: ${mood.emotions}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: ThemeColor.neutral_600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                if (mood.note.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '"${mood.note}"',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: ThemeColor.neutral_700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ],

                    // Period Details Card
                    if (periodModel != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ThemeColor.secondary_400.withAlpha(20),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ThemeColor.secondary_400.withAlpha(60),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('💧', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    periodModel.isPeriodStart
                                        ? 'Period Start (Day 1)'
                                        : 'Period Flow: ${periodModel.flow.capitalizeFirst}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: ThemeColor.secondary_400,
                                    ),
                                  ),
                                  if (periodModel.symptoms.isNotEmpty)
                                    Text(
                                      'Symptoms: ${periodModel.symptoms.join(", ")}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: ThemeColor.neutral_600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Get.back();
                              RecordController.to.selectedDate = date;
                              Get.to(() => const MoodWizardView());
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: ThemeColor.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded,
                                color: ThemeColor.primary, size: 18),
                            label: const Text(
                              'Add Mood +',
                              style: TextStyle(
                                color: ThemeColor.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Get.back();
                              final menstrualCtrl =
                                  Get.isRegistered<MenstrualLogController>()
                                      ? Get.find<MenstrualLogController>()
                                      : Get.put(MenstrualLogController());
                              menstrualCtrl.selectedDate = date;
                              Get.to(
                                  () => AddMenstrualLogView(initialDate: date));
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(
                                  color: ThemeColor.secondary_400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Text('💧',
                                style: TextStyle(fontSize: 14)),
                            label: Text(
                              periodModel == null
                                  ? 'Log Period 🩸'
                                  : 'Edit Period 🩸',
                              style: const TextStyle(
                                color: ThemeColor.secondary_400,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

String _getEmojiForMood(MoodConditions mood) {
  switch (mood) {
    case MoodConditions.happy:
      return '😊';
    case MoodConditions.cheerful:
      return '🥰';
    case MoodConditions.excited:
      return '🤩';
    case MoodConditions.sad:
      return '😢';
    case MoodConditions.tired:
      return '😴';
  }
}
