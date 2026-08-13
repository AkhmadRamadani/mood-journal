import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moodie/modules/record/controllers/menstrual_log_controller.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';

class AddMenstrualLogView extends StatelessWidget {
  const AddMenstrualLogView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenstrualLogController>(
      init: MenstrualLogController(),
      id: 'menstrual_form',
      builder: (controller) {
        return Container(
          decoration: const BoxDecoration(
            color: ThemeColor.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(CustomRadius.defaultRadius),
              topRight: Radius.circular(CustomRadius.defaultRadius),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: Spacing.spacing),
                const Icon(Icons.keyboard_arrow_down),
                const SizedBox(height: Spacing.spacing),
                Text(
                  'Add Menstrual Log',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: ThemeColor.neutral_900,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: Spacing.spacing * 2),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.spacing * 2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date picker row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ThemeColor.neutral_900,
                              ),
                            ),
                            InkWell(
                              onTap: () async {
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
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: ThemeColor.neutral_200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: ThemeColor.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('yyyy-MM-dd')
                                          .format(controller.selectedDate),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: ThemeColor.neutral_900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.spacing * 3),

                        // Flow selection
                        const Text(
                          'Flow Intensity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColor.neutral_900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.flowOptions.map((flowOption) {
                              final isSelected =
                                  controller.flow.value == flowOption;
                              return ChoiceChip(
                                label: Text(
                                  flowOption.capitalizeFirst!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? ThemeColor.white
                                        : ThemeColor.neutral_900,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: ThemeColor.primary,
                                backgroundColor: ThemeColor.neutral_200,
                                onSelected: (bool selected) {
                                  if (selected) {
                                    controller.setFlow(flowOption);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: Spacing.spacing * 3),

                        // Symptoms multi-select
                        const Text(
                          'Symptoms',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColor.neutral_900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                controller.availableSymptoms.map((symptom) {
                              final isSelected =
                                  controller.symptoms.contains(symptom);
                              return FilterChip(
                                label: Text(
                                  symptom,
                                  style: TextStyle(
                                    color: isSelected
                                        ? ThemeColor.white
                                        : ThemeColor.neutral_900,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: ThemeColor.purple_400,
                                backgroundColor: ThemeColor.neutral_200,
                                onSelected: (_) {
                                  controller.toggleSymptom(symptom);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: Spacing.spacing * 3),

                        // Period Start Toggle
                        Obx(
                          () => Container(
                            decoration: BoxDecoration(
                              color: ThemeColor.neutral_200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SwitchListTile(
                              title: const Text(
                                'First Day of Period?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: ThemeColor.neutral_900,
                                ),
                              ),
                              activeColor: ThemeColor.primary,
                              value: controller.isPeriodStart.value,
                              onChanged: (val) {
                                controller.setPeriodStart(val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: Spacing.spacing * 3),

                        // Note input
                        TextFormField(
                          maxLines: 4,
                          controller: controller.noteController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(16),
                            fillColor: ThemeColor.neutral_200,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: ThemeColor.primary,
                              ),
                            ),
                            hintText: 'Additional notes or symptoms...',
                          ),
                        ),
                        const SizedBox(height: Spacing.spacing * 4),

                        // Next / Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeColor.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    controller.handleSaveMenstrualLogFlow();
                                  },
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: ThemeColor.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Save Log",
                                    style: TextStyle(
                                      color: ThemeColor.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: Spacing.spacing * 3),
                      ],
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
}
