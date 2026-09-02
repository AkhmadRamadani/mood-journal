import 'package:flutter/material.dart';
import 'package:moodie/modules/quick_log/controllers/quick_log_controller.dart';
import 'package:moodie/modules/quick_log/domain/tool_call.dart';
import 'package:moodie/shared/themes/colors.dart';

/// Confirmation and review bottom sheet for detected Quick Log actions.
class QuickLogConfirmSheet extends StatefulWidget {
  final ParsedQuickLogResult result;

  const QuickLogConfirmSheet({super.key, required this.result});

  static Future<void> show(BuildContext context, ParsedQuickLogResult result) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickLogConfirmSheet(result: result),
    );
  }

  @override
  State<QuickLogConfirmSheet> createState() => _QuickLogConfirmSheetState();
}

class _QuickLogConfirmSheetState extends State<QuickLogConfirmSheet> {
  late List<ToolCall> _activeCalls;

  @override
  void initState() {
    super.initState();
    _activeCalls = List.from(widget.result.toolCalls);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: ThemeColor.neutral_300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeColor.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: ThemeColor.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirm Quick Log',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ThemeColor.neutral_900,
                      ),
                    ),
                    Text(
                      'Extracted with on-device Needle AI',
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColor.neutral_500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Original query preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: ThemeColor.neutral_100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '"${widget.result.rawQuery}"',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 13,
                color: ThemeColor.neutral_700,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Detected tool call cards
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _activeCalls.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final call = _activeCalls[index];
                return _buildCallCard(call, index);
              },
            ),
          ),
          const SizedBox(height: 20),

          // Confirm buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: ThemeColor.neutral_300),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: ThemeColor.neutral_700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await QuickLogController.to.executeToolCalls(_activeCalls);
                    QuickLogController.to.textController.clear();
                  },
                  child: const Text(
                    'Log All',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCallCard(ToolCall call, int index) {
    if (call is MoodLogToolCall) {
      return _buildMoodCard(call, index);
    } else if (call is WaterLogToolCall) {
      return _buildWaterCard(call, index);
    } else if (call is CycleSymptomToolCall) {
      return _buildCycleCard(call, index);
    }
    return const SizedBox.shrink();
  }

  Widget _buildMoodCard(MoodLogToolCall call, int index) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                call.displayLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF6D4C41),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close,
                    size: 18, color: ThemeColor.neutral_500),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() => _activeCalls.removeAt(index));
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Intensity: ',
                  style:
                      TextStyle(fontSize: 12, color: ThemeColor.neutral_600)),
              ...List.generate(5, (i) {
                final starLevel = i + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeCalls[index] = MoodLogToolCall(
                        mood: call.mood,
                        intensity: starLevel,
                        confidence: call.confidence,
                      );
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(
                      starLevel <= call.intensity
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: const Color(0xFFFFA000),
                      size: 22,
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterCard(WaterLogToolCall call, int index) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  call.displayLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  '${call.ml} ml total',
                  style: const TextStyle(
                      fontSize: 12, color: ThemeColor.neutral_600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline,
                size: 22, color: ThemeColor.neutral_600),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              if (call.glasses > 1) {
                setState(() {
                  _activeCalls[index] = WaterLogToolCall(
                    glasses: call.glasses - 1,
                    confidence: call.confidence,
                  );
                });
              }
            },
          ),
          const SizedBox(width: 8),
          Text(
            '${call.glasses}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                size: 22, color: ThemeColor.neutral_600),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _activeCalls[index] = WaterLogToolCall(
                  glasses: call.glasses + 1,
                  confidence: call.confidence,
                );
              });
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close,
                size: 18, color: ThemeColor.neutral_500),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() => _activeCalls.removeAt(index));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCycleCard(CycleSymptomToolCall call, int index) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF8B4B4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                call.displayLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF9B1C1C),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close,
                    size: 18, color: ThemeColor.neutral_500),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() => _activeCalls.removeAt(index));
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Severity: ',
                  style:
                      TextStyle(fontSize: 12, color: ThemeColor.neutral_600)),
              ...List.generate(5, (i) {
                final lvl = i + 1;
                final isSelected = lvl == call.severity;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeCalls[index] = CycleSymptomToolCall(
                        symptom: call.symptom,
                        severity: lvl,
                        confidence: call.confidence,
                      );
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFF9B1C1C) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF9B1C1C)
                            : ThemeColor.neutral_300,
                      ),
                    ),
                    child: Text(
                      '$lvl',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            isSelected ? Colors.white : ThemeColor.neutral_700,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
