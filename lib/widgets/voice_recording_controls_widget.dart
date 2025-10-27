import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_recording_service.dart';

class VoiceRecordingControlsWidget extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onSend;
  final VoidCallback onPause;
  final VoidCallback onResume;

  const VoiceRecordingControlsWidget({
    super.key,
    required this.onCancel,
    required this.onSend,
    required this.onPause,
    required this.onResume,
  });

  @override
  State<VoiceRecordingControlsWidget> createState() => _VoiceRecordingControlsWidgetState();
}

class _VoiceRecordingControlsWidgetState extends State<VoiceRecordingControlsWidget> {
  final AudioRecordingService _audioService = AudioRecordingService();
  StreamSubscription<Duration>? _durationSubscription;
  Duration _recordingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _durationSubscription = _audioService.durationStream?.listen((duration) {
      setState(() {
        _recordingDuration = duration;
      });
    });
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // Recording indicator and timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_recordingDuration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Slide to cancel text
          Expanded(
            child: Center(
              child: Text(
                '< Slide to cancel',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          
          // Send button
          GestureDetector(
            onTap: widget.onSend,
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF00C851),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
