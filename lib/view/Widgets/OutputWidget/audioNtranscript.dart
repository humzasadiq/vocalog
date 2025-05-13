import 'package:flutter/material.dart';
import 'package:vocalog/view/Widgets/OutputWidget/sub/audioPlayer.dart';
import 'package:vocalog/view/Widgets/OutputWidget/sub/scriptWidget.dart';

class AudioNtranscript extends StatelessWidget {
  AudioNtranscript({
    super.key,
    required this.filePath,
    required this.calar,
    required this.transcript,
  });
  final String filePath;
  final String transcript;
  final Color calar;

  @override
  Widget build(BuildContext context) {
    return Container(
      
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        
        
      ),
      child: Column(
        children: [
          Audioplayer(filePath: filePath, calar: calar),
          transcriptWidget(transcript: transcript),
        ],
      ),
    );
  }
}
