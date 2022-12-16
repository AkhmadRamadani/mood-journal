import 'package:flutter/material.dart';
import 'package:moodie/modules/record/views/add_mood_desc.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:get/get.dart';
import 'package:moodie/shared/widgets/cards/emotions_card.dart';
import 'package:moodie/shared/widgets/cards/select_mood_card.dart';

class AddMood extends StatelessWidget {
  const AddMood({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                            const SelectMood(),
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
                            const Emotions(),
                            const SizedBox(height: Spacing.spacing * 3),
                            Container(
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
                                      Container(
                                        height: Get.height / 1.2,
                                        child: AddMoodDesc(),
                                      ),
                                      isScrollControlled: true,
                                      enableDrag: true);
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
