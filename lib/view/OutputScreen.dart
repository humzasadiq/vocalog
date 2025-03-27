import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocalog/view/Widgets/OutputWidget/aiResponseWidget.dart';
import 'package:vocalog/view/Widgets/OutputWidget/audioPlayer.dart';
import 'package:intl/intl.dart';
import 'Widgets/OutputWidget/toggleButton.dart';
import 'Widgets/OutputWidget/scriptWidget.dart';

class Outputscreen extends StatefulWidget {
  Outputscreen({
    super.key,
    required this.filePath,
    required this.index,
    required this.fileStat,
  });

  final String filePath;
  final String fileStat;
  final int index;

  @override
  State<Outputscreen> createState() => _OutputscreenState();
}

class _OutputscreenState extends State<Outputscreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final dirPath = widget.filePath
        .split('/')
        .sublist(0, widget.filePath.split('/').length - 1)
        .join('/');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF101010),
        title: Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Recording ${widget.index + 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Dated: ${widget.fileStat}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Day: ${datetoWeekDayName(widget.fileStat)}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          MyToggleButton(
            onToggle: (int index) {
              setState(() {
                selectedIndex = index; // Update the selected index
              });
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _getContentForIndex(selectedIndex, dirPath), // Automatically expand
          ),
        ],
      ),
    );
  }

  Widget _getContentForIndex(int index, String dirPath) {
    switch (index) {
      case 0:
        return Audioplayer(filePath: widget.filePath); // Audio player
      case 1:
        return transcriptWidget(filePath: dirPath); // transcript Widget
      case 2:
        return AIResponseWidget(filePath: dirPath); // AI Response Widget
      default:
        return const Center(
          child: Text(
            "Unknown Content",
            style: TextStyle(color: Colors.white),
          ),
        );
    }
  }
}

String datetoWeekDayName(String date) {
  try {
    var dateTime = DateTime.parse(date);
    return DateFormat('EEEE').format(dateTime);
  } catch (e) {
    return "Invalid Date";
  }
}
