import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:vocalog/view/pages/OutputScreen.dart';
import 'package:just_audio/just_audio.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});
  final player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    var path = "/storage/emulated/0/VocalogRecordings";
    return Scaffold(
      // backgroundColor: Colors.black,
      backgroundColor: Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: Color(0xFF101010),
        // backgroundColor: Color(0xFF7550F1),
        centerTitle: true,
        title: Text(
          "[History]",
          style: TextStyle(color: Colors.white, fontSize: 18),
          // style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: Scrollbar(
        child: FutureBuilder<List<File>>(
          future: getRecordingFiles(path),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text(
                      style: TextStyle(color: Colors.white70),
                      'No recordings found'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final Color calar =
                      Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                          .withOpacity(1.0);
                  return TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      overlayColor: MaterialStateProperty.all(
                          Colors.grey.shade900.withOpacity(0.5)),
                    ),
                    onPressed: () async {
                      Get.to(Outputscreen(
                        calar: calar,
                        filePath: snapshot.data![index].path,
                        index: index,
                        fileStat: FileStat.statSync(snapshot.data![index].path)
                            .modified
                            .toString(),
                        fileDuration:
                            (await player.setUrl(snapshot.data![index].path))
                              ?.toString()
                              .split('.')
                              .first ?? 'Unknown',
                      ));
                    },
                    child: ListTile(
                      title: Text(
                        'Recording ${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        "Dated: ${FileStat.statSync(snapshot.data![index].path).modified.toString()}",
                      ),
                      leading: Icon(
                        Icons.record_voice_over,
                        color: calar,
                      ),
                    ),
                  );
                },
              );
            }
          },
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
}
