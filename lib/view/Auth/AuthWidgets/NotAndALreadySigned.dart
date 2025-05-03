import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:vocalog/utils/Themes.dart';

// import 'package:weatherapp/utils/Themes.dart';

class NotAndAlreadySigned extends StatelessWidget {
  const NotAndAlreadySigned(
      {super.key,
      required this.currentTheme,
      required this.onTap,
      required this.firstText,
      required this.seconfText});

  final String firstText;
  final String seconfText;

  final ThemeData currentTheme;
  final GestureTapCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          firstText,
          style:
              TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12.5),
        ),
        5.widthBox,
        InkWell(
            splashColor: AppConstant.primary,
            focusColor: AppConstant.primary,
            hoverColor: AppConstant.primary,
            onTap: onTap,
            child: Text(seconfText,
                style: TextStyle(
                    color: AppConstant.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)))
      ],
    );
  }
}
