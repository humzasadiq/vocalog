import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:get/get.dart';
import 'package:vocalog/controllers/recorder.dart';

class Waveform extends StatefulWidget {
  Waveform({super.key});

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform> {

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.asset(
      'assets/rive/vocalog.riv',
      artboard: 'card',
      fit: BoxFit.fill,
      stateMachines: ['State Machine'],
      onInit: Get.find<RecorderController>().initRiveController,
    );
  }
}