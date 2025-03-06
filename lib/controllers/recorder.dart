import 'package:get/get.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'transcript_api.dart';

class RecorderController extends GetxController {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  var isRecording = false.obs;
  var transcript = "".obs;
  String? filePath;

  @override
  void onInit() {
    super.onInit();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        Permission.manageExternalStorage,
        Permission.storage,
      ].request();

      if (!statuses[Permission.microphone]!.isGranted) {
        print("Microphone permission denied!");
        return;
      }

      await _recorder.openRecorder();
      await _recorder.setSubscriptionDuration(const Duration(milliseconds: 10));
    } catch (e) {
      print("Error initializing recorder: $e");
    }
  }

  Future<void> startRecording() async {
    try {
      Directory recordingsDir =
          Directory('/storage/emulated/0/VocalogRecordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      filePath =
      // current date and time for each recording
          '${recordingsDir.path}/recording_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}_${DateTime.now().hour}_${DateTime.now().minute}.aac';

      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
      );

      isRecording.value = true;
      print("Recording started at: $filePath");
    } catch (e) {
      print("Error starting recorder: $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      await _recorder.stopRecorder();
      isRecording.value = false;
      print("Recording saved: $filePath");

      if (filePath != null) {
        String fileName = basename(filePath!);
        print("File name: $fileName");

        String? result = await TranscriptApi.getTranscript(filePath!, fileName);
        if (result != null) {
          transcript.value = result;
        }
      }
    } catch (e) {
      print("Error stopping recorder: $e");
    }
  }

  void toggleRecording() async {
    isRecording.value ? await stopRecording() : await startRecording();
  }

  void deleteAllRecordings() async {
    Directory recordingsDir =
        Directory('/storage/emulated/0/VocalogRecordings');
    if (await recordingsDir.exists()) {
      await recordingsDir.delete(recursive: true);
    }
  }
  @override
  void onClose() {
    _recorder.stopRecorder();
    _recorder.closeRecorder();
    super.onClose();
  }
}
