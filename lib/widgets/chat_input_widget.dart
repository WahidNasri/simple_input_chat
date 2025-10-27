import 'package:flutter/material.dart';
import 'text_input_widget.dart';
import 'voice_recording_widget.dart';
import '../services/audio_recording_service.dart';

enum ChatInputState {
  textInput,
  voiceRecording,
}

class ChatInputWidget extends StatefulWidget {
  final Function(String)? onTextMessage;
  final Function(String)? onVoiceMessage;
  final VoidCallback? onEmojiPressed;
  final VoidCallback? onAttachmentPressed;
  final VoidCallback? onCameraPressed;
  final Duration? maxRecordingDuration;
  final Function() onIsMicUsed;

  const ChatInputWidget({
    super.key,
    this.onTextMessage,
    this.onVoiceMessage,
    this.onEmojiPressed,
    this.onAttachmentPressed,
    this.onCameraPressed,
    this.maxRecordingDuration,
    required this.onIsMicUsed,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  ChatInputState _currentState = ChatInputState.textInput;
  final AudioRecordingService _audioService = AudioRecordingService();

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }


  void _handleSendText(String text) {
    if (text.trim().isNotEmpty) {
      widget.onTextMessage?.call(text);
    }
  }

  void _handleVoicePressed() {
    setState(() {
      _currentState = ChatInputState.voiceRecording;
    });
  }


  void _handleVoiceCancel() {
    setState(() {
      _currentState = ChatInputState.textInput;
    });
    _audioService.cancelRecording();
  }

  void _handleVoiceSend(String? path) async {
    final recordingPath = path ?? await _audioService.stopRecording();
    if (recordingPath != null) {
      widget.onVoiceMessage?.call(recordingPath);
    }
    setState(() {
      _currentState = ChatInputState.textInput;
    });
  }

  void _handleAttachmentPressed() {
    widget.onAttachmentPressed?.call();
  }

  void _handleCameraPressed() {
    widget.onCameraPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Voice recording widget (full screen)
        if (_currentState == ChatInputState.voiceRecording)
          VoiceRecordingWidget(
            onCancel: _handleVoiceCancel,
            onSend: _handleVoiceSend,
            onIsMicUsed: (){
              widget.onIsMicUsed();
              _handleVoiceCancel();
            },
            maxDuration: widget.maxRecordingDuration,
            onPlayVoiceError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Playback error: $error')),
              );
            },
          ),



        // Text input widget
        if (_currentState == ChatInputState.textInput)
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextInputWidget(
              onSendPressed: _handleSendText,
              onVoicePressed: _handleVoicePressed,
              onAttachmentPressed: _handleAttachmentPressed,
              onCameraPressed: _handleCameraPressed,
            ),
          ),
      ],
    );
  }
}
