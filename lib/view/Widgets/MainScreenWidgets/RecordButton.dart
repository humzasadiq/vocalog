import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';
import '../../../controllers/recorder.dart';
import 'LoadingDots.dart';

class RecordButton extends StatelessWidget {
  final RecorderController controller;
  final StateMachineController? riveController;
  final SMIInput<bool>? upTrigger;

  const RecordButton({
    Key? key,
    required this.controller,
    this.riveController,
    this.upTrigger,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show loading animation when processing
      if (controller.isLoading.value) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[800],
          ),
          child: Center(
            child: LoadingDots(
              status: controller.loadingStatus.value,
              isComplete: controller.isComplete.value,
              isError: controller.isError.value,
            ),
          ),
        );
      }

      // Show success state briefly
      if (controller.isComplete.value) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[800],
          ),
          child: Center(
            child: LoadingDots(
              status: controller.loadingStatus.value,
              isComplete: true,
              isError: false,
            ),
          ),
        );
      }

      // Show error state briefly
      if (controller.isError.value) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[800],
          ),
          child: Center(
            child: LoadingDots(
              status: controller.loadingStatus.value,
              isComplete: false,
              isError: true,
            ),
          ),
        );
      }

      // Show normal recording button
      return GestureDetector(
        onTapDown: (_) {
          if (!controller.isRecording.value) {
            controller.startRecording();
            upTrigger?.value = true;
          }
        },
        onTapUp: (_) {
          if (controller.isRecording.value) {
            controller.stopRecording();
            upTrigger?.value = false;
          }
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: controller.isRecording.value ? Colors.red : Colors.grey[800],
          ),
          child: Center(
            child: Icon(
              controller.isRecording.value ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      );
    });
  }
} 