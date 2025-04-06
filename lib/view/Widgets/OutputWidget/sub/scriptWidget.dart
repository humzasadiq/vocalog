import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
              padding: EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "Transcript",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(color: Colors.black12,),
                    const SizedBox(height: 10),
                    Text(
                        "${transcriptFile.readAsStringSync()}",
                        style: GoogleFonts.tinos(color: Colors.black, fontSize: 18),
                      ),
                  ],
                ),
              ),
            )
          : Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      "Transcribing",
                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.black,
                      size: 50,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}