import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodie/modules/profile/controllers/profile_controller.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:moodie/shared/widgets/cards/page_header.dart';
import 'package:moodie/shared/widgets/text_field/custom_text_field.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  void _showDeleteAccountDialog(
      BuildContext context, ProfileController controller) {
    final passwordController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Delete Account',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeColor.neutral_900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete your account? This action cannot be undone. Please enter your password to confirm.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: passwordController,
                hintText: 'Enter your password',
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          color: ThemeColor.neutral_700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final pwd = passwordController.text;
                        if (pwd.isEmpty) {
                          Get.snackbar(
                            'Oops',
                            'Please enter your password',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        Get.back(); // close confirm dialog
                        await controller.deleteAccount(pwd);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ProfileController controller = Get.put(ProfileController());
    Widget menuItem(String text) {
      return Row(
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
                          Navigator.pushNamed(context, '/change-password');
                        },
                        child: menuItem('Change Password'),
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

                      // Log Out button
                      GestureDetector(
                        onTap: () {
                          controller.logout();
                        },
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

                      const SizedBox(height: Spacing.spacing * 3),

                      // Delete Account button
                      GestureDetector(
                        onTap: () {
                          _showDeleteAccountDialog(context, controller);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Delete Account',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.spacing * 2),
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
