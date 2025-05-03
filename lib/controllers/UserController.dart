import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocalog/view/Auth/SignInScreen.dart';
import '../Models/User.dart';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Rx<CurrentUser?> user = Rx<CurrentUser?>(null);
  RxBool isLoggedIn = false.obs;
  RxBool isLoading = false.obs;

  Future<void> _saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  Future<String?> _getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  Future<void> _removeEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
  }

  /// 🔍 Fetch User by Email
  Future<void> fetchUser(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        user.value = CurrentUser.fromJson(userData);
        isLoggedIn.value = true;
      } else {
        user.value = null;
        isLoggedIn.value = false;
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    try {
      // Firebase Authentication
      isLoading.value = true;
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.sendEmailVerification();

      // Save user info to Firestore
      final newUser = {
        'id': userCredential.user!.uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp()
      };

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser);

      user.value = CurrentUser.fromJson(newUser);
      isLoggedIn.value = true;
      await _saveEmail(email);

      Get.snackbar(
          "Success", "User created successfully. Please verify your email.");
      isLoading.value = false;
      Get.to(() => LogInScreen());
    } catch (e) {
      Get.snackbar("Error", "Signup failed: $e");
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      // Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        Get.snackbar("Warning", "Please verify your email before logging in");
        return;
      }

      // Fetch user data from Firestore using UID
      final uid = userCredential.user!.uid;
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        user.value = CurrentUser.fromJson(docSnapshot.data()!);
        isLoggedIn.value = true;
        await _saveEmail(email);
        Get.snackbar("Success", "Login successful");
        isLoading.value = false;
      } else {
        Get.snackbar("Error", "No user data found in Firestore");
        isLoading.value = false;
      }
    } catch (e) {
      Get.snackbar("Error", "Login failed: $e");
      isLoading.value = false;
    }
  }

  /// ✅ Check Session
  Future<void> checkSession() async {
    isLoading.value = true;

    String? storedEmail = await _getEmail();
    if (storedEmail == null) {
      isLoggedIn.value = false;
      isLoading.value = false;

      return;
    }
    await fetchUser(storedEmail);
    isLoading.value = false;
  }

  /// 🚪 Logout
  Future<void> logout() async {
    await _removeEmail();
    user.value = null;
    isLoggedIn.value = false;
    Get.snackbar("Success", "Logged out successfully");
  }

  Future<void> forgetPasswordMethod(String userEmail) async {
    try {
      // EasyLoading.show(status: "Please Wait ..");

      // Check if the user email exists in Firestore
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (userQuery.docs.isEmpty) {
        // If the email is not registered, show an error
        // EasyLoading.dismiss();
        Get.snackbar("Error", "No user found with this email",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFFF5722),
            colorText: Colors.white);
      } else {
        // If the email is registered, send the password reset email
        await _auth.sendPasswordResetEmail(email: userEmail);
        // EasyLoading.dismiss();
        Get.snackbar("Request sent successfully",
            "Password reset link sent to $userEmail",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFFF5722),
            colorText: Colors.white);
        Get.offAll(() => const LogInScreen());
      }
    } on FirebaseAuthException catch (e) {
      // EasyLoading.dismiss();
      Get.snackbar("Error", e.message ?? "An error occurred",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFF5722),
          colorText: Colors.white);
    }
  }

  /// ✏️ Update User
  Future<void> updateUser(String userId, {String? name, String? email}) async {
    try {
      Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;

      await _firestore.collection('users').doc(userId).update(updateData);

      final updatedDoc = await _firestore.collection('users').doc(userId).get();

      user.value = CurrentUser.fromJson(updatedDoc.data()!);
      Get.snackbar("Success", "User updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to update user: $e");
    }
  }

  /// ❌ Delete User
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      await _removeEmail();
      user.value = null;
      isLoggedIn.value = false;
      Get.snackbar("Success", "Account deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete user: $e");
    }
  }
}
