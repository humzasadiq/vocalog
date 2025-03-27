import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';

class Audioplayer extends StatefulWidget {
  const Audioplayer({super.key, required this.filePath});
  final String filePath;

  @override
  State<Audioplayer> createState() => _AudioplayerState();
}

class _AudioplayerState extends State<Audioplayer> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  StreamSubscription? _playerSubscription;

  @override
  void initState() {
    super.initState();
    
    _player.openPlayer().then((_) {
      setState(() {
        if (_player.onProgress != null) {
          _playerSubscription = _player.onProgress!.listen((event) {
            setState(() {
              _currentPosition = event.position;
              _totalDuration = event.duration;
            });
          });
        }
      });
    });
    _player.setSubscriptionDuration(const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _player.stopPlayer();
    } else {
      await _player.startPlayer(
        fromURI: widget.filePath,
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
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF101010), // Match the dark theme
        borderRadius: BorderRadius.circular(10),
        
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.filePath.split('/').last,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: _totalDuration.inMilliseconds > 0
                ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
                : 0,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _togglePlayback,
            icon: Icon(
              _isPlaying ? Icons.stop : Icons.play_arrow,
              color: Colors.black,
            ),
            label: Text(
              _isPlaying ? 'Stop' : 'Play',
              style: const TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white70, // Match the theme
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}