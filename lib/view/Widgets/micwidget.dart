import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/recorder.dart';

class RecordingWidget extends StatelessWidget {
  final RecorderController controller = Get.put(RecorderController());

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Obx(
          () => IconButton(
            icon: Icon(controller.isRecording.value ? Icons.stop : Icons.mic),
            iconSize: 80.0,
            onPressed: controller.toggleRecording,
            color: controller.isRecording.value ? Colors.red : Colors.blue,
          ),
        ),
      ),
    );
  }
}
