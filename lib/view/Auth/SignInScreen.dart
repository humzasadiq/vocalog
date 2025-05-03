import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import 'package:velocity_x/velocity_x.dart';
import 'package:vocalog/main.dart';
import 'package:vocalog/utils/Themes.dart';

import '../../controllers/UserController.dart';
import 'AuthWidgets/EmailField.dart';
import 'AuthWidgets/MainButton.dart';
import 'AuthWidgets/NotAndALreadySigned.dart';
import 'AuthWidgets/PassField.dart';
import 'ForgotPassScreen.dart';
import 'SignupScreen.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController email = TextEditingController();

  final TextEditingController password = TextEditingController();

  final UserController userController = Get.put(UserController());

  RxBool isPassVisible = true.obs;

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return SingleChildScrollView(
      child: Container(
        color: currentTheme.canvasColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: Get.width * 0.8,
                height: Get.height * 0.15,
                child: Positioned(
                  right: Get.width * 0.01,
                  top: 0,
                  child: Opacity(
                    opacity: 0.6,
                    child: Image.asset(
                      "assets/logo.png",
                      width: Get.width * 0.3,
                      height: Get.height * 0.15,
                      fit: BoxFit.contain,
                    ),
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
                ).pOnly(top: Get.height * 0.1, left: Get.width * 0.02),
            Row(
              children: [
                Text(
                  "Login Account",
                  style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
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
            // Logo(currentTheme: currentTheme),
            Material(
              child: Column(
                children: [
                  EmailField(Email: email, currentTheme: currentTheme),
                  10.heightBox,
                  PasswordField(
                      isPassVisible: isPassVisible,
                      password: password,
                      currentTheme: currentTheme),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => ForgotPassScreen(),
                          transition: Transition.rightToLeft);
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Forgot Password ?",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppConstant.primary,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontSize: 12),
                      ).pOnly(top: Get.width * 0.015, right: Get.width * 0.04),
                    ),
                  ),
                  Obx(() {
                    return userController.isLoading.value
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : MainButton(
                                currentTheme: currentTheme,
                                onTap: () async {
                                  try {
                                    await userController.login(
                                        email.text, password.text);
                                    final user = userController.user.value;
                                    if (user != null) {
                                      Get.offAll(() => VocalogScreen(),
                                          transition: Transition
                                              .rightToLeft); // Navigate to the intro screen
                                      print(user.name);
                                    } else {}
                                  } catch (error) {
                                    print("Error Signing In: $error");
                                  }
                                },
                                text: "Login")
                            .marginOnly(top: Get.width * 0.08);
                  }),
                  // OrSignInDivider(currentTheme: currentTheme)
                  //     .marginOnly(top: Get.width * 0.08),
                  // GoogleAndFb(currentTheme: currentTheme)
                  //     .marginOnly(top: Get.width * 0.01),
                  NotAndAlreadySigned(
                    seconfText: "Create Account",
                    firstText: "Not registered yet? ",
                    currentTheme: currentTheme,
                    onTap: () {
                      Get.to(() => const SignUp(),
                          transition: Transition.rightToLeft);
                    },
                  ).marginOnly(top: Get.width * 0.08, bottom: 10)
                ],
              ),
            ).pOnly(left: 12, right: 12),
          ],
        ),
      ),
    );
  }
}

class ProfileIcon extends StatelessWidget {
  const ProfileIcon({
    super.key,
    required this.currentTheme,
  });

  final ThemeData currentTheme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Iconsax.user,
          // color: currentTheme.primaryColorDark.withOpacity(0.3),
          color: Colors.white.withOpacity(0.2),

          size: 16,
        ),
        Icon(
          Iconsax.user,
          // color: currentTheme.primaryColorDark.withOpacity(0.3),
          color: Colors.white.withOpacity(0.2),

          size: 17,
        ),
        Icon(
          Iconsax.user,
          // color: currentTheme.primaryColorDark.withOpacity(0.3),
          color: Colors.white.withOpacity(0.2),

          size: 18,
        ),
        Icon(
          Iconsax.user,
          // color: currentTheme.primaryColorDark.withOpacity(0.3),
          color: Colors.white.withOpacity(0.2),

          size: 19,
        ),
        Icon(
          Iconsax.user,
          // color: currentTheme.primaryColorDark.withOpacity(0.3),
          color: Colors.white.withOpacity(0.2),

          size: 20,
        ),
        Icon(
          Iconsax.user,
          // color: currentTheme.primaryColorDark.withOpacity(0.3),
          color: Colors.white.withOpacity(0.2),

          size: 21,
        ),
        Icon(
          Iconsax.user,
          // color: currentTheme.primaryColorDark.withOpacity(0.3),
          color: Colors.white.withOpacity(0.2),

          size: 22,
        ),
      ],
    );
  }
}
