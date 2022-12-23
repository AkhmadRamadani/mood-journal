import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/models/firebase_notif_model.dart';
import 'package:moodie/modules/notification/controllers/notification_controller.dart';
import 'package:moodie/modules/record/views/add_mood_view.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:moodie/shared/widgets/cards/notification_card.dart';
import 'package:moodie/shared/widgets/cards/page_header.dart';
import 'package:get/get.dart';
import 'package:moodie/utils/extensions/date_extension.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationController controller = Get.put(
      NotificationController(),
    );
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
                image: controller.user?.photoURL ?? '',
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await controller.getNotifications();
                    },
                    child: ListView(
                      // crossAxisAlignment: CrossAxisAlignment.start,
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
                        GetBuilder<NotificationController>(
                          builder: (state) {
                            if (state.isLoading.value) {
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return NotificationCard(
                                    type: 0,
                                    title: 'Mood Record Time!',
                                    desc:
                                        'Hello! How are you today? hope it all will be good! Keep your mood is on fire!',
                                    time: '07:00 AM',
                                    isLoading: state.isLoading.value,
                                    isRead: false,
                                    onClick: () {},
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(
                                  height: Spacing.spacing * 3,
                                ),
                                itemCount: 3,
                              );
                            } else {
                              if (state.todaysNotifList.isNotEmpty) {
                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    FirebaseNotificationModel notif =
                                        state.todaysNotifList[index];
                                    return NotificationCard(
                                      type: 0,
                                      title: notif.title ?? '',
                                      desc: notif.body ?? '',
                                      time: (notif.date ?? DateTime.now())
                                          .toTimeAString(),
                                      isLoading: state.isLoading.value,
                                      isRead: notif.isRead ?? false,
                                      onClick: () async {
                                        if (notif.topic == 'drinkReminder') {
                                          await Get.toNamed(Routes.hydrate);
                                          await state.readNotification(notif);
                                        } else if (notif.topic ==
                                            'fillJournal') {
                                          await Get.bottomSheet(
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              height: Get.height / 1.2,
                                              child: const AddMood(),
                                            ),
                                            isScrollControlled: true,
                                            enableDrag: true,
                                          );
                                          await state.readNotification(notif);
                                        }
                                      },
                                    );
                                  },
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(
                                    height: Spacing.spacing * 3,
                                  ),
                                  itemCount: state.todaysNotifList.length,
                                );
                              } else {
                                return const Center(
                                  child: Text('No Notification'),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: Spacing.spacing * 3),
                        Text(
                          'Last Notification'.tr,
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: Spacing.spacing * 3),
                        GetBuilder<NotificationController>(
                          builder: (state) {
                            if (state.isLoading.value) {
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return NotificationCard(
                                    type: 0,
                                    title: 'Mood Record Time!',
                                    desc:
                                        'Hello! How are you today? hope it all will be good! Keep your mood is on fire!',
                                    time: '07:00 AM',
                                    isLoading: state.isLoading.value,
                                    isRead: false,
                                    onClick: () {},
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(
                                  height: Spacing.spacing * 3,
                                ),
                                itemCount: 3,
                              );
                            } else {
                              if (state.yesterdayNotifList.isNotEmpty) {
                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    FirebaseNotificationModel notif =
                                        state.yesterdayNotifList[index];
                                    return NotificationCard(
                                      type: 0,
                                      title: notif.title ?? '',
                                      desc: notif.body ?? '',
                                      time: (notif.date ?? DateTime.now())
                                          .toTimeAString(),
                                      isLoading: state.isLoading.value,
                                      isRead: notif.isRead ?? false,
                                      onClick: () async {
                                        if (notif.topic == 'drinkReminder') {
                                          await Get.toNamed(Routes.hydrate);
                                          await state.readNotification(notif);
                                        } else if (notif.topic ==
                                            'fillJournal') {
                                          await Get.bottomSheet(
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              height: Get.height / 1.2,
                                              child: const AddMood(),
                                            ),
                                            isScrollControlled: true,
                                            enableDrag: true,
                                          );
                                          await state.readNotification(notif);
                                        }
                                      },
                                    );
                                  },
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(
                                    height: Spacing.spacing * 3,
                                  ),
                                  itemCount: state.yesterdayNotifList.length,
                                );
                              } else {
                                return const Center(
                                  child: Text('No Notification'),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
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
