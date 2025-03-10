import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocalog/controllers/ai_api.dart';
import 'package:vocalog/controllers/recorder.dart';


class AIResponseWidget extends StatelessWidget {
  final RecorderController recorderController = Get.put(RecorderController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 50,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 235, 245, 255),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() => recorderController.aiResponse.value.isNotEmpty
              ? SizedBox(
                  height: 150,
                  child: SingleChildScrollView(
                    child: Text(
                      "Meeting Minutes: \n${recorderController.aiResponse.value}",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.left,
                    ),
                  ),
                )
              : Text(
                  "No Meeting Minutes yet",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                )),
        ],
      ),
    );
  }
}
