import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:moodie/constants/asset_const.dart';
import 'package:moodie/modules/profile/controllers/change_password_controller.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/widgets/buttons/custom_text_button.dart';
import 'package:moodie/shared/widgets/text_field/custom_text_field.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ChangePasswordController.to;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Stack(
        children: [
          Scaffold(
            body: Container(
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AssetConst.signIn),
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 24),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    Colors.black.withAlpha((0.3 * 255).toInt()),
                                width: 0.4,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: const Icon(Icons.arrow_back),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Change Password",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Enter your current password and a new password below.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Current Password field
                      CustomTextField(
                        controller: controller.currentPasswordController,
                        hintText: "Current Password",
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      const SizedBox(height: 16),

                      // New Password field
                      CustomTextField(
                        controller: controller.newPasswordController,
                        hintText: "New Password",
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      const SizedBox(height: 16),

                      // Confirm New Password field
                      CustomTextField(
                        controller: controller.confirmPasswordController,
                        hintText: "Confirm New Password",
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      CustomTextButton(
                        title: "Update Password",
                        onPressed: () {
                          controller.submitChangePassword();
                        },
                        textColor: Colors.white,
                        backgroundColor: ThemeColor.primary,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
          GetBuilder<ChangePasswordController>(
            builder: (controller) {
              if (controller.isLoading.value) {
                return Container(
                  color: Colors.black.withAlpha((0.3 * 255).toInt()),
                  child: Center(
                    child: Lottie.asset(
                      AssetConst.animationLoading,
                      width: 48,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
