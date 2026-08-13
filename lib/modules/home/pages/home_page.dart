import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:moodie/modules/home/controllers/home_controller.dart';
import 'package:moodie/modules/record/controllers/record_controller.dart';
import 'package:moodie/modules/record/views/add_menstrual_log_view.dart';
import 'package:moodie/shared/icons/custom_icon.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void _showFabMenu(BuildContext context, HomeController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(Spacing.spacing * 3),
        decoration: const BoxDecoration(
          color: ThemeColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ThemeColor.neutral_400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'What would you like to record?',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: ThemeColor.neutral_900,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                Get.back();
                await Get.toNamed(Routes.addMood);
                if (controller.currentPageIndex.value == 0) {
                  DashboardController.to.refresh();
                } else if (controller.currentPageIndex.value == 1) {
                  RecordController.to.refresh();
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: ThemeColor.neutral_200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: ThemeColor.primary,
                      child:
                          Icon(Icons.emoji_emotions, color: ThemeColor.white),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Add Mood',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeColor.neutral_900,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 16, color: ThemeColor.neutral_500),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                Get.back();
                await Get.to(() => const AddMenstrualLogView());
                if (controller.currentPageIndex.value == 0) {
                  DashboardController.to.refresh();
                } else if (controller.currentPageIndex.value == 1) {
                  RecordController.to.refresh();
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: ThemeColor.neutral_200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: ThemeColor.purple_400,
                      child: Icon(Icons.water_drop, color: ThemeColor.white),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Add Menstrual Log',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeColor.neutral_900,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 16, color: ThemeColor.neutral_500),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) => Scaffold(
        body: controller.pages[controller.currentPageIndex.value],
        bottomNavigationBar: Container(
          color: ThemeColor.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Spacing.spacing * 2,
              horizontal: Spacing.spacing * 3,
            ),
            child: GNav(
              backgroundColor: ThemeColor.white,
              color: ThemeColor.neutral_900,
              activeColor: ThemeColor.white,
              tabBackgroundColor: ThemeColor.primary,
              padding: const EdgeInsets.symmetric(
                  vertical: Spacing.spacing + 4,
                  horizontal: Spacing.spacing + 4),
              gap: Spacing.spacing,
              tabs: [
                GButton(
                  icon: CustomIcons.home,
                  text: 'Home'.tr,
                ),
                GButton(
                  icon: CustomIcons.search,
                  text: 'Record'.tr,
                ),
                GButton(
                  icon: CustomIcons.notification,
                  text: 'Notification'.tr,
                ),
                GButton(
                  icon: CustomIcons.profile,
                  text: 'Profile'.tr,
                ),
              ],
              onTabChange: (index) => controller.setPageIndex(index),
            ),
          ),
        ),
        floatingActionButton: Visibility(
          visible: controller.currentPageIndex.value == 0 ||
              controller.currentPageIndex.value == 1,
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () => _showFabMenu(context, controller),
              backgroundColor: ThemeColor.primary,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }
}
