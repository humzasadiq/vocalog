import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:vocalog/Models/User.dart';
import 'package:vocalog/controllers/UserController.dart';
import 'package:vocalog/utils/Themes.dart';
import 'package:vocalog/view/pages/Profilescreen.dart';

import '../Widgets/DialogLogoutWidget.dart';

class UpdateUserInfoScreen extends StatelessWidget {
  CurrentUser userModel;
  final TextEditingController nameController = TextEditingController();
  // final TextEditingController phoneController = TextEditingController();
  // final TextEditingController cityController = TextEditingController();
  // final TextEditingController addressController = TextEditingController();
  // final TextEditingController streetController = TextEditingController();
  // // final ChangeInfoController changeInfoController =
  //     Get.put(ChangeInfoController());
  final UserController userController = Get.find<UserController>();

  UpdateUserInfoScreen({super.key, required this.userModel}) {
    nameController.text = userModel.name;
  }
  RxBool isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    return Scaffold(
      backgroundColor: currentTheme.primaryColor,
      appBar: AppBar(
        title: Text(
          'Update Information',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              controller: nameController,
              labelText: 'Name',
              icon: Icons.person,
              theme: currentTheme,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialog(
                      title: "Save Changes",
                      content: "Are you sure ?",
                      onCancel: () {
                        Navigator.of(context).pop();
                        nameController.text = userModel.name;

                        Navigator.of(context).pop();
                      },
                      onConfirm: () async {
                        Navigator.of(context).pop();

                        await userController.updateUser(
                          userController.user.value!.id,
                          name: nameController.text,
                        );
                        // Navigator.of(context).pop();

                        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        //   content: Text(
                        //     'Information Updated',
                        //     style: TextStyle(
                        //         color: currentTheme.colorScheme.surface),
                        //   ),
                        //   backgroundColor: currentTheme.colorScheme.onPrimary,
                        // ));
                        // Get.back();
                        Get.off(() => ProfileScreen());
                      });
                });
          },
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                currentTheme.colorScheme.onPrimary,
              ),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)))),
          child: Text(
            'Save Changes',
            style: TextStyle(color: AppConstant.primary),
          ),
        ).h(Get.height / 16),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required ThemeData theme,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: theme.colorScheme.tertiaryFixed),
        prefixIcon: Icon(icon, color: AppConstant.primary),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.tertiary),
        ),
        hintStyle: TextStyle(color: theme.colorScheme.tertiaryFixed),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required ThemeData theme,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: theme.colorScheme.tertiaryFixed),
        prefixIcon: Icon(icon, color: theme.colorScheme.onPrimary),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.tertiary),
        ),
        hintStyle: TextStyle(color: theme.colorScheme.tertiaryFixed),
      ),
    );
  }
}
