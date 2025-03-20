import 'package:flutter/material.dart';

class MyToggleButton extends StatefulWidget {
  final Function(int) onToggle;

  const MyToggleButton({super.key, required this.onToggle});

  @override
  _MyToggleButtonState createState() => _MyToggleButtonState();
}

class _MyToggleButtonState extends State<MyToggleButton> {
  List<bool> isSelected = [true, false, false];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            ToggleButtons(
              isSelected: isSelected,
              borderRadius: BorderRadius.circular(30),
              selectedColor: Colors.black,
              fillColor: Colors.white,
              color: Colors.white70,
              constraints: const BoxConstraints(minWidth: 100, minHeight: 40),
              children: const [
                Text("Audio"),
                Text("Transcript"),
                Text("Output"),
              ],
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < isSelected.length; i++) {
                    isSelected[i] = i == index;
                  }
                });
                widget.onToggle(index);
              },
            ),
          ],
        ),
      ),
    );
  }
}