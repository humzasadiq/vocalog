import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';

class Audioplayer extends StatefulWidget {
  const Audioplayer({super.key, required this.filePath, required this.calar});
  final String filePath;
  final Color calar;

  @override
  State<Audioplayer> createState() => _AudioplayerState();
}

class _AudioplayerState extends State<Audioplayer> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  StreamSubscription? _playerSubscription;
  String? _localFilePath;
  RxBool isLoading = false.obs;
  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    isLoading.value = true;
    await _player.openPlayer();
    _player.setSubscriptionDuration(const Duration(milliseconds: 100));

    try {
      final url = widget.filePath;
      final response = await HttpClient().getUrl(Uri.parse(url));
      final fileStream = await response.close();

      final dir = await getTemporaryDirectory();
      final localFile = File("${dir.path}/downloaded_audio.aac");

      // ✅ Fix: Use openWrite() to get a StreamConsumer
      await fileStream.pipe(localFile.openWrite());

      setState(() {
        _localFilePath = localFile.path;
      });

      _playerSubscription = _player.onProgress?.listen((event) {
        setState(() {
          _currentPosition = event.position;
          _totalDuration = event.duration;
        });
      });
      isLoading.value = false;
    } catch (e) {
      debugPrint("Error downloading audio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed to load audio."),
        ),
      );
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_localFilePath == null) return;

    if (_isPlaying) {
      await _player.stopPlayer();
    } else {
      await _player.startPlayer(
        fromURI: _localFilePath,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
            _currentPosition = Duration.zero;
          });
        },
      );
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours != "00" ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
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
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        _formatDuration(_totalDuration),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () async {
                try {
                  await Share.shareXFiles(
                    [XFile(widget.filePath)],
                    subject: 'Audio Recording',
                  );
                } catch (e) {
                  debugPrint('Error sharing file: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Failed to share file'),
                    ),
                  );
                }
              },
              icon: Icon(
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
