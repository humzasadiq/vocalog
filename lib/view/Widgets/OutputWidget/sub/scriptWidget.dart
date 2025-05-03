import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class transcriptWidget extends StatelessWidget {
  transcriptWidget({super.key, required this.transcript});
  final String transcript;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Container(
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
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              color: Colors.white12,
            ),
            const SizedBox(height: 10),
            Text(
              "${transcript}",
              style: GoogleFonts.tinos(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    )
        // : Center(
        //     child: Padding(
        //       padding: EdgeInsets.all(20.0),
        //       child: Column(
        //         children: [
        //           Text(
        //             "Transcribing",
        //             style: TextStyle(
        //                 color: Colors.black,
        //                 fontSize: 15,
        //                 fontWeight: FontWeight.bold),
        //             textAlign: TextAlign.center,
        //           ),
        //           SizedBox(height: 10),
        //           LoadingAnimationWidget.staggeredDotsWave(
        //             color: Colors.black,
        //             size: 50,
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        );
  }
}
