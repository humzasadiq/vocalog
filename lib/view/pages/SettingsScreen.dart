import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocalog/controllers/RecordingController.dart';
import 'package:vocalog/controllers/UserController.dart';
import 'package:vocalog/controllers/recorder.dart';
import 'package:vocalog/utils/Themes.dart';
import 'package:vocalog/view/Auth/ForgotPassScreen.dart';
import 'package:vocalog/view/Auth/SignInScreen.dart';
import 'package:vocalog/view/pages/Profilescreen.dart';

import '../Widgets/DialogLogoutWidget.dart';

class SettingsScreen extends StatelessWidget {
  // const SettingsScreen({super.key});
  final RecorderController recorderController = Get.put(RecorderController());
  final UserController userController = Get.find<UserController>();
  final RecordingController recordingController =
      Get.put(RecordingController());
  final WidgetStateProperty<Color?> overlayColor =
      WidgetStateProperty<Color?>.fromMap(
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
        centerTitle: true,
        title: Text(
          "[Settings]",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            ListTile(
              onTap: () => Get.to(() => ProfileScreen()),
              textColor: Colors.grey,
              leading: Icon(
                Icons.person,
                color: AppConstant.primary,
              ),
              title: Text("Update Profile"),
              subtitle: Text("Change your display name"),
            ),
            Divider(
              thickness: 1,
              color: Colors.white.withOpacity(0.2),
            ),
            ListTile(
              onTap: () => Get.to(() => ForgotPassScreen()),
              textColor: Colors.grey,
              title: Text("Forgot Password"),
              leading: Icon(
                Icons.lock,
                color: AppConstant.primary,
              ),
              subtitle: Text("Change your password"),
            ),
            // Divider(
            //   thickness: 1,
            //   color: Colors.white.withOpacity(0.2),
            // ),
            // ListTile(
            //   textColor: Colors.grey,
            //   title: Text("Gemini API Key"),
            //   subtitle: Text("Enter your AI API Key"),
            //   trailing: IconButton(
            //     onPressed: () {},
            //     icon: const Icon(
            //       Icons.edit,
            //       color: Colors.blue,
            //     ),
            //   ),
            // ),
            // Divider(
            //   thickness: 1,
            //   color: Colors.white.withOpacity(0.2),
            // ),
            // ListTile(
            //   textColor: Colors.grey,
            //   title: Text("ElevenLabs API Key"),
            //   subtitle: Text("Enter your STT API Key"),
            //   trailing: IconButton(
            //     onPressed: () {},
            //     icon: const Icon(
            //       Icons.edit,
            //       color: Colors.blue,
            //     ),
            //   ),
            // ),
            Divider(
              thickness: 1,
              color: Colors.white.withOpacity(0.2),
            ),
            // Divider(
            // thickness: 1,
            // color: Colors.white.withOpacity(0.2),,),
            ListTile(
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                          title: "Logout",
                          content: "Are you sure ?",
                          onCancel: () {
                            Navigator.of(context).pop();
                          },
                          onConfirm: () async {
                            Get.offAll(() => LogInScreen());

                            await userController.logout();
                          });
                    });
              },
              textColor: Colors.grey,
              title: Text("Logout"),
              trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.logout,
                    color: Colors.blue,
                  )),
            ),
            Divider(
              thickness: 1,
              color: Colors.white.withOpacity(0.2),
            ),
            ListTile(
              onTap: () => recordingController.deleteAllRecordings(),
              textColor: Colors.grey,
              title: Text("Delete all recordings"),
              trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  )),
            ),
            Divider(
              thickness: 1,
              color: Colors.white.withOpacity(0.2),
            ),
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
