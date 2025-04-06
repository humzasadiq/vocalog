import 'package:flutter/material.dart';
import 'package:vocalog/view/Widgets/OutputWidget/sub/audioPlayer.dart';
import 'package:vocalog/view/Widgets/OutputWidget/sub/scriptWidget.dart';

class AudioNtranscript extends StatelessWidget {
  AudioNtranscript({super.key, required this.filePath, required this.dirPath, required this.calar});
  final String filePath;
  final String dirPath;
  final Color calar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Audioplayer(filePath: filePath, calar: calar), // Audio player
        transcriptWidget(filePath: dirPath), // transcript Widget
      ],
    );
  }
}