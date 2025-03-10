import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vocalog/view/HistoryScreen.dart';
import 'package:vocalog/view/MainScreen.dart';
import 'utils/Themes.dart';
import 'view/Widgets/micwidget.dart';
import 'view/Widgets/scriptWidget.dart';
import 'view/MainScreen.dart';


void main() {
  runApp(const MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: MyTheme.darkTheme(context),
      
      title: 'Weather Guy',
      builder: EasyLoading.init(),
      home: VocalogScreen(),
    );
  }
}

class VocalogScreen extends StatefulWidget {
  const VocalogScreen({super.key});

  @override
  State<VocalogScreen> createState() => _VocalogScreenState();
}

class _VocalogScreenState extends State<VocalogScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        indicatorColor: Colors.blueAccent,
        backgroundColor: Colors.black,
        selectedIndex: currentIndex,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.mic),
            label: 'Record',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
      body: <Widget>[
        MainScreen(),
        HistoryScreen(),
      ][currentIndex],
    );
  }
}