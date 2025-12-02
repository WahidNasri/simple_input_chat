import 'package:flutter/material.dart';
import 'text_input_widget.dart';
import 'voice_recording_widget.dart';
import '../services/audio_recording_service.dart';

enum ChatInputState {
  textInput,
  voiceRecording,
}

class SimpleChatInput extends StatefulWidget {
  final Function(String)? onTextMessage;
  final Function(String path, Duration duration, int fileSizeBytes, List<double>? waveform)? onVoiceMessage;
  final VoidCallback? onEmojiPressed;
  final VoidCallback? onAttachmentPressed;
  final VoidCallback? onCameraPressed;
  final Duration? maxRecordingDuration;
  final Function() onMicUsed;
  final TextEditingController? controller;
  final Color? fillColor;
  final String? hint;
  final EdgeInsets? padding;
  final Color? primaryColor;
  final Color? canCelOrPauseColor;
  final bool enableVoiceRecording;

  const SimpleChatInput({
    super.key,
    this.onTextMessage,
    this.onVoiceMessage,
    this.onEmojiPressed,
    this.onAttachmentPressed,
    this.onCameraPressed,
    this.maxRecordingDuration,
    required this.onMicUsed,
    this.controller,
    this.fillColor,
    this.hint,
    this.padding,
    this.primaryColor,
    this.canCelOrPauseColor,
    this.enableVoiceRecording = true,
  });

  @override
  State<SimpleChatInput> createState() => _SimpleChatInputState();
}

class _SimpleChatInputState extends State<SimpleChatInput> {
  ChatInputState _currentState = ChatInputState.textInput;
  final AudioRecordingService _audioService = AudioRecordingService();

  @override
  void dispose() {
    // Only cleanup active recordings, don't dispose the singleton service
    _audioService.cleanup();
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

  void _handleVoiceSend(String? path, Duration? duration, int? fileSizeBytes, List<double>? waveform) async {
    final recordingPath = path ?? await _audioService.stopRecording();
    if (recordingPath != null && duration != null && fileSizeBytes != null) {
      widget.onVoiceMessage?.call(recordingPath, duration, fileSizeBytes, waveform);
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
    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice recording widget (full screen)
          if (_currentState == ChatInputState.voiceRecording)
            VoiceRecordingWidget(
              onCancel: _handleVoiceCancel,
              onSend: _handleVoiceSend,
              onIsMicUsed: (){
                widget.onMicUsed();
                _handleVoiceCancel();
              },
              maxDuration: widget.maxRecordingDuration,
              onPlayVoiceError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Playback error: $error')),
                );
              },
              canCelOrPauseColor: widget.canCelOrPauseColor,
              primaryColor: widget.primaryColor,
            ),

          // Text input widget
          if (_currentState == ChatInputState.textInput)
            TextInputWidget(
              key: ValueKey("ChatInputState.textInput"),
              controller: widget.controller,
              onSendPressed: _handleSendText,
              onVoicePressed: _handleVoicePressed,
              onAttachmentPressed: _handleAttachmentPressed,
              onCameraPressed: _handleCameraPressed,
              fillColor: widget.fillColor,
              hint: widget.hint,
              enableVoiceRecording: widget.enableVoiceRecording,
            ),
        ],
      ),
    );
  }
}
