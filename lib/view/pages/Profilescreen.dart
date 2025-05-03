import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:velocity_x/velocity_x.dart';
import 'package:vocalog/utils/Themes.dart';
import 'package:vocalog/view/pages/PersonalInfoScreen.dart';

import '../../Models/User.dart';
import '../../controllers/UserController.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserController userController = Get.find<UserController>();
  void restartApp() {
    SystemNavigator.pop(); // This exits the app
  }

  @override
  Widget build(BuildContext context) {
    RxBool isLoading = false.obs;

    // bool isDark = Theme.of(context).da

    final currentTheme = Theme.of(context);

    return Scaffold(
      backgroundColor: currentTheme.primaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        title: Container(
            child: "Profile"
                .text
                .color(Colors.white)
                .bold
                .make()),
      ),
      body: Obx(() {
        CurrentUser? user = userController.user.value!;
        if (userController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        } else if (userController.user.value == null) {
          return Center(
            child: Text("User not found").text.color(Colors.white).make(),
          );
        } else {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      "Account Information"
                          .text
                          .color(AppConstant.primary)
                          .bold
                          .xl
                          .make(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: Get.width * 0.23,
                            child: "Email"
                                .text
                                .color(currentTheme.colorScheme.tertiaryFixed)
                                .make(),
                          ),
                          user.email.text
                              .textStyle(const TextStyle(fontSize: 10))
                              .make(),
                          // IconButton(
                          //   iconSize: 18,
                          //   onPressed: () {},
                          //   icon: Icon(Iconsax.edit,color: currentTheme.colorScheme.tertiaryFixed,)
                          // ),
                        ],
                      ).pOnly(top: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: Get.width * 0.23,
                            child: "User Id"
                                .text
                                .color(currentTheme.colorScheme.tertiaryFixed)
                                .make(),
                          ),
                          user.id.text
                              .overflow(TextOverflow.ellipsis)
                              .textStyle(const TextStyle(fontSize: 10))
                              .make()
                              .w(Get.width * 0.5),
                          Spacer(),
                          IconButton(
                              iconSize: 18,
                              onPressed: () {},
                              icon: Icon(
                                Iconsax.copy,
                                color: currentTheme.colorScheme.tertiaryFixed,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  endIndent: 20,
                  indent: 20,
                  color: Colors.white.withOpacity(0.2),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          "Personal Information".text.bold.xl.make(),
                          IconButton(
                              onPressed: () {
                                Get.to(() => UpdateUserInfoScreen(
                                      userModel: user,
                                    ));
                              },
                              icon: Icon(
                                Iconsax.edit,
                                color: currentTheme.colorScheme.tertiaryFixed,
                              ))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          "Name"
                              .text
                              .color(currentTheme.colorScheme.tertiaryFixed)
                              .make(),
                          user.name.text
                              .textStyle(const TextStyle(fontSize: 10))
                              .make()
                              .pOnly(left: 62),
                        ],
                      ).pOnly(top: 5),
                    ],
                  ),
                )
              ],
            ),
          );
        }
      }),
    );
  }
}
