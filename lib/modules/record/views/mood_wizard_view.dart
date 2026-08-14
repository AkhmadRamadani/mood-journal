import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:moodie/constants/asset_const.dart';
import 'package:moodie/modules/record/controllers/record_controller.dart';
import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:moodie/shared/widgets/buttons/voice_dictation_button.dart';
import 'package:moodie/shared/widgets/cards/emotions_card.dart';

class MoodWizardView extends StatefulWidget {
  const MoodWizardView({Key? key}) : super(key: key);

  @override
  State<MoodWizardView> createState() => _MoodWizardViewState();
}

class _MoodWizardViewState extends State<MoodWizardView> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  double _intensity = 0.5;

  final List<String> _stepTitles = [
    'How are you feeling?',
    'Pick your emotions',
    'Write your journal',
  ];

  @override
  void initState() {
    super.initState();
    final recordController = Get.put(RecordController());
    if (recordController.editingMoodModel != null) {
      _intensity = recordController.intensity;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(RecordController controller) {
    if (_currentStep == 0) {
      if (controller.mood == null) {
        Get.snackbar(
          'Select Mood',
          'Please select how you are feeling to continue',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeColor.redColor,
          colorText: ThemeColor.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (controller.emotions.isEmpty) {
        Get.snackbar(
          'Select Emotion',
          'Please pick at least one emotion tag',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeColor.redColor,
          colorText: ThemeColor.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }
    }

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      controller.addMood();
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

  String _getLottiePath(MoodConditions? mood) {
    switch (mood) {
      case MoodConditions.tired:
        return AssetConst.cryingAnimation;
      case MoodConditions.sad:
        return AssetConst.sadAnimation;
      case MoodConditions.excited:
        return AssetConst.winkingAnimation;
      case MoodConditions.cheerful:
        return AssetConst.blushingAnimation;
      case MoodConditions.happy:
        return AssetConst.smileyAnimation;
      default:
        return AssetConst.smileyAnimation;
    }
  }

  String _getMoodName(MoodConditions? mood) {
    if (mood == null) return 'Select a Mood';
    switch (mood) {
      case MoodConditions.tired:
        return 'Tired';
      case MoodConditions.sad:
        return 'Sad';
      case MoodConditions.excited:
        return 'Excited';
      case MoodConditions.cheerful:
        return 'Cheerful';
      case MoodConditions.happy:
        return 'Happy';
    }
  }

  LinearGradient _getMoodGradient(MoodConditions? mood) {
    switch (mood) {
      case MoodConditions.tired:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEDE7F6),
            Color(0xFFD1C4E9),
            ThemeColor.background,
          ],
        );
      case MoodConditions.sad:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE3F2FD),
            Color(0xFFBBDEFB),
            ThemeColor.background,
          ],
        );
      case MoodConditions.excited:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF3E0),
            Color(0xFFFFE0B2),
            ThemeColor.background,
          ],
        );
      case MoodConditions.cheerful:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFCE4EC),
            Color(0xFFF8BBD0),
            ThemeColor.background,
          ],
        );
      case MoodConditions.happy:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8F5E9),
            Color(0xFFC8E6C9),
            ThemeColor.background,
          ],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF0F4FE),
            Color(0xFFE8ECFA),
            ThemeColor.background,
          ],
        );
    }
  }

  Color _getMoodAuraColor(MoodConditions? mood) {
    return mood?.color ?? ThemeColor.primary;
  }

  @override
  Widget build(BuildContext context) {
    final recordController = Get.put(RecordController());

    return GetBuilder<RecordController>(
      id: 'mood',
      builder: (state) {
        final currentMood = state.mood;

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: _getMoodGradient(currentMood),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Top App Bar & Progress
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
                                color: _getMoodAuraColor(currentMood)
                                    .withAlpha((0.15 * 255).toInt()),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_currentStep + 1} of 3',
                                style: TextStyle(
                                  color: _getMoodAuraColor(currentMood),
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
                                color: _getMoodAuraColor(currentMood),
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
                            // Step 1: Mood & Intensity
                            _buildStep1(recordController),

                            // Step 2: Pick Emotions
                            _buildStep2(recordController),

                            // Step 3: Journal Note
                            _buildStep3(recordController),
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
                                  backgroundColor:
                                      _getMoodAuraColor(currentMood),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 2,
                                  shadowColor: _getMoodAuraColor(currentMood)
                                      .withAlpha((0.4 * 255).toInt()),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () => _nextPage(recordController),
                                child: Text(
                                  _currentStep == 2
                                      ? 'Save Mood ✨'
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

                  // Loading overlay
                  GetBuilder<RecordController>(
                    id: 'addMood',
                    builder: (state) {
                      if (state.isLoadingInsert.value) {
                        return Container(
                          color: Colors.black.withAlpha((0.3 * 255).toInt()),
                          child: Center(
                            child: Lottie.asset(
                              AssetConst.animationLoading,
                              width: 60,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // STEP 1: Mood Selection + Hero Preview + Slider
  Widget _buildStep1(RecordController controller) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.spacing * 3),
      child: GetBuilder<RecordController>(
        id: 'mood',
        builder: (state) {
          final currentMood = state.mood;
          final auraColor = _getMoodAuraColor(currentMood);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: Spacing.spacing * 2),

              // Hero Large Animated Emoji with Dynamic Glowing Aura
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: auraColor.withAlpha((0.12 * 255).toInt()),
                  boxShadow: [
                    BoxShadow(
                      color: auraColor.withAlpha((0.4 * 255).toInt()),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: auraColor.withAlpha((0.2 * 255).toInt()),
                      blurRadius: 70,
                      spreadRadius: 15,
                    ),
                  ],
                ),
                child: Center(
                  child: currentMood != null
                      ? Lottie.asset(
                          _getLottiePath(currentMood),
                          width: 120,
                          height: 120,
                        )
                      : Icon(
                          Icons.sentiment_satisfied_alt_rounded,
                          size: 90,
                          color: auraColor,
                        ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                _getMoodName(currentMood),
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: ThemeColor.neutral_900,
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: Spacing.spacing * 3),

              // Horizontal Emoji Picker Row
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: MoodConditions.values.map((moodItem) {
                    final isSelected = currentMood == moodItem;
                    final itemAura = _getMoodAuraColor(moodItem);

                    return GestureDetector(
                      onTap: () {
                        state.setMood(moodItem);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? itemAura.withAlpha((0.18 * 255).toInt())
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(color: itemAura, width: 2.5)
                              : Border.all(color: Colors.transparent),
                        ),
                        child: Lottie.asset(
                          _getLottiePath(moodItem),
                          width: isSelected ? 48 : 38,
                          height: isSelected ? 48 : 38,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: Spacing.spacing * 4),

              // Feeling Intensity Slider
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Feeling Intensity',
                          style:
                              Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          _intensity < 0.35
                              ? 'Mild 🍃'
                              : _intensity < 0.7
                                  ? 'Moderate ⚡'
                                  : 'Intense 🔥',
                          style: TextStyle(
                            color: auraColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GetBuilder<RecordController>(
                      id: 'intensity',
                      builder: (state) {
                        return SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: auraColor,
                            inactiveTrackColor: ThemeColor.neutral_200,
                            thumbColor: auraColor,
                            overlayColor:
                                auraColor.withAlpha((0.2 * 255).toInt()),
                            trackHeight: 6,
                          ),
                          child: Slider(
                            value: state.intensity,
                            onChanged: (val) {
                              setState(() {
                                _intensity = val;
                              });
                              state.setIntensity(val);
                            },
                          ),
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Mild',
                              style: TextStyle(
                                  color: ThemeColor.neutral_500, fontSize: 12)),
                          Text('Moderate',
                              style: TextStyle(
                                  color: ThemeColor.neutral_500, fontSize: 12)),
                          Text('Intense',
                              style: TextStyle(
                                  color: ThemeColor.neutral_500, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Spacing.spacing * 2),
            ],
          );
        },
      ),
    );
  }

  // STEP 2: Emotion Chip Tags Picker (Multi-Select)
  Widget _buildStep2(RecordController controller) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.spacing * 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Spacing.spacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Select tags that describe what you feel (multiple selection):',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: ThemeColor.neutral_700,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              GetBuilder<RecordController>(
                id: 'emotions',
                builder: (state) {
                  final count = state.selectedEmotions.length;
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ThemeColor.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      ' selected',
                      style: TextStyle(
                        color: ThemeColor.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: Spacing.spacing * 2),
          GetBuilder<RecordController>(
            id: 'emotions',
            builder: (state) {
              return Container(
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
                child: Emotions(
                  selectedEmotions: state.selectedEmotions,
                  onEmotionToggled: (emotion) {
                    state.toggleEmotion(emotion);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: Spacing.spacing * 3),
        ],
      ),
    );
  }

  // STEP 3: Journal Title & Note Input
  Widget _buildStep3(RecordController controller) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.spacing * 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Spacing.spacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Express your thoughts and capture this moment:',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: ThemeColor.neutral_700,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              VoiceDictationButton(
                targetController: controller.noteController,
              ),
            ],
          ),
          const SizedBox(height: Spacing.spacing * 2),

          // Title Input
          TextFormField(
            controller: controller.titleController,
            style: const TextStyle(
              color: ThemeColor.neutral_900,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Entry Title (e.g. Great Workout, Quiet Evening)',
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
                  color: _getMoodAuraColor(controller.mood),
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: Spacing.spacing * 2.5),

          // Note Multiline Input
          TextFormField(
            controller: controller.noteController,
            maxLines: 7,
            style: const TextStyle(color: ThemeColor.neutral_900),
            decoration: InputDecoration(
              hintText: 'Write down what happened or how you feel...',
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
                  color: _getMoodAuraColor(controller.mood),
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
