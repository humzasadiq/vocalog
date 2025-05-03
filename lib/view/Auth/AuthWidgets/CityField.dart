import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CityField extends StatelessWidget {
  const CityField({
    super.key,
    required this.City,
    required this.currentTheme,
  });

  final TextEditingController City;
  final ThemeData currentTheme;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: City,
      decoration: InputDecoration(
          filled: true,
          fillColor: currentTheme.cardColor,
          hintText: "Enter City",
          hintStyle: TextStyle(color: currentTheme.primaryColorDark.withOpacity(0.5)),
          prefixIcon: Icon(
            Iconsax.map,
            color: currentTheme.primaryColorDark.withOpacity(0.5),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: currentTheme.primaryColor, width: 1.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: currentTheme.primaryColorDark.withOpacity(0.5)))),
    );
  }
}
