import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Audioplayer extends StatefulWidget {
  const Audioplayer({super.key, required this.filePath, required this.calar});
  final String filePath;
  final Color calar;

  @override
  State<Audioplayer> createState() => _AudioplayerState();
}

class _AudioplayerState extends State<Audioplayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  RxBool isLoading = false.obs;
  String? _localFilePath;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    if (_isDisposed) return;
    isLoading.value = true;
    try {
      // Set up position stream
      _player.positionStream.listen((position) {
        if (!_isDisposed) {
          setState(() {
            _currentPosition = position;
          });
        }
      });

      // Set up duration stream
      _player.durationStream.listen((duration) {
        if (!_isDisposed && duration != null) {
          setState(() {
            _totalDuration = duration;
          });
        }
      });

      // Set up player completion
      _player.playerStateStream.listen((state) {
        if (!_isDisposed && state.processingState == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
            _currentPosition = Duration.zero;
          });
        }
      });

      // Download and cache the audio file
      final url = widget.filePath;
      final response = await HttpClient().getUrl(Uri.parse(url));
      final fileStream = await response.close();
      final dir = await getTemporaryDirectory();
      final localFile = File("${dir.path}/downloaded_audio.aac");
      await fileStream.pipe(localFile.openWrite());
      _localFilePath = localFile.path;

      // Set the audio source
      await _player.setAudioSource(
        AudioSource.uri(Uri.file(_localFilePath!)),
        preload: true,
      );

      if (!_isDisposed) {
        isLoading.value = false;
      }
    } catch (e) {
      debugPrint("Error initializing audio player: $e");
      if (!_isDisposed) {
        Get.snackbar(
          "Error",
          "Failed to load audio file. Please try again.",
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
        );
        isLoading.value = false;
      }
    }
  }

  Future<void> _togglePlayback() async {
    if (_isDisposed) return;
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }
      if (!_isDisposed) {
        setState(() {
          _isPlaying = !_isPlaying;
        });
      }
    } catch (e) {
      debugPrint("Error toggling playback: $e");
      if (!_isDisposed) {
        Get.snackbar(
          "Error",
          "Failed to play audio. Please try again.",
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours != "00" ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
  }

  @override
  void dispose() {
    _isDisposed = true;
    try {
      _player.pause();
      _player.dispose();
    } catch (e) {
      debugPrint("Error disposing player: $e");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: widget.calar,
          ),
        );
      }
      return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: widget.calar.withOpacity(0.1),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: _togglePlayback,
              icon: Icon(
                _isPlaying ? Icons.stop : Icons.play_arrow,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.calar,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: LinearProgressIndicator(
                      value: _totalDuration.inMilliseconds > 0
                          ? _currentPosition.inMilliseconds /
                              _totalDuration.inMilliseconds
                          : 0,
                      backgroundColor: widget.calar.withOpacity(0.5),
                      valueColor: AlwaysStoppedAnimation<Color>(widget.calar),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_currentPosition),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        _formatDuration(_totalDuration),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () async {
                if (_localFilePath == null) {
                  Get.snackbar(
                    "Error",
                    "Audio is still loading, please wait",
                    backgroundColor: Colors.red.withOpacity(0.1),
                    colorText: Colors.red,
                    snackPosition: SnackPosition.TOP,
                    duration: Duration(seconds: 3),
                  );
                  return;
                }
                
                try {
                  await Share.shareXFiles(
                    [XFile(_localFilePath!)],
                    subject: 'Audio Recording',
                  );
                } catch (e) {
                  debugPrint('Error sharing file: $e');
                  Get.snackbar(
                    "Error",
                    "Failed to share file: ${e.toString()}",
                    backgroundColor: Colors.red.withOpacity(0.1),
                    colorText: Colors.red,
                    snackPosition: SnackPosition.TOP,
                    duration: Duration(seconds: 3),
                  );
                }
              },
              icon: const Icon(
                Icons.ios_share,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.calar,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}