import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vocalog/controllers/RecordingController.dart';
import 'package:vocalog/view/Auth/SplashScreen.dart';
import 'package:vocalog/view/pages/HistoryScreen.dart';
import 'package:vocalog/view/pages/MainScreen.dart';
import 'package:vocalog/view/pages/SettingsScreen.dart';
import 'utils/Themes.dart';
import 'controllers/recorder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Failed to load .env file: $e");
  }
  Get.lazyPut(() => RecorderController());
  Get.lazyPut(() => RecordingController());
  await Firebase.initializeApp();
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
  late final RecorderController recorderController =
      Get.find<RecorderController>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        fontFamily: 'IBM',
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
            primary: Colors.grey.shade600,
            tertiaryFixed: AppConstant.primary,
            tertiary: AppConstant.primary),
      ),
      title: 'vocalog',
      builder: EasyLoading.init(),
      home: SplashScreen(),
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
      bottomNavigationBar: GetX<RecorderController>(
        builder: (controller) => NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.black,
            indicatorColor: Colors.white,
            labelTextStyle: MaterialStateProperty.all(
              TextStyle(
                color:
                    controller.isRecording.value ? Colors.grey : Colors.white,
              ),
            ),
            iconTheme: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return IconThemeData(color: Colors.black);
              }
              return IconThemeData(
                color:
                    controller.isRecording.value ? Colors.grey : Colors.white,
              );
            }),
          ),
          child: NavigationBar(
            onDestinationSelected: (int index) {
              if (!controller.isRecording.value) {
                setState(() {
                  currentIndex = index;
                });
              }
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
              NavigationDestination(
                icon: Icon(Icons.settings),
                label: 'Setting',
              ),
            ],
          ),
        ),
      ),
      body: <Widget>[
        MainScreen(),
        HistoryScreen(),
        SettingsScreen(),
      ][currentIndex],
    );
  }
}
