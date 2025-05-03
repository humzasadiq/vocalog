import 'package:flutter/material.dart';

class OrSignInDivider extends StatelessWidget {
  const OrSignInDivider({
    super.key,
    required this.currentTheme,
  });

  final ThemeData currentTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
            child: Divider(
          color: currentTheme.primaryColorLight,
          thickness: 1,
          indent: 20,
          endIndent: 10,
        )),
        Text(
          "Or sign up with",
          style: TextStyle(fontSize: 12, color: currentTheme.primaryColorLight),
        ),
        Flexible(
            child: Divider(
          color: currentTheme.primaryColorLight,
          thickness: 1,
          indent: 10,
          endIndent: 20,
        )),
      ],
    );
  }
}