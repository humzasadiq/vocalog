import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const List<String> list = <String>['Meeting Minutes', 'Summary', 'Class Notes'];

class Logfordropdown extends StatefulWidget {
  const Logfordropdown({super.key});

  @override
  State<Logfordropdown> createState() => _LogfordropdownState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _LogfordropdownState extends State<Logfordropdown> {
  static final List<MenuEntry> menuEntries = UnmodifiableListView<MenuEntry>(
    list.map<MenuEntry>((String name) => MenuEntry(value: name, label: name)),
  );
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      textStyle: TextStyle(color: Colors.white),
      width: MediaQuery.of(context).size.width * 0.7,
      initialSelection: list.first,
      onSelected: (String? value) {
        setState(() {
          dropdownValue = value!;
        });
      },
      dropdownMenuEntries: menuEntries,
    );
  }
}