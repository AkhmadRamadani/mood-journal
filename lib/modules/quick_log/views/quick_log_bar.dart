import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/modules/quick_log/controllers/quick_log_controller.dart';
import 'package:moodie/modules/quick_log/views/quick_log_confirm_sheet.dart';
import 'package:moodie/shared/themes/colors.dart';

/// Interactive AI Quick Log input bar embedded on the dashboard.
///
/// Converts natural language (typed or spoken) into on-device structured logs.
class QuickLogBar extends StatelessWidget {
  const QuickLogBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = QuickLogController.to;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border:
            Border.all(color: ThemeColor.neutral_200.withValues(alpha: 0.8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          // AI Sparkle indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeColor.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: ThemeColor.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),

          // Text Field
          Expanded(
            child: TextField(
              controller: controller.textController,
              textInputAction: TextInputAction.send,
              onSubmitted: (value) async {
                final result = await controller.processInput(value,
                    autoExecuteIfConfident: false);
                if (result.isNotEmpty && context.mounted) {
                  QuickLogConfirmSheet.show(context, result);
                }
              },
              style: const TextStyle(
                fontSize: 14,
                color: ThemeColor.neutral_900,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: 'Quick log: "anxious 4, drank 2 glasses"...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: ThemeColor.neutral_400,
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),

          // Voice / Send buttons
          Obx(() {
            if (controller.isParsing.value || controller.isLogging.value) {
              return const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ThemeColor.primary,
                ),
              );
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Voice Mic Button
                IconButton(
                  icon: Icon(
                    controller.isListening.value
                        ? Icons.mic_rounded
                        : Icons.mic_none_rounded,
                    color: controller.isListening.value
                        ? Colors.redAccent
                        : ThemeColor.neutral_500,
                    size: 22,
                  ),
                  tooltip: 'Voice Dictation',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: controller.toggleVoice,
                ),

                // Submit Button
                IconButton(
                  icon: const Icon(
                    Icons.arrow_upward_rounded,
                    color: ThemeColor.primary,
                    size: 20,
                  ),
                  tooltip: 'Log',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: () async {
                    final text = controller.textController.text;
                    if (text.trim().isEmpty) return;
                    final result = await controller.processInput(text,
                        autoExecuteIfConfident: false);
                    if (result.isNotEmpty && context.mounted) {
                      QuickLogConfirmSheet.show(context, result);
                    }
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
