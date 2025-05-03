// import 'package:ecom_mobile/Views/Auth/IntroMainScreen.dart';
// import 'package:ecom_mobile/Views/navigationMenu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocalog/controllers/UserController.dart';
import 'package:vocalog/view/Auth/SignInScreen.dart';


import '../../main.dart';

class SplashScreen extends StatelessWidget {
  final UserController userController = Get.put(UserController());

  SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    checkLoginStatus();
    final currentTheme = Theme.of(context);
    return Scaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          width: Get.width * 0.5,
          height: Get.height * 0.5,
        ),
      ),
    );
  }

  void checkLoginStatus() async {
    print("Checking status");
    // final email = await userController.getSavedEmail();
    await userController.checkSession();
    if (userController.user.value != null) {
      Get.off(() => VocalogScreen());
    } else {
      Get.off(() => LogInScreen());
    }
  }
}
