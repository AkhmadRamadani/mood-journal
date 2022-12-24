import 'package:flutter/material.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/help_text.dart';
import 'package:moodie/shared/themes/privacy_police_text.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:get/get.dart';
import 'package:moodie/shared/themes/term_service_text.dart';
import 'package:moodie/shared/widgets/cards/bulletList_card.dart';

class TermService extends StatelessWidget {
  const TermService({Key? key}) : super(key: key);

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
              margin: const EdgeInsets.only(
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
                    'Term of Service',
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
                              TermServiceText.date,
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
                              TermServiceText.desc1,
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
                              TermServiceText.desc2,
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
                              TermServiceText.desc3,
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
                              TermServiceText.ltow,
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
                              TermServiceText.ltow1,
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
                              TermServiceText.ltow2,
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
                              TermServiceText.ltow3,
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
                              TermServiceText.trm,
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
                              TermServiceText.trm1,
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
                              TermServiceText.trm2,
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
                              TermServiceText.gl,
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
                              TermServiceText.gl1,
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
                              TermServiceText.gl2,
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
                              TermServiceText.ch,
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
                              TermServiceText.ch1,
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
                              TermServiceText.ch2,
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
                              TermServiceText.cu,
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
                              TermServiceText.cu1,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
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
