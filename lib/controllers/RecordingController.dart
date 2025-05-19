import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:vocalog/controllers/UserController.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import '../Models/Recording.dart';

class RecordingController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  late final SupabaseClient supabase;

  RxList<Recording> recordings = <Recording>[].obs;

  RxBool isLoading = false.obs;
  UserController userController = Get.find<UserController>();

  // Flag to determine if we should use Supabase
  bool get useSupabase => Get.find<UserController>().user.value?.country == 'Pakistan';

  @override
  void onInit() {
    super.onInit();
    supabase = Supabase.instance.client;
    fetchUserRecordings();
  }

  /// ✅ Delete all recordings for the current user
  Future<void> deleteAllRecordings() async {
    try {
      isLoading.value = true;
      final userId = userController.user.value?.id;
      if (userId == null) throw Exception("User ID not found");

      if (useSupabase) {
        try {
          // First get all recordings to get their file paths
          final recordings = await supabase
              .from('recordings')
              .select()
              .eq('user_id', userId);
          
          // Delete files from storage
          for (var recording in recordings) {
            try {
              final filePath = recording['file_link'] as String;
              final fileName = filePath.split('/').last;
              await supabase
                  .storage
                  .from('recordings')
                  .remove(['$userId/$fileName']);
            } catch (e) {
              print('Error deleting file from storage: $e');
            }
          }

          // Delete from Supabase database
          final response = await supabase
              .from('recordings')
              .delete()
              .eq('user_id', userId);
          print('Supabase delete response: $response');
        } catch (e) {
          print('Supabase delete error: $e');
          throw Exception('Failed to delete from Supabase: $e');
        }
      } else {
        // Delete from Firebase
        final querySnapshot = await firestore
            .collection('recordings')
            .where('user_id', isEqualTo: userId)
            .get();

        // Delete files from storage
        for (var doc in querySnapshot.docs) {
          try {
            final fileUrl = doc.data()['file_link'] as String;
            final ref = storage.refFromURL(fileUrl);
            await ref.delete();
          } catch (e) {
            print('Error deleting file from storage: $e');
          }
        }

        final batch = firestore.batch();
        for (var doc in querySnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      await fetchUserRecordings();
      Get.snackbar("Success", "All recordings deleted successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Upload recording file to storage
  Future<String?> uploadRecordingToStorage(File recordingFile, String userId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.aac';
      String? fileUrl;
      int retryCount = 0;
      const maxRetries = 3;

      if (useSupabase) {
        try {
          // Upload to Supabase Storage
          final response = await supabase
              .storage
              .from('recordings')
              .upload('$userId/$fileName', recordingFile);
          print('Supabase upload response: $response');
              
          fileUrl = supabase
              .storage
              .from('recordings')
              .getPublicUrl('$userId/$fileName');
          print('Supabase file URL: $fileUrl');
        } catch (e) {
          print('Supabase upload error: $e');
          throw Exception('Failed to upload to Supabase: $e');
        }
      } else {
        // Upload to Firebase Storage with retry logic
        while (retryCount < maxRetries) {
          try {
            final bucket = 'e-commerece-f7d89.appspot.com';
            final storagePath = 'recordings/$userId/$fileName';
            final url = 'https://firebasestorage.googleapis.com/v0/b/$bucket/o?uploadType=media&name=$storagePath';

            final bytes = await recordingFile.readAsBytes();
            final response = await http.post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'audio/aac',
                'Authorization': 'Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}',
              },
              body: bytes,
            );

            if (response.statusCode == 200) {
              final encodedPath = Uri.encodeComponent(storagePath);
              fileUrl = 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
              break; // Success, exit retry loop
            } else {
              print('Firebase upload attempt $retryCount failed with status: ${response.statusCode}');
              print('Response body: ${response.body}');
              retryCount++;
              if (retryCount < maxRetries) {
                // Wait before retrying (exponential backoff)
                await Future.delayed(Duration(seconds: pow(2, retryCount).toInt()));
              }
            }
          } catch (e) {
            print('Firebase upload attempt $retryCount failed with error: $e');
            retryCount++;
            if (retryCount < maxRetries) {
              // Wait before retrying (exponential backoff)
              await Future.delayed(Duration(seconds: pow(2, retryCount).toInt()));
            }
          }
        }

        if (fileUrl == null) {
          throw Exception('Failed to upload to Firebase after $maxRetries attempts');
        }
      }

      return fileUrl;
    } catch (e) {
      print("Recording upload error: $e");
      return null;
    }
  }

  /// ✅ Create recording
  Future<void> createRecording(
      String topic, String fileUrl, String transcript, String output) async {
    try {
      isLoading.value = true;
      final userId = userController.user.value?.id;
      if (userId == null) throw Exception("User ID not found");

      final recordingData = {
        'user_id': userId,
        'topic': topic,
        'file_link': fileUrl,
        'transcript': transcript,
        'output': output,
        if (useSupabase) 'created_at': DateTime.now().toIso8601String(),
        if (!useSupabase) 'datetime': DateTime.now().toIso8601String(),
      };

      if (useSupabase) {
        try {
          // Create in Supabase
          final response = await supabase
              .from('recordings')
              .insert(recordingData);
          print('Supabase insert response: $response');
        } catch (e) {
          print('Supabase insert error: $e');
          throw Exception('Failed to insert into Supabase: $e');
        }
      } else {
        // Create in Firebase
        await firestore.collection('recordings').add({
          ...recordingData,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      await fetchUserRecordings();
      Get.snackbar(
        "Success", 
        "Recording created successfully!",
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );
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

      if (useSupabase) {
        try {
          print('Fetching from Supabase for user: $userId');
          // Fetch from Supabase
          final response = await supabase
              .from('recordings')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false);
          print('Supabase fetch response: $response');

          recordings.value = (response as List)
              .map((data) => Recording.fromJson(data))
              .toList();
        } catch (e) {
          print('Supabase fetch error: $e');
          throw Exception('Failed to fetch from Supabase: $e');
        }
      } else {
        // Fetch from Firebase
        final query = await firestore
            .collection('recordings')
            .where('user_id', isEqualTo: userId)
            .orderBy('created_at', descending: true)
            .get();

        recordings.value = query.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          if (data.containsKey('created_at')) {
            data['datetime'] =
                (data['created_at'] as Timestamp).toDate().toIso8601String();
          }
          return Recording.fromJson(data);
        }).toList();
      }
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
      final updateData = {
        'topic': topic,
        'file_link': fileLink,
        'transcript': transcript,
        'output': output,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (useSupabase) {
        try {
          // Update in Supabase
          final response = await supabase
              .from('recordings')
              .update(updateData)
              .eq('id', docId);
          print('Supabase update response: $response');
        } catch (e) {
          print('Supabase update error: $e');
          throw Exception('Failed to update in Supabase: $e');
        }
      } else {
        // Update in Firebase
        await firestore.collection('recordings').doc(docId).update({
          ...updateData,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

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
      
      if (useSupabase) {
        try {
          // First get the recording to get its file path
          final recording = await supabase
              .from('recordings')
              .select()
              .eq('id', docId)
              .single();
          
          // Delete file from storage
          if (recording != null) {
            try {
              final filePath = recording['file_link'] as String;
              final fileName = filePath.split('/').last;
              final userId = recording['user_id'] as String;
              await supabase
                  .storage
                  .from('recordings')
                  .remove(['$userId/$fileName']);
            } catch (e) {
              print('Error deleting file from storage: $e');
            }
          }

          // Delete from Supabase database
          final response = await supabase
              .from('recordings')
              .delete()
              .eq('id', docId);
          print('Supabase delete response: $response');
        } catch (e) {
          print('Supabase delete error: $e');
          throw Exception('Failed to delete from Supabase: $e');
        }
      } else {
        // Get the document first to get the file URL
        final doc = await firestore.collection('recordings').doc(docId).get();
        if (doc.exists) {
          try {
            final fileUrl = doc.data()?['file_link'] as String;
            final ref = storage.refFromURL(fileUrl);
            await ref.delete();
          } catch (e) {
            print('Error deleting file from storage: $e');
          }
        }

        // Delete from Firebase database
        await firestore.collection('recordings').doc(docId).delete();
      }

      await fetchUserRecordings();
      Get.snackbar("Success", "Recording deleted successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
