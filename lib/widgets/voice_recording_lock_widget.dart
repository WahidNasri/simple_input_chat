import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_recording_service.dart';

class VoiceRecordingLockWidget extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onSend;
  final VoidCallback onLock;
  final VoidCallback onUnlock;

  const VoiceRecordingLockWidget({
    super.key,
    required this.onCancel,
    required this.onSend,
    required this.onLock,
    required this.onUnlock,
  });

  @override
  State<VoiceRecordingLockWidget> createState() => _VoiceRecordingLockWidgetState();
}

class _VoiceRecordingLockWidgetState extends State<VoiceRecordingLockWidget> {
  final AudioRecordingService _audioService = AudioRecordingService();
  StreamSubscription<Duration>? _durationSubscription;
  Duration _recordingDuration = Duration.zero;
  bool _isLocked = false;

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
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00C851),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header with timer and lock indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Timer
                Text(
                  _formatDuration(_recordingDuration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const Spacer(),
                
                // Lock indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isLocked ? const Color(0xFF00C851) : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _isLocked ? const Color(0xFF00C851) : const Color(0xFF9E9E9E),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isLocked ? Icons.lock : Icons.lock_open,
                        color: _isLocked ? Colors.white : const Color(0xFF9E9E9E),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isLocked ? 'Locked' : 'Unlocked',
                        style: TextStyle(
                          color: _isLocked ? Colors.white : const Color(0xFF9E9E9E),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Recording status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  _isLocked ? 'Recording (Locked)' : 'Recording...',
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Control buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel button
                GestureDetector(
                  onTap: widget.onCancel,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF424242),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                
                // Lock/Unlock button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLocked = !_isLocked;
                    });
                    if (_isLocked) {
                      widget.onLock();
                    } else {
                      widget.onUnlock();
                    }
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _isLocked ? const Color(0xFF00C851) : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isLocked ? Icons.lock : Icons.mic,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                
                // Send button
                GestureDetector(
                  onTap: widget.onSend,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C851),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 24,
                    ),
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
