import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifyCodeFields extends StatelessWidget {
  const VerifyCodeFields({
    super.key,
    required this.controllers,
    required this.focusNodes,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: Get.width * 0.15,
          height: Get.height*0.09,
          child: Card(
            elevation: 0,
            color: currentTheme.cardColor,
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              textAlign: TextAlign.center, // Center the text
              keyboardType: TextInputType.number, // Numeric keyboard
              maxLength: 1, // Only allow 1 digit
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: '', // Remove the character counter
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: currentTheme.primaryColorLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: currentTheme.primaryColorDark),
                ),
              ),
              onChanged: (value) {
                if (value.length == 1) {
                  if (index < 5) {
                    FocusScope.of(context)
                        .requestFocus(focusNodes[index + 1]);
                  } else {
                    FocusScope.of(context)
                        .unfocus(); // Dismiss keyboard on last field
                  }
                } else if (value.isEmpty && index > 0) {
                  
                  FocusScope.of(context).requestFocus(focusNodes[
                      index - 1]); // Go back to previous field if empty
                }
              },
            ),
          ),
        );
      }),
    );
  }
}
