import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodie/constants/asset_const.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/widgets/buttons/custom_text_button.dart';
import 'package:moodie/shared/widgets/text_field/custom_text_field.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              top: 24,
                            ),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black.withOpacity(0.3),
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
                          const SizedBox(),
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        "Create Your Account!",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),

                      /// Button with icon and text
                      CustomTextButton(
                        onPressed: () {},
                        title: "Continue with Google",
                        svgLocation: AssetConst.googleIc,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        "Or sign up with email",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      const CustomTextField(
                        hintText: "Full Name",
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      const CustomTextField(
                        hintText: "Email",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      const CustomTextField(
                        hintText: "Password",
                        keyboardType: TextInputType.visiblePassword,
                      ),

                      const SizedBox(
                        height: 24,
                      ),
                      CustomTextButton(
                        title: "Sign Up",
                        onPressed: () {},
                        textColor: Colors.white,
                        backgroundColor: ThemeColor.primary,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Sign in",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: ThemeColor.primary,
                          ),
                        ),
                      ],
                    ),
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