import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/recorder.dart';

class RecordingWidget extends StatelessWidget {
  final RecorderController controller = Get.find<RecorderController>();
  

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IconButton(
        icon: Image.asset(
          controller.isRecording.value
              ? 'assets/icon3.png'
              : 'assets/icon2.png',
          width: 200,
        ),
        // icon: Icon(controller.isRecording.value ? Icons.stop : Icons.mic),

        onPressed: controller.toggleRecording,
        color: controller.isRecording.value ? Colors.red : Colors.white,
      ),
    );
  }
}
