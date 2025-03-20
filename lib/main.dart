import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vocalog/view/HistoryScreen.dart';
import 'package:vocalog/view/MainScreen.dart';
import 'utils/Themes.dart';
import 'controllers/recorder.dart';
void main() {
  // Initialize RecorderController before running the app
  Get.lazyPut(() => RecorderController());
  runApp(MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  late final RecorderController recorderController = Get.find<RecorderController>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(fontFamily: 'IBM'),
      title: 'vocalog',
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
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Color(0xFF101010),
          indicatorColor: Colors.white,
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(color: Colors.white),
          ),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return IconThemeData(color: Colors.black);
            }
            return IconThemeData(color: Colors.white);
          }),
        ),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentIndex = index;
            });
          },
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
      ),
      body: <Widget>[
        MainScreen(),
        HistoryScreen(),
      ][currentIndex],
    );
  }
}