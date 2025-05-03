import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class UsernameField extends StatelessWidget {
  const UsernameField({
    super.key,
    required this.username,
    required this.currentTheme,
  });

  final TextEditingController username;
  final ThemeData currentTheme;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: username,
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          hintText: "Enter Username",
          hintStyle:
              TextStyle(color: currentTheme.primaryColorDark.withOpacity(0.3)),
          prefixIcon: Icon(
            Iconsax.user_edit,
            color: currentTheme.primaryColorDark.withOpacity(0.3),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: currentTheme.primaryColor, width: 1.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: currentTheme.primaryColorDark.withOpacity(0.3)))),
    );
  }
}
