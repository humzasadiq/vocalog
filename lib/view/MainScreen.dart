import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Widgets/scriptWidget.dart';
import 'package:vocalog/controllers/recorder.dart';
import 'Widgets/micWidget.dart';

class MainScreen extends StatelessWidget {
  final RecorderController recorderController = Get.put(RecorderController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png'),
        actions: [
          Text("Delete all recordings"),
          IconButton(
            onPressed: () => recorderController.deleteAllRecordings(),
            icon: const Icon(Icons.delete),
            color: Colors.red,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RecordingWidget(),
            SizedBox(height: 20),
            transcriptWidget(),
            SizedBox(height: 20),
          ],
        ),
      ),
      
    );
  }
}
