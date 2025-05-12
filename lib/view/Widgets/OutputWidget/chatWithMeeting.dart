import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';

class ChatWithMeeting extends StatefulWidget {
  const ChatWithMeeting(
      {super.key, required this.filePath, required this.calar});
  final String filePath;
  final Color calar;

  @override
  State<ChatWithMeeting> createState() => _ChatWithMeetingState();
}

class _ChatWithMeetingState extends State<ChatWithMeeting> {
  final TextEditingController _textController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  late String transcriptPath;
  late String meetingMinutesPath;
  late File _messagesFile;
  String? _transcriptContent;
  String? _meetingMinutesContent;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    transcriptPath = "${widget.filePath}/transcript.txt";
    meetingMinutesPath = "${widget.filePath}/output.md";
    _messagesFile = File("${widget.filePath}/chat_messages.json");
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    await _loadMessages();
    await _loadMeetingContent();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadMeetingContent() async {
    try {
      final transcriptFile = File(transcriptPath);
      final meetingMinutesFile = File(meetingMinutesPath);

      if (await transcriptFile.exists()) {
        _transcriptContent = await transcriptFile.readAsString();
      }

      if (await meetingMinutesFile.exists()) {
        _meetingMinutesContent = await meetingMinutesFile.readAsString();
      }
    } catch (e) {
      debugPrint('Error loading meeting content: $e');
    }
  }

  Future<void> _loadMessages() async {
    try {
      if (await _messagesFile.exists()) {
        final String contents = await _messagesFile.readAsString();
        final dynamic decodedData = jsonDecode(contents);

        if (decodedData is List) {
          setState(() {
            if (decodedData.isNotEmpty && decodedData[0] is String) {
              _messages = List<String>.from(decodedData)
                  .map((text) => {
                        'text': text,
                        'isUser':
                            true,
                        'timestamp': DateTime.now().toIso8601String(),
                      })
                  .toList();
            } else if (decodedData.isNotEmpty && decodedData[0] is Map) {
              _messages = List<Map<String, dynamic>>.from(decodedData);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
      _messages = [];
    }
  }

  Future<void> _saveMessages() async {
    try {
      await _messagesFile.writeAsString(jsonEncode(_messages));
    } catch (e) {
      debugPrint('Error saving messages: $e');
    }
  }

  Future<String> _getAIResponse(String userMessage) async {
    final String apiKey = dotenv.get('ai', fallback: '');
    if (apiKey.isEmpty) {
      return 'API key not configured. Please set the "ai" environment variable.';
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

    String systemPrompt =
        "You are an assistant helping with questions about a meeting. dont ever provide any information about the meeting that is not in the meeting transcript or meeting minutes. If the information isn't in the meeting content, please say so. Format your responses using Markdown for better readability. also dont use code blocks.";

    if (_transcriptContent != null && _transcriptContent!.isNotEmpty) {
      systemPrompt +=
          "Here is the meeting transcript:\n\n$_transcriptContent\n\n";
    }

    if (_meetingMinutesContent != null && _meetingMinutesContent!.isNotEmpty) {
      systemPrompt +=
          "Here are the meeting minutes:\n\n$_meetingMinutesContent\n\n";
    }

    if (_transcriptContent != null || _meetingMinutesContent != null) {
      systemPrompt +=
          "Based on this meeting information, please answer the following user question concisely and accurately. If the information isn't in the meeting content, please say so. Format your responses using Markdown for better readability.";
    } else {
      systemPrompt +=
          "I don't have the meeting transcript or minutes available. I'll do my best to answer based on general knowledge. Format your responses using Markdown for better readability.";
    }

    final List<Content> history = [];

    history.add(Content.text(systemPrompt));

    final recentMessages = _messages.length > 6
        ? _messages.sublist(_messages.length - 6)
        : _messages;
    for (var message in recentMessages) {
      history.add(Content.text(message['text']));
    }

    final chat = model.startChat(history: history);

    final content = Content.text(userMessage);

    try {
      final response = await chat.sendMessage(content);
      return response.text ?? "No response received.";
    } catch (e) {
      debugPrint('Error getting AI response: $e');
      return "Sorry, there was an error processing your request. Please try again.";
    }
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _isLoading = true;
    });
    _textController.clear();

    final response = await _getAIResponse(text);

    setState(() {
      _messages.add({
        'text': response,
        'isUser': false,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _isLoading = false;
    });

    await _saveMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: _isLoading && _messages.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(widget.calar),
                    ),
                  )
                : ListView.builder(
                    itemCount: _messages.length,
                    padding: const EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUserMessage = message['isUser'] == true;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: isUserMessage
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: isUserMessage
                                    ? widget.calar.withOpacity(0.2)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Stack(
                                children: [
                                  isUserMessage
                                      ? Text(
                                          message['text'],
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          ),
                                        )
                                      : MarkdownBody(
                                          data: message['text'],
                                          styleSheet: MarkdownStyleSheet(
                                            p: TextStyle(color: Colors.black87),
                                            h1: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                            h2: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                            h3: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                            listBullet: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          shrinkWrap: true,
                                        ),
                                ],
                              ),
                            ),
                            if (!isUserMessage)
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  Icons.copy,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                    text: message['text'],
                                  ));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      backgroundColor: widget.calar,
                                      content: const Text(
                                          style: TextStyle(color: Colors.white),
                                          'Copied to clipboard'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (_isLoading && _messages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(widget.calar),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Thinking...",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left:10,bottom: 30),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    controller: _textController,
                    decoration: InputDecoration(
                      fillColor: widget.calar.withOpacity(0.05),
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: widget.calar),
                      ),
                      hintText: 'Ask about your meeting...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => _handleSubmitted(_textController.text),
                  icon: const Icon(Icons.send),
                  color: widget.calar,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
