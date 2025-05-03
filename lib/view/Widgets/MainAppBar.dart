import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocalog/view/pages/Profilescreen.dart';
import 'package:vocalog/view/pages/SettingsScreen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      centerTitle: true,
      elevation: 2,
      actions: [
        IconButton(
          onPressed: () => Get.to(() => ProfileScreen()),
          icon: const Icon(Icons.person),
          color: Colors.grey,
        ),
      ],
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'IBM',
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}
