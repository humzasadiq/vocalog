import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_markdown/flutter_markdown.dart';

class AIResponseWidget extends StatelessWidget {
  AIResponseWidget({super.key, required this.filePath});
  final String filePath;

  @override
  Widget build(BuildContext context) {
    final directoryExists = Directory(filePath).existsSync();
    final outputFile = File("$filePath/output.md");
    final outputExists = outputFile.existsSync();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(10),
      ),
      child: directoryExists && outputExists
          ? SizedBox(
              width: double.infinity,
              child: Markdown(
                data: outputFile.readAsStringSync(),
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(color: Colors.black),
                ),
              ),
            )
          : const Center(
              child: Text(
                "No Meeting Minutes yet",
                style: TextStyle(color: Colors.black87, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}