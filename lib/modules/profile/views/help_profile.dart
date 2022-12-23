import 'package:flutter/material.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/help_text.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:get/get.dart';
import 'package:moodie/shared/widgets/cards/bulletList_card.dart';

class HelpProfile extends StatelessWidget {
  const HelpProfile({Key? key}) : super(key: key);

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
                    'Help & Support',
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
                              HelpText.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              HelpText.desc1,
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
                              HelpText.gs,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: HelpText.gs1),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: HelpText.gs2),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: HelpText.gs3),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              HelpText.us,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: HelpText.us1),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: HelpText.us2),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: HelpText.us3),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: HelpText.us4),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              HelpText.trbs,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: HelpText.trbs1),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: HelpText.trbs2),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              HelpText.cu,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 2),
                            const BulletList(text: HelpText.cu1),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              HelpText.desc2,
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
