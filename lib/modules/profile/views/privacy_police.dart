import 'package:flutter/material.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/help_text.dart';
import 'package:moodie/shared/themes/privacy_police_text.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:get/get.dart';
import 'package:moodie/shared/widgets/cards/bulletList_card.dart';

class PrivacyPolice extends StatelessWidget {
  const PrivacyPolice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: ThemeColor.white,
                      ),
                    ),
                  ),
                  Text(
                    'Privacy & Police',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: ThemeColor.white,
                          fontWeight: FontWeight.bold,
                        ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: Spacing.spacing * 2,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          top: Spacing.spacing,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              PrivacyText.date,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              PrivacyText.desc1,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              PrivacyText.desc2,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              PrivacyText.desc3,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              PrivacyText.cu,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              PrivacyText.descu,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: PrivacyText.cu1),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: PrivacyText.cu2),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: PrivacyText.cu3),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              PrivacyText.descu2,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              PrivacyText.si,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              PrivacyText.dessi,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: PrivacyText.si1),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: PrivacyText.si2),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: PrivacyText.si3),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              PrivacyText.yc,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              PrivacyText.desyc,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: PrivacyText.yc1),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: PrivacyText.yc2),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: PrivacyText.yc3),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: PrivacyText.yc4),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              PrivacyText.ds,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              PrivacyText.desds,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w400,
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
