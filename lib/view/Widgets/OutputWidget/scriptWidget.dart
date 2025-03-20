import 'dart:io';
import 'package:flutter/material.dart';

class transcriptWidget extends StatelessWidget {
  transcriptWidget({super.key, required this.filePath});
  final String filePath;

  @override
  Widget build(BuildContext context) {
    final directoryExists = Directory(filePath).existsSync();
    final transcriptFile = File("$filePath/transcript.txt");
    final transcriptExists = transcriptFile.existsSync();

    return Container(
      
      child: directoryExists && transcriptExists
          ? Container(
              padding: const EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Text(
                  "Transcription: \n${transcriptFile.readAsStringSync()}",
                  // style: const TextStyle(color: Colors.white70, fontSize: 18),
                  textAlign: TextAlign.left,
                ),
              ),
            )
          : const Center(
              child: Text(
                "No transcription yet",
                style: TextStyle(color: Colors.white70, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}