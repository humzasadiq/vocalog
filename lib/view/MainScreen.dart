import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocalog/controllers/recorder.dart';
import 'package:vocalog/view/Widgets/MainAppBar.dart';
import 'Widgets/MainScreenWidgets/micWidget.dart';
import 'Widgets/MainScreenWidgets/Waveform.dart';
import 'Widgets/MainScreenWidgets/options/optionsButton.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final RecorderController recorderController = Get.find<RecorderController>();
  
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    appBar: CustomAppBar(),
    body: Stack(
      children: [
        Obx(() => recorderController.isRecording.value ? Waveform() : const SizedBox()),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Obx(() {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RecordingWidget(),
                  recorderController.isRecording.value
                      ? Text(
                          recorderController.recordingTime.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const SizedBox(height: 40,),
                  
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
