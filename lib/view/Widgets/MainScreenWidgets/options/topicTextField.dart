import 'package:flutter/material.dart';

class Topictextfield extends StatelessWidget {
  const Topictextfield({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: TextField(
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            fillColor: Colors.white,
            border: OutlineInputBorder(),
            labelText: "Topic of Interest",
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
      )
    );
  }
}