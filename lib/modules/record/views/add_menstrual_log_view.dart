import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moodie/modules/record/controllers/menstrual_log_controller.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';

class AddMenstrualLogView extends StatefulWidget {
  final DateTime? initialDate;
  const AddMenstrualLogView({Key? key, this.initialDate}) : super(key: key);

  @override
  State<AddMenstrualLogView> createState() => _AddMenstrualLogViewState();
}

class _AddMenstrualLogViewState extends State<AddMenstrualLogView> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final List<String> _stepTitles = [
    'Date & Period Status',
    'Flow & Symptoms',
    'Notes & Submission',
  ];

  @override
  void initState() {
    super.initState();
    final controller = Get.put(MenstrualLogController());
    if (widget.initialDate != null) {
      controller.selectedDate = widget.initialDate!;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(MenstrualLogController controller) {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      controller.handleSaveMenstrualLogFlow();
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.back();
    }
  }

  LinearGradient _getStepGradient() {
    switch (_currentStep) {
      case 0:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFCE4EC),
            Color(0xFFF8BBD0),
            ThemeColor.background,
          ],
        );
      case 1:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF3E5F5),
            Color(0xFFE1BEE7),
            ThemeColor.background,
          ],
        );
      case 2:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEDE7F6),
            Color(0xFFD1C4E9),
            ThemeColor.background,
          ],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFCE4EC),
            Color(0xFFF8BBD0),
            ThemeColor.background,
          ],
        );
    }
  }

  Color _getThemeAccent() {
    switch (_currentStep) {
      case 0:
        return const Color(0xFFE91E63);
      case 1:
        return ThemeColor.purple_400;
      case 2:
        return ThemeColor.primary;
      default:
        return ThemeColor.purple_400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenstrualLogController>(
      init: MenstrualLogController(),
      id: 'menstrual_form',
      builder: (controller) {
        final accentColor = _getThemeAccent();

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: _getStepGradient(),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Top Navigation & Step Indicator
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.spacing * 2,
                          vertical: Spacing.spacing * 1.5,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _prevPage,
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: ThemeColor.neutral_900,
                                size: 20,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _stepTitles[_currentStep],
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color: ThemeColor.neutral_900,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    accentColor.withAlpha((0.15 * 255).toInt()),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_currentStep + 1} of 3',
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Animated Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.spacing * 3,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: 6,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: ThemeColor.neutral_200
                                    .withAlpha((0.6 * 255).toInt()),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 6,
                              width: MediaQuery.of(context).size.width *
                                  ((_currentStep + 1) / 3),
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: Spacing.spacing * 2),

                      // PageView Steps Content (Swipeable)
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentStep = index;
                            });
                          },
                          physics: const BouncingScrollPhysics(),
                          children: [
                            // Step 1: Date & Period Start Toggle
                            _buildStep1(controller, accentColor),

                            // Step 2: Flow Intensity & Symptoms
                            _buildStep2(controller, accentColor),

                            // Step 3: Additional Notes & Submit
                            _buildStep3(controller, accentColor),
                          ],
                        ),
                      ),

                      // Bottom Action Buttons
                      Container(
                        padding: const EdgeInsets.all(Spacing.spacing * 2.5),
                        decoration: BoxDecoration(
                          color:
                              ThemeColor.white.withAlpha((0.92 * 255).toInt()),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withAlpha((0.04 * 255).toInt()),
                              blurRadius: 10,
                              offset: const Offset(0, -4),
                            ),
                          ],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          children: [
                            if (_currentStep > 0) ...[
                              Expanded(
                                flex: 1,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side: const BorderSide(
                                        color: ThemeColor.neutral_400),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: _prevPage,
                                  child: const Text(
                                    'Back',
                                    style: TextStyle(
                                      color: ThemeColor.neutral_700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 2,
                                  shadowColor: accentColor
                                      .withAlpha((0.4 * 255).toInt()),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () => _nextPage(controller),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: ThemeColor.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _currentStep == 2
                                            ? 'Save Menstrual Log ✨'
                                            : 'Continue →',
                                        style: const TextStyle(
                                          color: ThemeColor.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // STEP 1: Date & Period Status
  Widget _buildStep1(MenstrualLogController controller, Color accentColor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.spacing * 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: Spacing.spacing * 2),

          // Central Hero Water Drop/Lotus Icon with Aura
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withAlpha((0.12 * 255).toInt()),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withAlpha((0.35 * 255).toInt()),
                  blurRadius: 35,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.water_drop_rounded,
                size: 80,
                color: accentColor,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Track Your Cycle',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: ThemeColor.neutral_900,
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: Spacing.spacing * 3),

          // Date Selector Card
          Container(
            padding: const EdgeInsets.all(Spacing.spacing * 2.5),
            decoration: BoxDecoration(
              color: ThemeColor.white.withAlpha((0.9 * 255).toInt()),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.04 * 255).toInt()),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log Date',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: ThemeColor.neutral_900,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMM d, yyyy')
                          .format(controller.selectedDate),
                      style: const TextStyle(
                        color: ThemeColor.neutral_600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        accentColor.withAlpha((0.15 * 255).toInt()),
                    elevation: 0,
                    foregroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      controller.selectedDate = picked;
                      controller.update(['menstrual_form']);
                    }
                  },
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: const Text(
                    'Change',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Spacing.spacing * 3),

          // Period Start Switch Card
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.spacing * 2.5,
                vertical: Spacing.spacing * 1.5,
              ),
              decoration: BoxDecoration(
                color: ThemeColor.white.withAlpha((0.9 * 255).toInt()),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.04 * 255).toInt()),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        accentColor.withAlpha((0.15 * 255).toInt()),
                    child: Icon(Icons.opacity_rounded, color: accentColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'First Day of Period?',
                          style:
                              Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Mark if your period started today',
                          style: TextStyle(
                            color: ThemeColor.neutral_500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: controller.isPeriodStart.value,
                    activeThumbColor: accentColor,
                    onChanged: (val) {
                      controller.setPeriodStart(val);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: Spacing.spacing * 2),
        ],
      ),
    );
  }

  // STEP 2: Flow Intensity & Symptoms
  Widget _buildStep2(MenstrualLogController controller, Color accentColor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.spacing * 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Spacing.spacing),

          // Flow Intensity Section
          Text(
            'Flow Intensity',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: ThemeColor.neutral_900,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select how heavy your flow is today:',
            style: TextStyle(color: ThemeColor.neutral_600, fontSize: 13),
          ),
          const SizedBox(height: Spacing.spacing * 1.5),

          Obx(
            () => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Spacing.spacing * 2),
              decoration: BoxDecoration(
                color: ThemeColor.white.withAlpha((0.9 * 255).toInt()),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.04 * 255).toInt()),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.flowOptions.map((flowOption) {
                  final isSelected = controller.flow.value == flowOption;
                  return ChoiceChip(
                    label: Text(
                      flowOption.capitalizeFirst!,
                      style: TextStyle(
                        color: isSelected
                            ? ThemeColor.white
                            : ThemeColor.neutral_900,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: accentColor,
                    backgroundColor:
                        ThemeColor.neutral_200.withAlpha((0.8 * 255).toInt()),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    onSelected: (bool selected) {
                      if (selected) {
                        controller.setFlow(flowOption);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: Spacing.spacing * 3),

          // Symptoms Section
          Text(
            'Physical Symptoms',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: ThemeColor.neutral_900,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select all symptoms you are experiencing:',
            style: TextStyle(color: ThemeColor.neutral_600, fontSize: 13),
          ),
          const SizedBox(height: Spacing.spacing * 1.5),

          Obx(
            () => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Spacing.spacing * 2),
              decoration: BoxDecoration(
                color: ThemeColor.white.withAlpha((0.9 * 255).toInt()),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.04 * 255).toInt()),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.availableSymptoms.map((symptom) {
                  final isSelected = controller.symptoms.contains(symptom);
                  return FilterChip(
                    label: Text(
                      symptom,
                      style: TextStyle(
                        color: isSelected
                            ? ThemeColor.white
                            : ThemeColor.neutral_900,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: accentColor,
                    backgroundColor:
                        ThemeColor.neutral_200.withAlpha((0.8 * 255).toInt()),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    onSelected: (_) {
                      controller.toggleSymptom(symptom);
                    },
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: Spacing.spacing * 3),
        ],
      ),
    );
  }

  // STEP 3: Additional Notes & Review
  Widget _buildStep3(MenstrualLogController controller, Color accentColor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.spacing * 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Spacing.spacing),
          Text(
            'Cycle Summary & Notes',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: ThemeColor.neutral_900,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add optional notes or observations for your doctor/log:',
            style: TextStyle(color: ThemeColor.neutral_600, fontSize: 13),
          ),
          const SizedBox(height: Spacing.spacing * 2),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(Spacing.spacing * 2),
            decoration: BoxDecoration(
              color: ThemeColor.white.withAlpha((0.9 * 255).toInt()),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.04 * 255).toInt()),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Date:',
                        style: TextStyle(
                            color: ThemeColor.neutral_600,
                            fontWeight: FontWeight.w500)),
                    Text(
                      DateFormat('yyyy-MM-dd').format(controller.selectedDate),
                      style: const TextStyle(
                          color: ThemeColor.neutral_900,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Flow:',
                        style: TextStyle(
                            color: ThemeColor.neutral_600,
                            fontWeight: FontWeight.w500)),
                    Obx(
                      () => Text(
                        controller.flow.value.capitalizeFirst!,
                        style: TextStyle(
                            color: accentColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Period Start:',
                        style: TextStyle(
                            color: ThemeColor.neutral_600,
                            fontWeight: FontWeight.w500)),
                    Obx(
                      () => Text(
                        controller.isPeriodStart.value ? 'Yes 🌸' : 'No',
                        style: const TextStyle(
                            color: ThemeColor.neutral_900,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (controller.symptoms.isNotEmpty) ...[
                  const Divider(height: 16),
                  const Text('Symptoms:',
                      style: TextStyle(
                          color: ThemeColor.neutral_600,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Obx(
                    () => Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: controller.symptoms
                          .map((s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accentColor
                                      .withAlpha((0.12 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: Spacing.spacing * 2.5),

          // Notes Input
          TextFormField(
            controller: controller.noteController,
            maxLines: 5,
            style: const TextStyle(color: ThemeColor.neutral_900),
            decoration: InputDecoration(
              hintText: 'Additional notes or symptoms details...',
              hintStyle: const TextStyle(color: ThemeColor.neutral_400),
              contentPadding: const EdgeInsets.all(18),
              fillColor: ThemeColor.white.withAlpha((0.9 * 255).toInt()),
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: ThemeColor.neutral_200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: accentColor,
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: Spacing.spacing * 3),
        ],
      ),
    );
  }
}
