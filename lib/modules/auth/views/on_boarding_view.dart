import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodie/constants/asset_const.dart';
import 'package:moodie/constants/routes.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/widgets/buttons/custom_text_button.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                    const SizedBox(
                      width: 10,
                    ),
                    Image.asset(
                      AssetConst.logoSVG,
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Journal",
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 20),
                SvgPicture.asset(
                  AssetConst.sittingManSVG,
                ),
                // const SizedBox(height: 100),
                Column(
                  children: [
                    Text(
                      'Welcome to Moodie',
                      style: GoogleFonts.openSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                      ),
                      child: Text(
                        'Moodie is a mood tracker app that helps you to track your mood and improve your mental health.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 20),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: CustomTextButton(
                        title: 'Get Started',
                        onPressed: () {
                          Get.offNamed(Routes.login);
                        },
                        backgroundColor: ThemeColor.primary,
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.black.withOpacity(0.4),
                        ),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: ThemeColor.primary,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
