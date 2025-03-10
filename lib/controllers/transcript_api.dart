import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';
import 'ai_api.dart';
import 'dart:io';

class TranscriptApi {
  static const String apiKey = String.fromEnvironment('stt', defaultValue: 'eleven_api_key');

  static Future<String?> getTranscript(String filePath, String fileName) async {
    try {
      if (filePath.isEmpty) {
        print("File path is empty");
        return null;
      }

      var apiUrl = "https://api.elevenlabs.io/v1/speech-to-text";
      var request = http.MultipartRequest("POST", Uri.parse(apiUrl));
      request.headers['xi-api-key'] = apiKey;
      request.fields['model_id'] = 'scribe_v1';
      request.fields['diarize'] = 'true';
      request.fields['language_code'] = 'eng';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.fields['file'] = fileName;

      EasyLoading.show(status: 'Transcribing...');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        return _formatTranscript(jsonResponse);
      } else {
        print('Upload failed with status: $responseBody');
        return "Error processing file";
      }
    } catch (e) {
      EasyLoading.dismiss();
      print("Error processing file: $e");
      return "Error occurred";
    }
  }

  static String _formatTranscript(Map<String, dynamic> jsonResponse) {
    if (!jsonResponse.containsKey("words")) return "No words found";

    List<dynamic> words = jsonResponse["words"];
    String transcript = "";
    String? currentSpeaker;
    List<String> sentence = [];

    for (var word in words) {
      String speaker = word["speaker_id"] ?? "Unknown";
      String text = word["text"];

      if (currentSpeaker != speaker) {
        if (sentence.isNotEmpty) {
          transcript += "\n> $currentSpeaker: ${sentence.join("")}\n";
          sentence.clear();
        }
        currentSpeaker = speaker;
      }
      
      sentence.add(text);
    }

    if (sentence.isNotEmpty && currentSpeaker != null) {
      transcript += "\n> $currentSpeaker: ${sentence.join("")}\n";
    }

    return transcript.trim();
  }
}
