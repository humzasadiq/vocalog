import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocalog/controllers/recorder.dart';
import 'Widgets/MainScreenWidgets/micWidget.dart';
import 'SettingsScreen.dart';
import 'Widgets/MainScreenWidgets/logforDropDown.dart';
import 'Widgets/MainScreenWidgets/speakerCheckbox.dart';
import 'Widgets/MainScreenWidgets/topicTextField.dart';
class MainScreen extends StatelessWidget {
  final RecorderController recorderController = Get.find<RecorderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        backgroundColor: Color(0xFF101010),
        automaticallyImplyLeading: false,
        actions: [
          SizedBox(width: 10),
          IconButton(
            onPressed: () => Get.to(SettingsScreen()),
            icon: const Icon(Icons.settings),
            color: Colors.white,
          ),
          SizedBox(width: 10),
          IconButton(
            onPressed: () => Get.to(SettingsScreen()),
            icon: const Icon(Icons.person),
            color: Colors.white,
          ),
          SizedBox(width: 10),
        ],
        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'VO',
              style: TextStyle(
                fontFamily: 'IBM',
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            Text(
              'CAL',
              style: TextStyle(
                fontFamily: 'IBM',
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            Container(
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.asset(
                    'assets/icon2.png',
                  ).image,
                ),
                shape: BoxShape.circle,
              ),
            ),
            Text(
              'G',
              style: TextStyle(
                fontFamily: 'IBM',
                color: Colors.white,
                fontSize: 22,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 2,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Obx(() {
              if (!recorderController.isRecording.value) {
                return Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Logfordropdown(),
                      SizedBox(height: 10),
                      SpeakerCheckbox(),
                      SizedBox(height: 20),
                      Topictextfield(),
                    ],
                  ),
                );
              } else {
                return SizedBox();
              }
            }),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Obx(() {
                  if (recorderController.isRecording.value) {
                    return Text(
                      recorderController.recordingTime.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),
                RecordingWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}