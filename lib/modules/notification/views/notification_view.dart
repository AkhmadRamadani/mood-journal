import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/models/firebase_notif_model.dart';
import 'package:moodie/modules/notification/controllers/notification_controller.dart';
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
    final NotificationController controller = Get.find();
    return Scaffold(
      backgroundColor: ThemeColor.primary,
      body: SafeArea(
        bottom: false,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.spacing * 3,
                  vertical: Spacing.spacing * 0.5,
                ),
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
                      children: [
                        const SizedBox(height: Spacing.spacing * 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Today\'s Notification'.tr,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            GetBuilder<NotificationController>(
                              builder: (state) {
                                final hasUnread = state.todaysNotifList
                                        .any((n) => !(n.isRead ?? false)) ||
                                    state.yesterdayNotifList
                                        .any((n) => !(n.isRead ?? false));
                                if (!hasUnread) return const SizedBox.shrink();
                                return GestureDetector(
                                  onTap: () => state.markAllAsRead(),
                                  child: Text(
                                    'Mark all as read'.tr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: ThemeColor.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.spacing * 3),
                        GetBuilder<NotificationController>(
                          builder: (state) {
                            if (state.isLoading.value) {
                              return _buildShimmerList(state);
                            } else if (state.todaysNotifList.isNotEmpty) {
                              return _buildNotifList(
                                  context, state, state.todaysNotifList);
                            } else {
                              return const Center(
                                child: Text('No Notification'),
                              );
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
                              return _buildShimmerList(state);
                            } else if (state.yesterdayNotifList.isNotEmpty) {
                              return _buildNotifList(
                                  context, state, state.yesterdayNotifList);
                            } else {
                              return const Center(
                                child: Text('No Notification'),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: Spacing.spacing * 2),
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

  Widget _buildShimmerList(NotificationController state) {
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
      separatorBuilder: (context, index) => const SizedBox(
        height: Spacing.spacing * 3,
      ),
      itemCount: 3,
    );
  }

  Widget _buildNotifList(BuildContext context, NotificationController state,
      List<FirebaseNotificationModel> list) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final FirebaseNotificationModel notif = list[index];
        return NotificationCard(
          type: 0,
          title: notif.title ?? '',
          desc: notif.body ?? '',
          time: (notif.date ?? DateTime.now()).toTimeAString(),
          isLoading: state.isLoading.value,
          isRead: notif.isRead ?? false,
          onClick: () => _handleNotifTap(state, notif),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(
        height: Spacing.spacing * 3,
      ),
      itemCount: list.length,
    );
  }

  Future<void> _handleNotifTap(
      NotificationController state, FirebaseNotificationModel notif) async {
    // Navigate based on topic
    if (notif.topic == 'drinkReminder') {
      await Get.toNamed(Routes.hydrate);
    } else if (notif.topic == 'fillJournal') {
      await Get.toNamed(Routes.addMood);
    }

    // Mark as read in background — don't block the UI
    if (!(notif.isRead ?? false)) {
      unawaited(state.readNotification(notif));
    }
  }
}
