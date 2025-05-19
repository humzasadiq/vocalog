import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TranscriptApi {
  static final String apiKey = dotenv.get('stt', fallback: '');

  static Future<String?> getTranscript(String filePath, String fileName, String dirPath, String languageCode) async {
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
      if (languageCode != 'auto') {
        request.fields['language_code'] = languageCode;
      }
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.fields['file'] = fileName;

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();


      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        var formatted = _formatTranscript(jsonResponse);
        try {
          File("$dirPath/transcript.txt").writeAsStringSync(formatted);
        }
        catch (e) {
          print("Error processing file: $e");
          return "Error occurred";
        }
        return formatted;
      } else {
        print('Upload failed with status: $responseBody');
        return "Error processing file";
      }
    } catch (e) {
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
