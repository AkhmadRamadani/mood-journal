import 'package:flutter/material.dart';
import 'package:moodie/modules/record/views/add_mood_view.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:moodie/shared/widgets/cards/notification_card.dart';
import 'package:moodie/shared/widgets/cards/page_header.dart';
import 'package:moodie/shared/widgets/cards/record_card.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView>
    with TickerProviderStateMixin {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                name: 'Notifications'.tr,
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
                        'Today\'s Notification'.tr,
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: ThemeColor.neutral_900,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: Spacing.spacing * 3),
                      NotificationCard(
                        type: 0,
                        title: 'Mood Record Time!',
                        desc:
                            'Hello! How are you today? hope it all will be good! Keep your mood is on fire!',
                        time: '07:00 AM',
                        onClick: () {
                          Get.bottomSheet(
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              height: Get.height / 1.2,
                              child: const AddMood(),
                            ),
                            isScrollControlled: true,
                            enableDrag: true,
                          );
                        },
                      ),
                      const SizedBox(height: Spacing.spacing * 3),
                      NotificationCard(
                        type: 0,
                        title: 'Mood Record Time!',
                        desc:
                            'Hello! How are you today? hope it all will be good! Keep your mood is on fire!',
                        time: '07:00 AM',
                        onClick: () {
                          Get.bottomSheet(
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              height: Get.height / 1.2,
                              child: const AddMood(),
                            ),
                            isScrollControlled: true,
                            enableDrag: true,
                          );
                        },
                      ),
                      const SizedBox(height: Spacing.spacing * 3),
                      Text(
                        'This Week\'s Notification'.tr,
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: ThemeColor.neutral_900,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: Spacing.spacing * 3),
                      NotificationCard(
                        type: 0,
                        title: 'Mood Record Time!',
                        desc:
                            'Hello! How are you today? hope it all will be good! Keep your mood is on fire!',
                        time: '07:00 AM',
                        onClick: () {
                          Get.bottomSheet(
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              height: Get.height / 1.2,
                              child: const AddMood(),
                            ),
                            isScrollControlled: true,
                            enableDrag: true,
                          );
                        },
                      ),
                      const SizedBox(height: Spacing.spacing * 3),
                      NotificationCard(
                        type: 0,
                        title: 'Mood Record Time!',
                        desc:
                            'Hello! How are you today? hope it all will be good! Keep your mood is on fire!',
                        time: '07:00 AM',
                        onClick: () {
                          Get.bottomSheet(
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              height: Get.height / 1.2,
                              child: const AddMood(),
                            ),
                            isScrollControlled: true,
                            enableDrag: true,
                          );
                        },
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
