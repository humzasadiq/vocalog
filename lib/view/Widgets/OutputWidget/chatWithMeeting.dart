import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';

class ChatWithMeeting extends StatefulWidget {
  const ChatWithMeeting({
    super.key,
    required this.filePath,
    required this.calar,
    required this.transcript,
    required this.output,
  });

  final String filePath;
  final Color calar;
  final String transcript;
  final String output;

  @override
  State<ChatWithMeeting> createState() => _ChatWithMeetingState();
}

class _ChatWithMeetingState extends State<ChatWithMeeting> {
  final TextEditingController _textController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  late File _messagesFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messagesFile = File("${widget.filePath}/chat_messages.json");
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    await _loadMessages();

    setState(() {
      _isLoading = false;
    });
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
                        'isUser': true,
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
        maxOutputTokens: 2048,
        responseMimeType: 'text/plain',
      ),
    );

    String systemPrompt =
        "You are an assistant helping with questions about a meeting. Don't ever provide any information about the meeting that is not in the meeting transcript or meeting minutes. If the information isn't in the meeting content, please say so. Format your responses using Markdown for better readability.";

    if (widget.transcript.isNotEmpty) {
      systemPrompt +=
          "\n\nHere is the meeting transcript:\n\n${widget.transcript}\n\n";
    }

    if (widget.output.isNotEmpty) {
      systemPrompt +=
          "\n\nHere are the meeting minutes:\n\n${widget.output}\n\n";
    }

    systemPrompt +=
        "\nBased on this meeting information, please answer the following user question concisely and accurately. If the information isn't in the meeting content, please say so. Format your responses using Markdown for better readability.";

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Chat Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: [
                Icon(Icons.chat_outlined, color: widget.calar),
                SizedBox(width: 8),
                Text(
                  'Chat with Meeting',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Messages List
          Expanded(
            child: _isLoading && _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(widget.calar),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading chat history...',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assistant,
                              size: 48,
                              color: Colors.black26,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Start a conversation about the meeting',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _messages.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isUserMessage = message['isUser'] == true;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: isUserMessage
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isUserMessage) ...[
                                  CircleAvatar(
                                    backgroundColor:
                                        widget.calar.withOpacity(0.1),
                                    radius: 16,
                                    child: Image(
                                        width: 30,
                                        height: 30,
                                        image: AssetImage('assets/icon.png')),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isUserMessage
                                          ? widget.calar.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(
                                            isUserMessage ? 16 : 4),
                                        topRight: Radius.circular(
                                            isUserMessage ? 4 : 16),
                                        bottomLeft: const Radius.circular(16),
                                        bottomRight: const Radius.circular(16),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (!isUserMessage)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  'vocalog AI',
                                                  style: TextStyle(
                                                    color: widget.calar,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              ),
                                              IconButton(
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                      icon: Icon(
                                                        Icons.copy,
                                                        size: 18,
                                                        color: Colors.black38,
                                                      ),
                                                      onPressed: () {
                                                        Clipboard.setData(ClipboardData(
                                                          text: message['text'],
                                                        ));
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            backgroundColor: widget.calar,
                                                            content: const Text(
                                                              'Copied to clipboard',
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                            duration: const Duration(seconds: 2),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                            ],
                                          ),
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
                                                  p: const TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 14,
                                                  ),
                                                  h1: TextStyle(
                                                    color: widget.calar,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                  h2: TextStyle(
                                                    color: widget.calar,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                  h3: TextStyle(
                                                    color: widget.calar,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                  listBullet: const TextStyle(
                                                    color: Colors.black87,
                                                  ),
                                                  blockquote: const TextStyle(
                                                    color: Colors.black54,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  code: TextStyle(
                                                    color: widget.calar,
                                                    backgroundColor: Colors
                                                        .black
                                                        .withOpacity(0.05),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isUserMessage) ...[
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    backgroundColor:
                                        widget.calar.withOpacity(0.1),
                                    radius: 16,
                                    child: Icon(
                                      Icons.person,
                                      size: 18,
                                      color: widget.calar,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
          ),
          // Loading indicator
          if (_isLoading && _messages.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.black12),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(widget.calar),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "AI is thinking...",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          // Input field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.black87),
                    controller: _textController,
                    decoration: InputDecoration(
                      fillColor: Colors.grey.withOpacity(0.1),
                      filled: true,
                      hintText: 'Ask about your meeting...',
                      hintStyle: TextStyle(
                        color: Colors.black38,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: widget.calar,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => _handleSubmitted(_textController.text),
                    icon: const Icon(Icons.send_rounded),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
