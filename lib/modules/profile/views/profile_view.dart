import 'package:flutter/material.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:moodie/shared/widgets/cards/notification_card.dart';
import 'package:moodie/shared/widgets/cards/page_header.dart';
import 'package:moodie/shared/widgets/cards/record_card.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget menuItem(String text) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: ThemeColor.neutral_600,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            const Icon(
              Icons.chevron_right,
              color: ThemeColor.neutral_600,
            )
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: ThemeColor.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: Spacing.spacing * 5,
                bottom: Spacing.spacing * 1,
                left: Spacing.spacing * 3,
                right: Spacing.spacing * 3,
              ),
              child: PageHeader(
                greet: false,
                isDark: true,
                type: 'heading',
                name: 'Profile'.tr,
                image:
                    'https://i.pinimg.com/564x/06/63/f5/0663f52b4e6775adcd134a27853004b3.jpg',
              ),
            ),
            const SizedBox(
              height: Spacing.spacing * 3,
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
                      Text(
                        'Account'.tr,
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: ThemeColor.neutral_900,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: Spacing.spacing * 3),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/show-profile');
                        },
                        child: menuItem('Show Profile'),
                      ),
                      const SizedBox(height: Spacing.spacing * 2),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/help-profile');
                        },
                        child: menuItem('Help'),
                      ),
                      const SizedBox(height: Spacing.spacing * 3),
                      Text(
                        'General'.tr,
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: ThemeColor.neutral_900,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: Spacing.spacing * 3),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/privacy-police');
                        },
                        child: menuItem('Privacy & Policy'),
                      ),
                      const SizedBox(height: Spacing.spacing * 2),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/term-service');
                        },
                        child: menuItem('Term of Service'),
                      ),
                      const SizedBox(height: Spacing.spacing * 4),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Log Out',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color: ThemeColor.secondary_400,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const Icon(
                                Icons.clear_outlined,
                                color: ThemeColor.secondary_400,
                              )
                            ],
                          ),
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
