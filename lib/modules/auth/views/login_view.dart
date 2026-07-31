import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:moodie/constants/asset_const.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/modules/auth/controllers/login_controller.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/widgets/buttons/custom_text_button.dart';
import 'package:moodie/shared/widgets/text_field/custom_text_field.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LoginController.to;
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
                      const SizedBox(height: 74),
                      Text(
                        "Welcome Back!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: SvgPicture.asset(
                          AssetConst.sittingManSVG,
                          height: 160,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Google Sign-In
                      CustomTextButton(
                        onPressed: () {
                          controller.loginWithGoogle();
                        },
                        title: "Sign in with Google",
                        svgLocation: AssetConst.googleIc,
                      ),

                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "Or sign in with email",
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Email field
                      CustomTextField(
                        controller: controller.emailController,
                        hintText: "Email",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      CustomTextField(
                        controller: controller.passwordController,
                        hintText: "Password",
                        keyboardType: TextInputType.visiblePassword,
                      ),

                      const SizedBox(height: 4),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: navigate to forgot password
                          },
                          child: Text(
                            "Forgot password?",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: ThemeColor.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Sign in button
                      CustomTextButton(
                        title: "Sign In",
                        onPressed: () {
                          controller.login();
                        },
                        textColor: Colors.white,
                        backgroundColor: ThemeColor.primary,
                      ),

                      const SizedBox(height: 24),

                      // Sign up link
                      InkWell(
                        onTap: () {
                          Get.toNamed(Routes.register);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Sign up",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: ThemeColor.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
          GetBuilder<LoginController>(
            builder: (controller) {
              if (controller.isLoading.value) {
                return Container(
                  color: Colors.black.withOpacity(0.3),
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
