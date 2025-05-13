import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocalog/controllers/recorder.dart';

import 'package:vocalog/view/Widgets/MainScreenWidgets/options/logforDropDown.dart';
import 'package:vocalog/view/Widgets/MainScreenWidgets/options/languageDropdown.dart';

class OptionsButton extends StatelessWidget {
  OptionsButton({super.key});

  final RecorderController recorderController = Get.find<RecorderController>();

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: BackdropFilter(
            filter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.4,
              maxChildSize: 0.8,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF101010),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Recording Options',
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Options Content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                // Log Type Dropdown
                                Obx(() => Logfordropdown(
                                  initialValue: recorderController.logType.value,
                                  onChanged: (value) => recorderController.setLogType(value),
                                )),
                                const SizedBox(height: 20),
                                // Language Dropdown
                                Obx(() => LanguageDropdown(
                                  initialValue: recorderController.language.value,
                                  onChanged: (value) => recorderController.setLanguage(value),
                                )),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline, 
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Regardless of the input language, \nthe output will always be in English.",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40), // Extra padding at bottom

                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SizedBox(
        width: 100,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
            alignment: Alignment.centerLeft,
            side: BorderSide(width: 1.0, color: Colors.grey.shade600),
          ),
          onPressed: () => _showOptions(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => Icon(
                Icons.settings,
                color: !recorderController.isRecording.value
                    ? Colors.grey
                    : Colors.grey.shade300,
              )),
              const SizedBox(width: 4),
              Obx(() => Text(
                'options',
                style: TextStyle(
                  fontFamily: 'IBM',
                  color: !recorderController.isRecording.value
                      ? Colors.grey
                      : Colors.grey.shade300,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
