import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../controllers/UserController.dart';
import 'AuthWidgets/EmailField.dart';
import 'AuthWidgets/MainButton.dart';
import 'AuthWidgets/NotAndALreadySigned.dart';
import 'AuthWidgets/PassField.dart';
import 'AuthWidgets/UsernameField.dart';
import 'SignInScreen.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    final TextEditingController username = TextEditingController();
    // final TextEditingController city = TextEditingController();
    final TextEditingController email = TextEditingController();
    final TextEditingController password = TextEditingController();

    final UserController userController = Get.find<UserController>();

    RxBool isPassVisible = true.obs;

    return SingleChildScrollView(
      physics: const PageScrollPhysics(),
      child: Material(
        color: currentTheme.canvasColor,
        child: Column(
          children: [
            SizedBox(
                width: Get.width,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    "assets/logo.png",
                    width: Get.width * 0.3,
                    height: Get.height * 0.15,
                    fit: BoxFit.contain,
                  ),
                )
                // Text(
                //   "Welcome Back!",
                //   textScaleFactor: MediaQuery.of(context).textScaler.scale(3),
                //   style: TextStyle(
                //       color: currentTheme.primaryColorDark,
                //       fontWeight: FontWeight.bold),
                //   softWrap: true,
                // ),
                ).pOnly(top: Get.height * 0.07),
            Row(
              children: [
                Text(
                  "Create Account",
                  style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      // color: currentTheme.primaryColorDark.withOpacity(0.7),
                      color: Colors.white.withOpacity(0.5),
                      fontSize: Get.width * 0.05,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none),
                ),
                5.widthBox,
                ProfileIcon(currentTheme: currentTheme),
              ],
            ).pOnly(
                top: Get.height * 0.04,
                left: Get.width * 0.04,
                bottom: Get.height * 0.02),
            Column(
              children: [
                UsernameField(username: username, currentTheme: currentTheme),
                8.heightBox,
                EmailField(Email: email, currentTheme: currentTheme),
                8.heightBox,
                PasswordField(
                    isPassVisible: isPassVisible,
                    password: password,
                    currentTheme: currentTheme),
              ],
            ).pOnly(left: 12, right: 12),
            MainButton(
                    currentTheme: currentTheme,
                    onTap: () async {
                      if (username.text.trim().isEmpty ||
                          email.text.trim().isEmpty ||
                          password.text.trim().isEmpty) {
                        Get.snackbar(
                          "Missing Fields",
                          "Please fill in all the required fields.",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      final check = await userController.signUp(
                        username.text,
                        email.text,
                        password.text,
                      );
                    },
                    text: "Create Account")
                .marginOnly(top: Get.width * 0.08),
            NotAndAlreadySigned(
              firstText: "Already registered?",
              seconfText: "Sign-in",
              currentTheme: currentTheme,
              onTap: () {
                Get.offAll(() => LogInScreen(),
                    transition: Transition.leftToRight);
              },
            ).marginOnly(top: Get.width * 0.08, bottom: Get.width * 0.1)
          ],
        ).pOnly(left: Get.width * 0.01, right: Get.width * 0.01),
      ),
    );
  }
}
