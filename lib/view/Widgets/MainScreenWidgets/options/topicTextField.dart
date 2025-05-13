import 'package:flutter/material.dart';

class Topictextfield extends StatefulWidget {
  final Function(String) onChanged;
  final String initialValue;

  const Topictextfield({
    super.key,
    required this.onChanged,
    required this.initialValue,
  });

  @override
  State<Topictextfield> createState() => _TopictextfieldState();
}

class _TopictextfieldState extends State<Topictextfield> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(Topictextfield oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: TextField(
          controller: _controller,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          onChanged: widget.onChanged,
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