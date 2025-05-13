import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart' show rootBundle;

class AIApi {
  // Template for meeting minutes
  static const String MEETING_TEMPLATE = '''
You are a professional meeting minutes writer. You will be given a transcript of a meeting.

Your response must start with a clear topic as an H1 heading (# Topic). Extract the most relevant topic from the transcript.

Your task is to create detailed meeting minutes that include:
1. Meeting Overview
   - Date and Topic
   - Key Participants
   - Main Objectives

2. Discussion Points
   - Major topics discussed
   - Key decisions made
   - Important arguments or viewpoints presented

3. Action Items
   - Tasks assigned
   - Responsibilities
   - Deadlines if mentioned

4. Conclusions
   - Decisions finalized
   - Next steps
   - Follow-up items

Format the minutes in a professional style with:
- Clear headings and subheadings
- Bullet points for discussion items
- Numbered lists for action items
- Emphasis on key decisions

Here's the meeting transcript:
{TRANSCRIPT}

Remember to start with an H1 heading (# Topic) that clearly states the main topic of the meeting.
Please provide comprehensive meeting minutes in English, regardless of the language used in the transcript.
''';

  // Template for summary
  static const String SUMMARY_TEMPLATE = '''
You are a professional content summarizer. You will be given a transcript to summarize.

Your response must start with a clear topic as an H1 heading (# Topic). Extract the most relevant topic from the transcript.

Your task is to create a concise but comprehensive summary of the content. The summary should:
1. Highlight the main points and key takeaways
2. Be organized in a clear, easy-to-read format
3. Maintain the essential information while eliminating redundancy
4. Use bullet points where appropriate
5. Include a brief overview at the beginning

Here's the transcript to summarize:
{TRANSCRIPT}

Remember to start with an H1 heading (# Topic) that clearly states the main topic of the content.
Please provide a well-structured summary in English, regardless of the language used in the transcript.
''';

  // Template for class notes
  static const String CLASS_TEMPLATE = '''
You are a professional academic note-taker. You will be given a transcript of a class lecture or discussion.

Your response must start with a clear topic as an H1 heading (# Topic). Extract the most relevant topic/subject from the transcript.

Your task is to create well-structured class notes that:
1. Identify and explain the main concepts and theories discussed
2. Organize the content into clear sections with headings
3. Highlight important definitions, formulas, or key terms
4. Include any examples or case studies mentioned
5. Note any assignments, deadlines, or important announcements
6. Create a brief summary of learning objectives

Format the notes in a clear, academic style with:
- Main topics as headings
- Subtopics as subheadings
- Bullet points for key details
- Numbered lists for steps or sequences
- Emphasis on important terms or concepts

Here's the lecture transcript:
{TRANSCRIPT}

Remember to start with an H1 heading (# Topic) that clearly states the main topic/subject of the lecture.
Please provide comprehensive class notes in English, regardless of the language used in the transcript.
''';

  static Future<Map<String, String>> getAIMinutes(String transcript, String fileDir, String logType) async {
    try {
      final String apiKey = dotenv.get('ai', fallback: '');
      

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
      
      // Get the appropriate template based on log type
      String template = _getTemplate(logType);
      
      // Build the prompt with template
      String prompt = _buildPrompt(template, transcript, logType);

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      String result = response.text ?? "No response generated";
      
      // Extract topic from the response
      String topic = _extractTopic(result);
      
      // Save the response to a file
      await _saveResponse(result, fileDir);
      
      return {
        'response': result,
        'topic': topic,
      };
    } catch (e) {
      print('Error in getAIMinutes: $e');
      return {
        'response': 'Error generating response: $e',
        'topic': 'Unknown Topic',
      };
    }
  }

  static String _getTemplate(String logType) {
    switch (logType) {
      case 'Meeting Minutes':
        return MEETING_TEMPLATE;
      case 'Summary':
        return SUMMARY_TEMPLATE;
      case 'Class Notes':
        return CLASS_TEMPLATE;
      default:
        return MEETING_TEMPLATE;
    }
  }

  static String _buildPrompt(String template, String transcript, String logType) {
    return template.replaceAll('{TRANSCRIPT}', transcript.trim());
  }

  static String _extractTopic(String response) {
    try {
      // Look for H1 heading pattern: # Topic
      final RegExp h1Regex = RegExp(r'#\s*([^\n]+)');
      final match = h1Regex.firstMatch(response);
      if (match != null && match.group(1) != null) {
        // Clean up the topic by removing any remaining # and trimming whitespace
        return match.group(1)!.replaceAll('#', '').trim();
      }
      return 'Unknown Topic';
    } catch (e) {
      print('Error extracting topic: $e');
      return 'Unknown Topic';
    }
  }

  static Future<void> _saveResponse(String response, String fileDir) async {
    try {
      final file = File('$fileDir/ai_response.txt');
      await file.writeAsString(response);
    } catch (e) {
      print('Error saving response: $e');
    }
  }
}
