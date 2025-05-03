import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.isPassVisible,
    required this.password,
    required this.currentTheme,
  });

  final RxBool isPassVisible;
  final TextEditingController password;
  final ThemeData currentTheme;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextFormField(
        obscureText: isPassVisible.value,
        controller: password,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),

            // fillColor: currentTheme.canvasColor,
            hintText: "Enter Password",
            hintStyle: TextStyle(
                color: currentTheme.primaryColorDark.withOpacity(0.3)),
            prefixIcon: Icon(
              Iconsax.key_square,
              color: currentTheme.primaryColorDark.withOpacity(0.3),
            ),
            suffixIcon: Obx(() => GestureDetector(
                  onTap: () {
                    isPassVisible.toggle();
                  },
                  child: isPassVisible.value
                      ? Icon(Iconsax.eye_slash,
                          color: currentTheme.primaryColorDark.withOpacity(0.3))
                      : Icon(Iconsax.eye,
                          color:
                              currentTheme.primaryColorDark.withOpacity(0.3)),
                )),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: currentTheme.primaryColor, width: 1.5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: currentTheme.primaryColorDark.withOpacity(0.3)))),
      ),
    );
  }
}
