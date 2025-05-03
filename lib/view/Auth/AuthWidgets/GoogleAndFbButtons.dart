// import 'package:ecom_mobile/Controllers/UserController.dart';
// import 'package:ecom_mobile/Controllers/googleSignInController.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:velocity_x/velocity_x.dart';


// class GoogleAndFb extends StatelessWidget {
//   GoogleAndFb({
//     super.key,
//     required this.currentTheme,
//   });

//   final ThemeData currentTheme;
//   final UserController userController = Get.put(UserController());
//   final GoogleSignInController googleSignInController =
//       Get.put(GoogleSignInController());
//   final FacebookSignInController facebookSigninController =
//       Get.put(FacebookSignInController());
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         TextButton(
//           onPressed: () async {
//             await googleSignInController.SignInWithGoogle();
//           },
//           child: SizedBox(
//             width: Get.width * 0.25,
//             height: Get.height * 0.09,
//             child: Card(
//                 elevation: 2,
//                 color: currentTheme.dividerColor,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15)),
//                 child: Image.asset(
//                   "assets/google.png",
//                 )),
//           ),
//         ),
//         20.widthBox,
//         TextButton(
//           onPressed: () async {
//             await facebookSigninController.signInWithFacebook();
//           },
//           child: SizedBox(
//             width: Get.width * 0.25,
//             height: Get.height * 0.09,
//             child: Card(
//                 elevation: 2,
//                 color: currentTheme.dividerColor,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15)),
//                 child: Image.asset(
//                   "assets/Fb.png",
//                 )),
//           ),
//         ),
//       ],
//     );
//   }
// }
