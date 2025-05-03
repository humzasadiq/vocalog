import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:vocalog/view/Widgets/MainAppBar.dart';
import 'package:vocalog/view/pages/OutputScreen.dart';
import 'package:just_audio/just_audio.dart';

import '../../controllers/RecordingController.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});
  final player = AudioPlayer();
  final RecordingController recordingController =
      Get.put(RecordingController());

  @override
  Widget build(BuildContext context) {
    // var path = "/storage/emulated/0/VocalogRecordings";
    return Scaffold(
      // backgroundColor: Colors.black,
      // backgroundColor: Color(0xFF101010),
      appBar: CustomAppBar(title: "[History]"),
      body: Scrollbar(
        child: Obx(() {
          final recordings = recordingController.recordings;

          if (recordingController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          } else if (recordings.isEmpty) {
            return Center(
              child: Text(
                'No recordings found',
                style: TextStyle(color: Colors.white70),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: recordings.length,
              itemBuilder: (context, index) {
                final recording = recordings[index];
                print(recording.transcript);
                final calar =
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                        .withOpacity(1.0);

                return SwipeActionCell(
                  trailingActions: [
                    SwipeAction(
                      performsFirstActionWithFullSwipe: true,
                      forceAlignmentToBoundary: false,
                      content: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Container(
                          margin: const EdgeInsets.all(0),
                          height: Get.height / 6.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.red,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete, color: Colors.white),
                              // SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                      widthSpace: Get.width / 3,
                      color: Colors.white.withOpacity(0.1),
                      onTap: (handler) async {
                        // Perform the deletion
                        await recordingController
                            .deleteRecording(recording.id!);
                      },
                    ),
                  ],
                  key: ObjectKey(recording.id),
                  child: InkWell(
                    onTap: () async {
                      final filePath = recording.fileLink;

                      Get.to(Outputscreen(
                        transcript: recording.transcript!,
                        calar: calar,
                        filePath: filePath,
                        index: index,
                        output: recording.output!,
                        fileStat: recording.datetime?.toString() ?? "Unknown",
                        fileDuration: (await player.setUrl(filePath))
                                ?.toString()
                                .split('.')
                                .first ??
                            'Unknown',
                      ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        border: Border(
                            top: BorderSide(
                                color: Colors.white.withOpacity(0.2), width: 1),
                            bottom: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                                width: 1)),
                        // color: calar,
                        // borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            '${recording.topic.toUpperCase()}',
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "Dated: ${recording.datetime?.toString() ?? 'Unknown'}",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.4)),
                            ),
                          ),
                          leading: Icon(Icons.record_voice_over, color: calar),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        }),
      ),
    );
  }

  Future<List<File>> getRecordingFiles(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) return [];

      final subdirectories = directory.listSync().where((entity) {
        if (entity is Directory) {
          final dirName = entity.path.split('/').last;
          return dirName.startsWith('recording_');
        }
        return false;
      }).cast<Directory>();

      List<File> recordingFiles = [];
      for (var subdir in subdirectories) {
        final file = File('${subdir.path}/recording.aac');
        if (await file.exists()) {
          recordingFiles.add(file);
        }
      }

      return recordingFiles;
    } catch (e) {
      print("Error fetching recording files: $e");
      return [];
    }
  }
}
