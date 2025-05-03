import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class Logo extends StatelessWidget {
  const Logo({
    super.key,
    required this.currentTheme,
  });

  final ThemeData currentTheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      height: Get.height*0.1,
      child : currentTheme.primaryColor == const Color(0xFFD6D6D6)
        ? Image.asset("assets/LogoDark.png",fit: BoxFit.contain,).pOnly(left: 10)
        : Image.asset("assets/Logo.png",fit: BoxFit.contain).pOnly(left: 10),
    );
  }
}