import 'package:flutter/material.dart';
import 'package:simple_chat_input/widgets/voice_recording_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Chat Input Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ChatExamplePage(),
    );
  }
}

class ChatExamplePage extends StatefulWidget {
  const ChatExamplePage({super.key});

  @override
  State<ChatExamplePage> createState() => _ChatExamplePageState();
}

class _ChatExamplePageState extends State<ChatExamplePage> {
  final List<ChatMessage> _messages = [];
  bool _isRecording = false;

  void _handleCancel() {
    setState(() {
      _isRecording = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recording cancelled'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handleSend(String? recordingPath, Duration? duration, int? fileSizeBytes) {
    setState(() {
      _isRecording = false;
    });
    
    if (recordingPath != null) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Voice message recorded',
          isVoice: true,
          timestamp: DateTime.now(),
          voicePath: recordingPath,
        ));
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voice sent: $recordingPath, duration: ${duration?.inMilliseconds ?? 0} ms, size: ${fileSizeBytes ?? 0} bytes'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleMicInUse() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Microphone is already in use by another app'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handlePlaybackError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playback error: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Chat Input Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
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
          
          // Voice recording widget or start button
          if (_isRecording)
            VoiceRecordingWidget(
              onCancel: _handleCancel,
              onSend: _handleSend,
              onIsMicUsed: _handleMicInUse,
              onPlayVoiceError: _handlePlaybackError,
              maxDuration: const Duration(minutes: 2), // 2 minutes max
              primaryColor: Colors.blue,
              canCelOrPauseColor: Colors.red,
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _startRecording,
                  icon: const Icon(Icons.mic),
                  label: const Text('Start Recording'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
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
              color: message.isVoice ? Colors.purple : Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.isVoice) ...[
                      const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      message.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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

class ChatMessage {
  final String text;
  final bool isVoice;
  final DateTime timestamp;
  final String? voicePath;

  ChatMessage({
    required this.text,
    required this.isVoice,
    required this.timestamp,
    this.voicePath,
  });
}
