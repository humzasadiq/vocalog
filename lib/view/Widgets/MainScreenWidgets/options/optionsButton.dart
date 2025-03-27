import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocalog/controllers/recorder.dart';

import 'package:vocalog/view/Widgets/MainScreenWidgets/logforDropDown.dart';
import 'package:vocalog/view/Widgets/MainScreenWidgets/speakerCheckbox.dart';
import 'package:vocalog/view/Widgets/MainScreenWidgets/topicTextField.dart';

class OptionsButton extends StatefulWidget {
  const OptionsButton({super.key});

  @override
  State<OptionsButton> createState() => _OptionsButtonState();
}

class _OptionsButtonState extends State<OptionsButton> {
  final RecorderController recorderController = Get.find<RecorderController>();
  OverlayEntry? _overlayEntry;

  void _toggleOptions(BuildContext context) {
    if (_overlayEntry == null) {
      _overlayEntry = _createOptionsOverlay(context);
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOptionsOverlay(BuildContext context) {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: GestureDetector(
          onTap: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
          },
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  color: Color(0xFF101010),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    // Close button
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          _overlayEntry?.remove();
                          _overlayEntry = null;
                        },
                      ),
                    ),
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        radius: const Radius.circular(10),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                Topictextfield(),
                                const SizedBox(height: 10),
                                Logfordropdown(),
                                const SizedBox(height: 10),
                                SpeakerCheckbox(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(50, 30),
          alignment: Alignment.centerLeft,
          side: BorderSide(width: 1.0, color: Colors.grey.shade600),
        ),
        onPressed: () {
            _toggleOptions(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Icon(
                color: !recorderController.isRecording.value
                    ? Colors.grey
                    : Colors.grey.shade300,
                Icons.add)),
            Obx(() => Text(
                  'options',
                  style: TextStyle(
                    color: !recorderController.isRecording.value
                        ? Colors.grey
                        : Colors.grey.shade300,
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Ensure overlay is removed when widget is disposed
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }
}
