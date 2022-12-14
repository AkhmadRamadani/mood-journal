import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:moodie/modules/home/controllers/home_controller.dart';
import 'package:moodie/shared/icons/custom_icon.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

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
      ),
    );
  }
}
