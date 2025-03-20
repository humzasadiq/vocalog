import 'package:get/get.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'transcript_api.dart';
import 'ai_api.dart';
import 'dart:async';

class RecorderController extends GetxController {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  var isRecording = false.obs;
  var transcript = "".obs;
  final aiResponse = "".obs;
  String? filePath;
  String? fileDir;

  var recordingTime = "00:00:00".obs;
  Timer? _timer;
  int _elapsedSeconds = 0;
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
    fileDir =
        '/storage/emulated/0/VocalogRecordings/recording_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}_${DateTime.now().hour}_${DateTime.now().minute}/';
    try {
      if (fileDir == null) {
        throw Exception("fileDir is null");
      }
      Directory recordingsDir = Directory(fileDir!);
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      filePath =
          // current date and time for each recording
          '${recordingsDir.path}/recording.aac';

      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
      );

      isRecording.value = true;
      _startTimer();
      print("Recording started at: $filePath");
    } catch (e) {
      print("Error starting recorder: $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      await _recorder.stopRecorder();
      isRecording.value = false;
      _stopTimer();
      print("Recording saved: $filePath");

      if (filePath != null) {
        String fileName = basename(filePath!);
        print("File name: $fileName");

        String? result = await TranscriptApi.getTranscript(filePath!, fileName, fileDir!);
        if (result != null) {
          transcript.value = result;
          aiResponse.value = await AIApi.getAIMinutes(result, fileDir!);
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

  void _startTimer() {
    _elapsedSeconds = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      recordingTime.value = _formatDuration(_elapsedSeconds);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _elapsedSeconds = 0;
    recordingTime.value = "00:00:00"; // Reset the time
  }

  String _formatDuration(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$secs";
  }

  @override
  void onClose() {
    _recorder.stopRecorder();
    _recorder.closeRecorder();
    _stopTimer();
    super.onClose();
  }
}
