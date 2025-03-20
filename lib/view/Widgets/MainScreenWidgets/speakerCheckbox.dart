import 'package:flutter/material.dart';

/// Flutter code sample for [Checkbox].

class SpeakerCheckbox extends StatefulWidget {
  @override
  State<SpeakerCheckbox> createState() => _SpeakerCheckboxState();
}

class _SpeakerCheckboxState extends State<SpeakerCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.white;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              checkColor: Colors.black,
              fillColor: WidgetStateProperty.resolveWith(getColor),
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value!;
                });
              },
            ),
            Text(
              "Number of Speakers (Optional)",
              style: TextStyle(
                  fontSize: 13,
                  color: (isChecked
                      ? Colors.white
                      : Color.fromARGB(255, 137, 137, 137))),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        if (isChecked)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
              
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15, left: 10),
                child: Container(
                  width: 1,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      maxLength: 2,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Enter the Number of Speakers",
                        labelStyle:
                            TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: "Comma (,) separated Names of Speakers",
                        labelStyle:
                            TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
      ],
    );
  }
}
