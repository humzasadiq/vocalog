import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocalog/view/Widgets/OutputWidget/aiResponseWidget.dart';
import 'package:intl/intl.dart';
import 'package:vocalog/view/Widgets/OutputWidget/chatWithMeeting.dart';
import '../Widgets/OutputWidget/toggleButton.dart';
import 'package:vocalog/view/Widgets/OutputWidget/audioNtranscript.dart';

class Outputscreen extends StatefulWidget {
  Outputscreen({
    super.key,
    required this.calar,
    required this.filePath,
    required this.index,
    required this.fileStat,
    required this.transcript,
    required this.output,
    required this.fileDuration,
  });

  final String filePath;
  final String fileStat;
  final String transcript;
  final String output;
  final int index;
  final Color calar;
  final String fileDuration;

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
          backgroundColor: Colors.black,
          title: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: widget.calar,
              ),
              Text(
                "Recording ${widget.index + 1}",
                style:  TextStyle(
                  color: widget.calar,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(
                        "Dated: ",
                        style: TextStyle(
                          color: widget.calar,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${widget.fileStat}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ]),
                    Row(
                      children: [
                        Row(children: [
                          Text(
                            "Day: ",
                            style: TextStyle(
                              color: widget.calar,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "${datetoWeekDayName(widget.fileStat)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ]),
                        const SizedBox(width: 20),
                        Row(
                          children: [
                            Text(
                              "Duration: ",
                              style: TextStyle(
                                color: widget.calar,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "${widget.fileDuration}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Divider(
                      color: Colors.white.withOpacity(0.2),
                      thickness: 1,
                      height: 1,
                    ),
                  ],
                ),
              ),
              MyToggleButton(
                onToggle: (int index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                calar: widget.calar,
              ),
              const SizedBox(height: 20),
              _getContentForIndex(selectedIndex, dirPath),
            ],
          ),
        ));
  }

  Widget _getContentForIndex(int index, String dirPath) {
    switch (index) {
      case 0:
        return AudioNtranscript(
            filePath: widget.filePath,
            transcript: widget.transcript,
            calar: widget.calar); // Audio + Transcript Widget
      case 1:
        return AIResponseWidget(output: widget.output, calar: widget.calar,); // AI Response Widget
      case 2:
        return ChatWithMeeting(
            filePath: dirPath, calar: widget.calar); // Chat with meeting Widget
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
