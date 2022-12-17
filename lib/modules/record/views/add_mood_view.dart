import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moodie/constants/asset_const.dart';
import 'package:moodie/modules/record/controllers/record_controller.dart';
import 'package:moodie/modules/record/views/add_mood_desc.dart';
import 'package:moodie/shared/enum/mood_enum.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:get/get.dart';
import 'package:moodie/shared/widgets/cards/emotions_card.dart';
import 'package:moodie/shared/widgets/cards/mood_emoticon.dart';
import 'package:moodie/shared/widgets/cards/select_mood_card.dart';

class AddMood extends StatelessWidget {
  const AddMood({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // RecordController recordController = Get.put(RecordController());
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: Spacing.spacing,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(Spacing.spacing * 2),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: ThemeColor.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(CustomRadius.defaultRadius),
                    topRight: Radius.circular(CustomRadius.defaultRadius),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.keyboard_arrow_down),
                      Container(
                        margin: const EdgeInsets.only(
                          top: Spacing.spacing * 2,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'What is your mood ?',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                            ),
                            GetBuilder<RecordController>(
                              id: 'mood',
                              builder: (state) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: Spacing.spacing,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Emoji 1
                                      GestureDetector(
                                        onTap: () {
                                          state.setMood(MoodConditions.tired);
                                        },
                                        child: MoodEmoticon(
                                          location: AssetConst.cryingAnimation,
                                          isSelected: state.mood ==
                                              MoodConditions.tired,
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 3,
                                      ),

                                      // Emoji 2
                                      GestureDetector(
                                        onTap: () {
                                          state.setMood(MoodConditions.sad);
                                        },
                                        child: MoodEmoticon(
                                          location: AssetConst.sadAnimation,
                                          isSelected:
                                              state.mood == MoodConditions.sad,
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 3,
                                      ),

                                      // Emoji 3
                                      GestureDetector(
                                        onTap: () {
                                          state.setMood(MoodConditions.excited);
                                        },
                                        child: MoodEmoticon(
                                          location: AssetConst.winkingAnimation,
                                          isSelected: state.mood ==
                                              MoodConditions.excited,
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 3,
                                      ),

                                      // Emoji 4
                                      GestureDetector(
                                        onTap: () {
                                          state
                                              .setMood(MoodConditions.cheerful);
                                        },
                                        child: MoodEmoticon(
                                          location:
                                              AssetConst.blushingAnimation,
                                          isSelected: state.mood ==
                                              MoodConditions.cheerful,
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 3,
                                      ),

                                      // Emoji 5
                                      GestureDetector(
                                        onTap: () {
                                          state.setMood(MoodConditions.happy);
                                        },
                                        child: MoodEmoticon(
                                          location: AssetConst.smileyAnimation,
                                          isSelected: state.mood ==
                                              MoodConditions.happy,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              'Emotions',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                            ),
                            GetBuilder<RecordController>(
                                id: 'emotions',
                                builder: (state) {
                                  return Emotions(
                                    selectedEmotion: state.emotions,
                                    onEmotionSelected: (p0) {
                                      state.setEmotions(p0);
                                    },
                                  );
                                }),
                            const SizedBox(height: Spacing.spacing * 3),
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: ThemeColor.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  Get.back();
                                  Get.bottomSheet(
                                    SizedBox(
                                      height: Get.height / 1.2,
                                      child: const AddMoodDesc(),
                                    ),
                                    isScrollControlled: true,
                                    enableDrag: true,
                                  );
                                },
                                child: const Text(
                                  "Next",
                                  style: TextStyle(
                                    color: ThemeColor.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
