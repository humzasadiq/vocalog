import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocalog/controllers/recorder.dart';
import 'Widgets/MainScreenWidgets/micWidget.dart';
import 'SettingsScreen.dart';
import 'Widgets/MainScreenWidgets/logforDropDown.dart';
import 'Widgets/MainScreenWidgets/speakerCheckbox.dart';
import 'Widgets/MainScreenWidgets/topicTextField.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final RecorderController recorderController = Get.find<RecorderController>();

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final Animation<AlignmentGeometry> _animation = Tween<AlignmentGeometry>(
    begin: Alignment.bottomCenter,
    end: const Alignment(0.0, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  ));

  @override
  void initState() {
    super.initState();

    recorderController.isRecording.listen((isRecording) {
      if (isRecording) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                'G',
                style: TextStyle(
                  fontFamily: 'IBM',
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 2,
      ),
      body: Column(
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
          Expanded(
            child: AlignTransition(
              alignment: _animation,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    Obx(() {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        width: recorderController.isRecording.value ? 250 : 100,
                        height:
                            recorderController.isRecording.value ? 250 : 100,
                        child: RecordingWidget(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
