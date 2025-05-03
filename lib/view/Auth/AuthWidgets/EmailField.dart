import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.Email,
    required this.currentTheme,
  });

  final TextEditingController Email;
  final ThemeData currentTheme;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: Email,
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          hintText: "Enter Email",
          hintStyle:
              TextStyle(color: currentTheme.primaryColorDark.withOpacity(0.3)),
          prefixIcon: Icon(
            Icons.email,
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
