import 'package:flutter/material.dart';

class MyToggleButton extends StatefulWidget {
  final Function(int) onToggle;

  MyToggleButton({super.key, required this.onToggle, required this.calar});
  final Color calar;

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
            SegmentedButton<int>(
              showSelectedIcon: false,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return widget.calar; // Selected background color
                    }
                    return Colors.transparent; // Unselected background color
                  },
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.white; // Selected text color
                    }
                    return widget.calar; // Unselected text color
                  },
                ),
                side: MaterialStateProperty.all(
                  BorderSide(color: widget.calar),
                ),
              ),
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text(
                    "Audio +\n Transcript",
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                ButtonSegment(value: 1, label: Text("Output")),
                ButtonSegment(value: 2, label: Text("Chat")),
              ],
              selected: {isSelected.indexOf(true)},
              
              onSelectionChanged: (Set<int> newSelection) {
                int selectedIndex = newSelection.first;
                setState(() {
                  for (int i = 0; i < isSelected.length; i++) {
                    isSelected[i] = i == selectedIndex;
                  }
                });
                widget.onToggle(selectedIndex);
              },
            ),
          ],
        ),
      ),
    );
  }
}