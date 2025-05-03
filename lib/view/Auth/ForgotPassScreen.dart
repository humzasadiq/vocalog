import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:velocity_x/velocity_x.dart';
import 'package:vocalog/controllers/UserController.dart';

import 'AuthWidgets/EmailField.dart';
import 'AuthWidgets/MainButton.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  final TextEditingController email = TextEditingController();

  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return SingleChildScrollView(
      child: Container(
        color: currentTheme.canvasColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
              child: SizedBox(
                width: Get.width * 0.65,
                child: Text(
                  "Forgot Password?",
                  textScaleFactor: MediaQuery.of(context).textScaler.scale(3),
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.bold),
                  softWrap: true,
                ),
              ),
            ).pOnly(
              top: Get.width * 0.16,
            ),

            // Logo(currentTheme: currentTheme),
            Material(
              child: Column(
                children: [
                  EmailField(Email: email, currentTheme: currentTheme),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 6),
                    child: Row(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "*",
                          style: TextStyle(color: currentTheme.primaryColor),
                        ),
                        Flexible(
                            child: Text(
                          "We will send you a message to set or reset your new password",
                          style:
                              TextStyle(color: currentTheme.primaryColorLight),
                          softWrap: true,
                        )),
                      ],
                    ),
                  ),
                  MainButton(
                          currentTheme: currentTheme,
                          onTap: () async {
                            try {
                              // EasyLoading.show();
                              await userController
                                  .forgetPasswordMethod(email.text);
                              // final user = userController.user.value;
                              // if (user != null) {
                              // Get.off(() =>
                              //     LogInScreen()); // Navigate to the intro screen
                              // }
                            } catch (error) {
                              // print("Error Signing In: $error");
                            }
                          },
                          text: "Submit")
                      .marginOnly(top: Get.width * 0.08),
                ],
              ),
            ).pOnly(top: 5, left: 12, right: 12),
          ],
        ),
      ),
    );
  }
}
