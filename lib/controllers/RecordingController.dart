import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:vocalog/controllers/UserController.dart';
import 'package:http/http.dart' as http;

import '../Models/Recording.dart';

class RecordingController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  RxList<Recording> recordings = <Recording>[].obs;

  RxBool isLoading = false.obs;
  UserController userController = Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    fetchUserRecordings();
  }

  /// ✅ Delete all recordings for the current user
  Future<void> deleteAllRecordings() async {
    try {
      isLoading.value = true;
      final userId = userController.user.value?.id;
      if (userId == null) throw Exception("User ID not found");

      final querySnapshot = await firestore
          .collection('recordings')
          .where('user_id', isEqualTo: userId)
          .get();

      final batch = firestore.batch();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      await fetchUserRecordings();
      Get.snackbar("Success", "All recordings deleted successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Upload recording file to Firebase Storage
  Future<String?> uploadRecordingToFirebase(
      File recordingFile, String userId) async {
    try {
      final bucket = 'e-commerece-f7d89.appspot.com'; // your storage bucket
      final fileName =
          'recordings/$userId/${DateTime.now().millisecondsSinceEpoch}.aac';
      final url =
          'https://firebasestorage.googleapis.com/v0/b/$bucket/o?uploadType=media&name=$fileName';

      final bytes = await recordingFile.readAsBytes();

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'audio/aac',
        },
        body: bytes,
      );

      if (response.statusCode == 200) {
        final encodedPath = Uri.encodeComponent(fileName);
        final downloadUrl =
            'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
        return downloadUrl;
      } else {
        print('Recording upload failed: ${response.statusCode}');
        print(response.body);
        return null;
      }
    } catch (e) {
      print("Recording upload error: $e");
      return null;
    }
  }

  /// ✅ Create recording in Firestore
  Future<void> createRecording(
      String topic, String fileUrl, String transcript, String output) async {
    try {
      isLoading.value = true;
      final userId = userController.user.value?.id;
      if (userId == null) throw Exception("User ID not found");

      await firestore.collection('recordings').add({
        'user_id': userId,
        'topic': topic,
        'file_link': fileUrl,
        'transcript': transcript,
        'output': output,
        'created_at': FieldValue.serverTimestamp(),
      });

      await fetchUserRecordings();
      Get.snackbar("Success", "Recording created successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Fetch user recordings
  Future<void> fetchUserRecordings() async {
    try {
      isLoading.value = true;
      final userId = userController.user.value?.id;
      if (userId == null) throw Exception("User ID not found");

      final query = await firestore
          .collection('recordings')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      recordings.value = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID for model
        // Convert Timestamp to ISO String for model
        if (data.containsKey('created_at')) {
          data['datetime'] =
              (data['created_at'] as Timestamp).toDate().toIso8601String();
        }
        return Recording.fromJson(data);
      }).toList();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Update recording
  Future<void> updateRecording(String docId, String topic, String fileLink,
      String transcript, String output) async {
    try {
      isLoading.value = true;
      await firestore.collection('recordings').doc(docId).update({
        'topic': topic,
        'file_link': fileLink,
        'transcript': transcript,
        'output': output,
        'updated_at': FieldValue.serverTimestamp(),
      });

      await fetchUserRecordings();
      Get.snackbar("Success", "Recording updated successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Delete recording
  Future<void> deleteRecording(String docId) async {
    try {
      isLoading.value = true;
      await firestore.collection('recordings').doc(docId).delete();
      await fetchUserRecordings();
      Get.snackbar("Success", "Recording deleted successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
