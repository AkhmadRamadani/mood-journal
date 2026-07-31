import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodie/constants/asset_const.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/modules/auth/controllers/login_controller.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/widgets/buttons/custom_text_button.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LoginController.to;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Container(
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AssetConst.onBoardingSVG),
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Mood",
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Image.asset(
                        AssetConst.logoSVG,
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Journal",
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SvgPicture.asset(
                    AssetConst.sittingManSVG,
                    height: 180,
                  ),
                  const SizedBox(height: 30),
                  Column(
                    children: [
                      Text(
                        'Welcome to Moodie',
                        style: GoogleFonts.openSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Moodie is a mood tracker app that helps you track your mood and improve your mental health.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      CustomTextButton(
                        onPressed: () {
                          controller.loginWithGoogle();
                        },
                        title: "Sign in with Google",
                        svgLocation: AssetConst.googleIc,
                      ),
                      const SizedBox(height: 16),
                      CustomTextButton(
                        onPressed: () {
                          Get.toNamed(Routes.login);
                        },
                        title: "Sign in with Email",
                        backgroundColor: ThemeColor.primary,
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(Routes.register);
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Don\'t have an account yet? ',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.6),
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeColor.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
