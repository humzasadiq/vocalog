import 'package:flutter/material.dart';
import 'package:vocalog/utils/Themes.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      content: Text(
        content,
        style: const TextStyle(fontSize: 18),
      ),
      actions: <Widget>[
        TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(currentTheme.colorScheme.surface)
          ),
          onPressed: onCancel,
          child: Text(
            'Cancel',
            style: TextStyle(color:Colors.white),
          ),
        ),
        TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(currentTheme.colorScheme.onPrimary)
          ),
          onPressed: onConfirm,
          child: Text(
            'Confirm',
            style: TextStyle(color:AppConstant.primary),
          ),
        ),
      ],
    );
  }
}
