import 'package:flutter/material.dart';

class LoadingDots extends StatefulWidget {
  final String status;
  final bool isComplete;
  final bool isError;

  const LoadingDots({
    Key? key,
    required this.status,
    this.isComplete = false,
    this.isError = false,
  }) : super(key: key);

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _dots = '...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          if (_controller.value < 0.33) {
            _dots = '.';
          } else if (_controller.value < 0.66) {
            _dots = '..';
          } else {
            _dots = '...';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isComplete) {
      return Text(
        '..?',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'IBM',
        ),
      );
    }

    if (widget.isError) {
      return Text(
        '*Error*',
        style: TextStyle(
          color: Colors.red,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'IBM',
        ),
      );
    }

    return Text(
      _dots,
      style: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'IBM',
      ),
    );
  }
} 