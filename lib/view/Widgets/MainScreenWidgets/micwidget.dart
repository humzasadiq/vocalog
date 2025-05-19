import 'package:flutter/material.dart' hide Image;
import 'package:flutter/material.dart' as material;
import 'package:get/get.dart';
import 'package:rive/rive.dart';
import '../../../controllers/recorder.dart';
import 'LoadingDots.dart';

class MicWidget extends StatelessWidget {
  final RecorderController controller;
  final StateMachineController? riveController;
  final SMIInput<bool>? upTrigger;

  const MicWidget({
    Key? key,
    required this.controller,
    this.riveController,
    this.upTrigger,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return IconButton(
        icon: Stack(
          alignment: Alignment.center,
          children: [
            // Always show the base image
            material.Image.asset(
              controller.isRecording.value ? 'assets/icon3.png' : 'assets/icon2.png',
              width: 200,
            ),
            // Show loading animation on top when processing
            if (controller.isLoading.value || controller.isComplete.value || controller.isError.value)
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 217, 217, 217),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: LoadingDots(
                    status: "",
                    isComplete: controller.isComplete.value,
                    isError: controller.isError.value,
                  ),
                ),
              ),
          ],
        ),
        onPressed: controller.isLoading.value ? null : controller.toggleRecording,
        color: controller.isRecording.value ? Colors.red : Colors.white,
      );
    });
  }
}
