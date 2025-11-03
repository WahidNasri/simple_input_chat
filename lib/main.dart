import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:waved_audio_player/waved_audio_player.dart';
import 'widgets/simple_chat_input.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Input Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ChatDemoPage(),
    );
  }
}

class ChatDemoPage extends StatefulWidget {
  const ChatDemoPage({super.key});

  @override
  State<ChatDemoPage> createState() => _ChatDemoPageState();
}

class _ChatDemoPageState extends State<ChatDemoPage> {
  final List<ChatMessage> _messages = [];

  void _handleTextMessage(String message) {
    setState(() {
      _messages.add(
        ChatMessage(text: message, isText: true, timestamp: DateTime.now()),
      );
    });
  }

  void _handleVoiceMessage(String voicePath, Duration duration, int fileSizeBytes) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: 'Voice message recorded',
          isText: false,
          timestamp: DateTime.now(),
          voicePath: voicePath,
          duration: duration
        ),
      );
    });
  }

  void _handleEmojiPressed() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Emoji picker pressed')));
  }

  void _handleAttachmentPressed() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Attachment pressed')));
  }

  void _handleCameraPressed() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Camera pressed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Input Demo'), elevation: 0),
      body: SafeArea(
        child: Column(
          children: [
            // Chat messages area
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),

            // Chat input widget
            SimpleChatInput(
              onTextMessage: _handleTextMessage,
              onVoiceMessage: _handleVoiceMessage,
              onEmojiPressed: _handleEmojiPressed,
              onAttachmentPressed: _handleAttachmentPressed,
              onCameraPressed: _handleCameraPressed,
              onMicUsed: () {
                print(">>>>>>>>>>>>> Mic used");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF00C851),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.isText)
                  Text(
                    message.text,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  )
                else
                  WavedAudioPlayer(
                    source: DeviceFileSource(message.voicePath!,mimeType: "audio/mp3"),
                    iconColor: Theme.of(context).colorScheme.onPrimary,
                    iconBackgoundColor: Theme.of(context).primaryColor,
                    playedColor: Theme.of(context).primaryColor,
                    unplayedColor: Colors.grey,
                    waveHeight: 20,
                    //waveWidth: 100,
                    barWidth: 2,
                    buttonSize: 30,
                    onError: (error) {
                      print(error.message);
                    },
                  ),
                const SizedBox(height: 4),
                Text(
                  '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isText;
  final DateTime timestamp;
  final String? voicePath;
  final Duration? duration;

  ChatMessage({
    required this.text,
    required this.isText,
    required this.timestamp,
    this.voicePath,
    this.duration,
  });
}
