import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocalog/controllers/recorder.dart';


class SettingsScreen extends StatelessWidget {
  // const SettingsScreen({super.key});
  final RecorderController recorderController = Get.find<RecorderController>();

  final WidgetStateProperty<Color?> overlayColor = WidgetStateProperty<Color?>.fromMap(
      <WidgetState, Color>{
        WidgetState.selected: const Color.fromARGB(255, 163, 115, 240),
        WidgetState.disabled: const Color.fromARGB(255, 254, 181, 108),
      },
    );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF080808),
        title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: Colors.white,
              ),
              Text(
                "[Settings]",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(width: 20),
            ],
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            ListTile(
              textColor: Colors.grey,
              title: Text("Gemini API Key"),
              subtitle: Text("Enter your AI API Key"),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                  ),
              ),
            ),
            Divider(),
            ListTile(
              textColor: Colors.grey,
              title: Text("ElevenLabs API Key"),
              subtitle: Text("Enter your STT API Key"),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                  ),
              ),
            ),
            Divider(),
            ListTile(
              textColor: Colors.grey,
              title: Text("Delete all recordings"),
              trailing: IconButton(
                onPressed: () => recorderController.deleteAllRecordings(), 
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                )),
            ),
            Divider(),
            // ListTile(
            //   textColor: Colors.grey,
            //   title: Text("Sound Effects"),
            //   subtitle: Obx(() => Text(recorderController.soundType.value ? "TipTop" : "Whimsical")),
            //   trailing: Obx(() => Switch(
            //     overlayColor: overlayColor,
            //     trackColor: overlayColor,
            //     value: recorderController.soundType.value,
            //     onChanged: (value) {
            //       recorderController.soundType.value = value;
            //       recorderController.playStartupSound();
            //       recorderController.reinitializeSoundEffects();
            //     },
            //   )),
            // ),
          ],
      ),
      ),
    );
  }
}
