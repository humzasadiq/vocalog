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

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final RecordingController recordingController = Get.find<RecordingController>();
  final player = AudioPlayer();
  // Add this map to store colors
  final Map<String, Color> recordingColors = {};
  // Add loading state
  final RxBool isItemLoading = false.obs;
  final RxString loadingItemId = ''.obs;

static const List<Color> baseColors = [
  Colors.grey,
  Colors.blueGrey,
  Colors.teal,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.lime,
  Colors.brown,
  Colors.lightBlue,
  Colors.pink,
];

static final List<Color> mutedColors = baseColors.map((color) {
  final hsl = HSLColor.fromColor(color);
  final mutedHsl = hsl.withSaturation(0.3).withLightness(0.6);
  return mutedHsl.toColor();
}).toList();


  // Modify the getRandomMutedColor method to work with recording IDs
  Color getColorForRecording(String recordingId) {
    if (!recordingColors.containsKey(recordingId)) {
      recordingColors[recordingId] = mutedColors[math.Random().nextInt(mutedColors.length)];
    }
    return recordingColors[recordingId]!;
  }

  @override
  Widget build(BuildContext context) {
    // var path = "/storage/emulated/0/VocalogRecordings";
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF080808),
        centerTitle: true,
        title: const Text(
          "[History]",
          style: TextStyle(
            fontFamily: 'IBM',
            color: Colors.white, fontSize: 18
            ),
        ),
      ),
      body: Obx(
        () => recordingController.recordings.isEmpty
            ? const Center(
                child: Text(
                  "No recordings yet",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Scrollbar(
                child: Obx(() {
                  final recordings = recordingController.recordings;

                  if (recordingController.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return ListView.builder(
                      itemCount: recordings.length,
                      itemBuilder: (context, index) {
                        final recording = recordings[index];
                        final calar = getColorForRecording(recording.id);  // Use this instead of getRandomMutedColor()
                        
                        return SwipeActionCell(
                          trailingActions: [
                            SwipeAction(
                              title: "Delete",
                              onTap: (CompletionHandler handler) async {
                                await handler(true);
                                recordingController.deleteRecording(recording.id);
                              },
                              color: Colors.red,
                            ),
                          ],
                          key: ObjectKey(recording),
                          child: InkWell(
                            onTap: () async {
                              final filePath = recording.fileLink;
                              loadingItemId.value = recording.id;
                              isItemLoading.value = true;

                              try {
                                final duration = await player.setUrl(filePath);
                                Get.to(Outputscreen(
                                  transcript: recording.transcript!,
                                  calar: calar,
                                  filePath: filePath,
                                  index: index,
                                  output: recording.output!,
                                  fileStat: recording.datetime?.toString() ?? "Unknown",
                                  fileDuration: duration?.toString().split('.').first ?? 'Unknown',
                                ));
                              } catch (e) {
                                print("Error loading audio: $e");
                                Get.snackbar(
                                  "Error",
                                  "Failed to load audio file",
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  colorText: Colors.red,
                                  snackPosition: SnackPosition.TOP,
                                );
                              } finally {
                                isItemLoading.value = false;
                                loadingItemId.value = '';
                              }
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
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text(
                                    '${recording.topic}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      "Dated: ${recording.datetime?.toString() ?? 'Unknown'}",
                                      style: TextStyle(
                                          fontFamily: 'IBM',
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.6)),
                                    ),
                                  ),
                                  leading: Obx(() => loadingItemId.value == recording.id && isItemLoading.value
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(calar),
                                        ),
                                      )
                                    : Icon(Icons.record_voice_over, color: calar)),
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

  @override
  void dispose() {
    player.dispose();
    recordingColors.clear();
    super.dispose();
  }
}
