import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIApi {
  static Future<String> getAIMinutes(String transcript, String dirPath) async {
    const String apiKey = String.fromEnvironment('ai', defaultValue: 'AI_API_KEY');
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
        "You are a professional meeting minutes writer. You will be given a meeting microphone recording transcript with speaker tags and you will need to write a detailed meeting minute. it should contain attendence, summary, meeting minutes. Heres the recording transcript:$transcript";
    final content = Content.text(message);

    final response = await chat.sendMessage(content);
    try {
      File("$dirPath/output.md").writeAsStringSync(response.text ?? "No response text available");
    }
    catch (e) {
      print("Error processing file: $e");
      return "Error occurred";
    }
    print("AI RESPONSE: ${response.text}");
    return response.text!;
  }
}
