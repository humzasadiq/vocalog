import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocalog/controllers/recorder.dart';


class SettingsScreen extends StatelessWidget {
  // const SettingsScreen({super.key});
  final RecorderController recorderController = Get.find<RecorderController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF101010),
        // toolbarHeight: 50,
        title: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Icon(
                Icons.settings,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), "Settings"),
            ],
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            ListTile(
              textColor: Colors.white,
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
              textColor: Colors.white,
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
              textColor: Colors.white,
              title: Text("Delete all recordings"),
              trailing: IconButton(
                onPressed: () => recorderController.deleteAllRecordings(), 
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                )),
            ),
            Divider(),
          ],
      ),
      ),
    );
  }
}
