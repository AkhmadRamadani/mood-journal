import 'package:flutter/material.dart';
import 'package:moodie/modules/profile/controllers/profile_controller.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:moodie/shared/widgets/buttons/profile_button.dart';
import 'package:moodie/shared/widgets/cards/notification_card.dart';
import 'package:moodie/shared/widgets/cards/page_header.dart';
import 'package:moodie/shared/widgets/cards/record_card.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';

class ShowProfile extends StatelessWidget {
  const ShowProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProfileController controller = Get.put(ProfileController());
    return Scaffold(
      backgroundColor: ThemeColor.primary,
      body: SafeArea(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                top: 24,
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
                  // Container(
                  //   child: IconButton(
                  //     onPressed: () {},
                  //     icon: const Icon(
                  //       Icons.check,
                  //       color: ThemeColor.white,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            ProfileButton(
              image: controller.user?.photoURL ?? '',
              // isRounded: true,
              size: 100,
            ),
            const SizedBox(
              height: Spacing.spacing * 3,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.spacing * 3,
                  Spacing.spacing * 3,
                  Spacing.spacing * 3,
                  0,
                ),
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
                              'Account Details',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              'Your Name :',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 2),
                            Text(
                              controller.user?.displayName ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              'Your Email :',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: Spacing.spacing * 2),
                            Text(
                              controller.user?.email ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
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
