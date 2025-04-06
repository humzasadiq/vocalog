import 'package:get/get.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rive/rive.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'transcript_api.dart';
import 'ai_api.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class RecorderController extends GetxController {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  var isRecording = false.obs;
  var transcript = "".obs;
  final aiResponse = "".obs;
  String? filePath;
  String? fileDir;
  // var soundType = true.obs;
  // String get soundTypeString => (soundType.value ? "1" : "2");

  // Sound paths
  late String startupSoundPath;
  late String stopSoundPath;
  bool _isSoundInitialized = false;

  // mplitude and animation related properties
  var volume = 0.0.obs;
  StateMachineController? _riveController;
  SMIInput<bool>? upTrigger;

  var recordingTime = "00:00:00".obs;
  Timer? _timer;
  Timer? _amplitudeTimer;
  int _elapsedSeconds = 0;

  @override
  void onInit() async {
    super.onInit();
    await _initializeSoundEffects();
    await _initializeRecorder();
  }

  Future<void> reinitializeSoundEffects() async {
    _isSoundInitialized = false;
    await _initializeSoundEffects();
  }

  Future<void> _initializeSoundEffects() async {
    try {
      final tempDir = await getTemporaryDirectory();
      startupSoundPath = '${tempDir.path}/startup1.wav';
      stopSoundPath = '${tempDir.path}/stop1.wav';

      // Copy sound files from assets to temp directory
      ByteData startupData =
          await rootBundle.load('assets/sounds/startup1.wav');
      ByteData stopData =
          await rootBundle.load('assets/sounds/stop1.wav');

      await File(startupSoundPath)
          .writeAsBytes(startupData.buffer.asUint8List());
      await File(stopSoundPath).writeAsBytes(stopData.buffer.asUint8List());

      _isSoundInitialized = true;
    } catch (e) {
      print("Error initializing sound effects: $e");
      _isSoundInitialized = false;
    }
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
      await _player.openPlayer();
      await _recorder.setSubscriptionDuration(const Duration(milliseconds: 10));

      // Pre-load sound effects
      // _isSoundInitialized = await _initializeSoundEffects();
    } catch (e) {
      print("Error initializing recorder: $e");
    }
  }

  void initRiveController(Artboard artboard) {
    _riveController =
        StateMachineController.fromArtboard(artboard, 'State Machine');

    if (_riveController != null) {
      artboard.addController(_riveController!);

      upTrigger = _riveController?.findInput('Up');

      if (upTrigger == null) {
        print('Could not find "Up" input');
      } else {
        print('"Up" input found and ready');
      }
    } else {
      print('State Machine not initialized');
    }
  }

  void _startAmplitudeMonitoring() {
    _amplitudeTimer = Timer.periodic(
        const Duration(milliseconds: 100), (_) => _updateAmplitude());
  }

  Future<void> _updateAmplitude() async {
    if (!isRecording.value) return;

    try {
      _recorder.onProgress?.listen((event) {
        double normalizedVolume = (event.decibels ?? 0) / 100;
        volume.value = normalizedVolume;

        if (normalizedVolume > 0.5 && upTrigger != null) {
          upTrigger?.value = true;
          // Reset trigger
          Future.delayed(const Duration(milliseconds: 500), () {
            upTrigger?.value = false;
          });
        }
      });
    } catch (e) {
      print('Amplitude reading error: $e');
    }
  }

  Future<void> playStartupSound() async {
    if (!_isSoundInitialized) return;
    try {
      await _player.openPlayer();
      await _player.startPlayer(
        fromURI: startupSoundPath,
        whenFinished: () async {
          await _player.stopPlayer();
          await _player.closePlayer();
        },
      );
    } catch (e) {
      print("Error playing startup sound: $e");
    }
  }

  Future<void> playStopSound() async {
    if (!_isSoundInitialized) return;
    try {
      await _player.openPlayer();
      await _player.startPlayer(
        fromURI: stopSoundPath,
        whenFinished: () async {
          await _player.stopPlayer();
          await _player.closePlayer();
        },
      );
    } catch (e) {
      print("Error playing stop sound: $e");
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

      filePath = '${recordingsDir.path}/recording.aac';

      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
      );

      isRecording.value = true;
      playStartupSound();

      _startTimer();
      _startAmplitudeMonitoring();
      print("Recording started at: $filePath");
    } catch (e) {
      print("Error starting recorder: $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      await _recorder.stopRecorder();
      isRecording.value = false;
      playStopSound();
      _stopTimer();
      _amplitudeTimer?.cancel();
      volume.value = 0.0;

      bool? shouldSave = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Save Recording'),
          content: Text('Do you want to save this recording?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('No'),
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('Save'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
                textStyle: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      if (shouldSave == true) {
        print("Recording saved: $filePath");
        if (filePath != null) {
          String fileName = basename(filePath!);
          print("File name: $fileName");

          String? result =
              await TranscriptApi.getTranscript(filePath!, fileName, fileDir!);
          if (result != null) {
            transcript.value = result;
            aiResponse.value = await AIApi.getAIMinutes(result, fileDir!);
          }
        }
      } else {
        // Delete the recording if user cancels
        if (filePath != null && File(filePath!).existsSync()) {
          await File(filePath!).delete();
          print("Recording deleted: $filePath");
        }
        if (fileDir != null && Directory(fileDir!).existsSync()) {
          await Directory(fileDir!).delete(recursive: true);
          print("Directory deleted: $fileDir");
        }
        transcript.value = "";
        aiResponse.value = "";
      }
    } catch (e) {
      print("Error stopping recorder: $e");
      Get.snackbar(
        'Error',
        'Failed to process recording',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
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
    recordingTime.value = "00:00:00";
  }

  String _formatDuration(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$secs";
  }

  @override
  void onClose() {
    _player.closePlayer();
    _recorder.closeRecorder();
    _stopTimer();
    _amplitudeTimer?.cancel();
    _riveController?.dispose();
    super.onClose();
  }
}
