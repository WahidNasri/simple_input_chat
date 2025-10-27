import 'package:flutter/material.dart';
import 'text_input_widget.dart';
import 'voice_recording_widget.dart';
import 'voice_recording_controls_widget.dart';
import 'voice_recording_lock_widget.dart';
import '../services/audio_recording_service.dart';

enum ChatInputState {
  textInput,
  voiceRecording,
  voiceRecordingControls,
  voiceRecordingLock,
}

class ChatInputWidget extends StatefulWidget {
  final Function(String)? onTextMessage;
  final Function(String)? onVoiceMessage;
  final VoidCallback? onEmojiPressed;
  final VoidCallback? onAttachmentPressed;
  final VoidCallback? onCameraPressed;

  const ChatInputWidget({
    super.key,
    this.onTextMessage,
    this.onVoiceMessage,
    this.onEmojiPressed,
    this.onAttachmentPressed,
    this.onCameraPressed,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  ChatInputState _currentState = ChatInputState.textInput;
  String _currentText = '';
  final AudioRecordingService _audioService = AudioRecordingService();

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  void _handleTextChanged(String text) {
    setState(() {
      _currentText = text;
    });
  }

  void _handleSendText() {
    if (_currentText.trim().isNotEmpty) {
      widget.onTextMessage?.call(_currentText.trim());
      setState(() {
        _currentText = '';
      });
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

  void _handleVoiceSend() async {
    final recordingPath = await _audioService.stopRecording();
    if (recordingPath != null) {
      widget.onVoiceMessage?.call(recordingPath);
    }
    setState(() {
      _currentState = ChatInputState.textInput;
    });
  }

  void _handleVoicePause() async {
    // The voice recording widget will handle the pause
  }

  void _handleVoiceResume() {
    // The voice recording widget will handle the resume
  }

  void _handleVoiceLock() {
    setState(() {
      _currentState = ChatInputState.voiceRecordingLock;
    });
  }

  void _handleVoiceUnlock() {
    setState(() {
      _currentState = ChatInputState.voiceRecordingControls;
    });
  }

  void _handleEmojiPressed() {
    widget.onEmojiPressed?.call();
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
            onPause: _handleVoicePause,
            onResume: _handleVoiceResume,
          ),

        // Voice recording lock widget
        if (_currentState == ChatInputState.voiceRecordingLock)
          VoiceRecordingLockWidget(
            onCancel: _handleVoiceCancel,
            onSend: _handleVoiceSend,
            onLock: _handleVoiceLock,
            onUnlock: _handleVoiceUnlock,
          ),

        // Voice recording controls (bottom bar)
        if (_currentState == ChatInputState.voiceRecordingControls)
          VoiceRecordingControlsWidget(
            onCancel: _handleVoiceCancel,
            onSend: _handleVoiceSend,
            onPause: _handleVoicePause,
            onResume: _handleVoiceResume,
          ),

        // Text input widget
        if (_currentState == ChatInputState.textInput)
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextInputWidget(
              initialText: _currentText,
              onTextChanged: _handleTextChanged,
              onSendPressed: _handleSendText,
              onVoicePressed: _handleVoicePressed,
              onEmojiPressed: _handleEmojiPressed,
              onAttachmentPressed: _handleAttachmentPressed,
              onCameraPressed: _handleCameraPressed,
            ),
          ),
      ],
    );
  }
}
