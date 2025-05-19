import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocalog/controllers/recorder.dart';
import 'package:vocalog/view/Widgets/MainAppBar.dart';
import '../../controllers/RecordingController.dart';
import '../Widgets/MainScreenWidgets/MicWidget.dart';
import '../Widgets/MainScreenWidgets/Waveform.dart';
import '../Widgets/MainScreenWidgets/options/optionsButton.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final RecorderController recorderController = Get.put(RecorderController());
  final RecordingController recordingController =
      Get.put(RecordingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "[Vocalog]",),
      body: Stack(
        children: [
          // Obx(() => recorderController.isRecording.value
          //     ? Waveform()
          //     : const SizedBox()),
          Waveform(),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Obx(() {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MicWidget(
                      controller: Get.find<RecorderController>(),
                    ),
                    recorderController.isRecording.value
                        ? Text(
                            recorderController.recordingTime.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'IBM',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox(
                            height: 40,
                          ),
                  ],
                );
              }),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: OptionsButton(),
          ),
        ],
      ),
    );
  }
}
