import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart' show rootBundle;

class AIApi {
  static Future<String> getAIMinutes(String transcript, String dirPath) async {
    final String apiKey = dotenv.get('ai', fallback: '');
    // Load templates using rootBundle
    final String template = await rootBundle.loadString('assets/template/meeting.txt');
    // final String AIPrompt = await rootBundle.loadString('assets/template/message.txt');
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY environment variable not set');
    }
    final model = GenerativeModel(
      model: 'gemini-2.0-flash-thinking-exp-01-21',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 65536,
        responseMimeType: 'text/plain',
      ),
    );
    final chat = model.startChat(history: []);
    final message =
        "You are a professional meeting minutes writer. You will be given a meeting microphone recording transcript with speaker tags and you will need to write a detailed meeting minute. Whatever the language is written in the transcript, english or other or a mix of both you will always give response in english. Heres the template $template Heres the recording transcript:$transcript";
    // final message = AIPrompt;
    final content = Content.text(message);

    final response = await chat.sendMessage(content);
    try {
      File("$dirPath/output.md")
          .writeAsStringSync(response.text ?? "No response text available");
    } catch (e) {
      print("Error processing file: $e");
      return "Error occurred";
    }
    print("AI RESPONSE: ${response.text}");
    return response.text!;
  }
}
