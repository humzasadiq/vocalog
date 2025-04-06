import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocalog/view/pages/SettingsScreen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFF040404),
      automaticallyImplyLeading: false,
      centerTitle: true,
      elevation: 2,
      actions: [],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 100,),
          Row(
            children: [
              const Text(
                '[vocalog]',
                style: TextStyle(
                  fontFamily: 'IBM',
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              // const Text(
              //   'cal',
              //   style: TextStyle(
              //     fontFamily: 'IBM',
              //     color: Colors.white,
              //     fontSize: 18,
              //   ),
              // ),
              // Container(
              //   width: 23,
              //   height: 23,
              //   decoration: BoxDecoration(
              //     image: DecorationImage(
              //       fit: BoxFit.cover,
              //       image: Image.asset(
              //         'assets/icon2.png',
              //       ).image,
              //     ),
              //     shape: BoxShape.circle,
              //   ),
              // ),
              // const Padding(
              //   padding: EdgeInsets.only(left: 2),
              //   child: Text(
              //     'g',
              //     style: TextStyle(
              //       fontFamily: 'IBM',
              //       color: Colors.white,
              //       fontSize: 18,
              //     ),
              //   ),
              // ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Get.to(SettingsScreen()),
                icon: const Icon(Icons.settings),
                color: Colors.grey,
              ),
              IconButton(
                onPressed: () => Get.to(SettingsScreen()),
                icon: const Icon(Icons.person_4),
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
