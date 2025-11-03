import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mic_info/mic_info.dart';
import 'package:waved_audio_player/waved_audio_player.dart';
import '../services/audio_recording_service.dart';

class VoiceRecordingWidget extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(String? path, Duration? duration, int? fileSizeBytes) onSend;
  final Function(String)? onPlayVoiceError;
  final Function() onIsMicUsed;
  final Duration? maxDuration;
  final Color? primaryColor;
  final Color? canCelOrPauseColor;

  const VoiceRecordingWidget({
    super.key,
    required this.onCancel,
    required this.onSend,
    this.onPlayVoiceError,
    required this.onIsMicUsed,
    this.maxDuration = const Duration(minutes: 1),
    this.primaryColor,
    this.canCelOrPauseColor,
  });

  @override
  State<VoiceRecordingWidget> createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget> {
  final AudioRecordingService _audioService = AudioRecordingService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _playbackSubscription;
  Duration _recordingDuration = Duration.zero;
  List<double> _waveformData = [];
  String? _recordingPath;
  final GlobalKey _waveformKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _playbackSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (await _isMicUsed()) {
      widget.onIsMicUsed();
      return;
    }
    final success = await _audioService.startRecording();
    if (success) {
      _durationSubscription = _audioService.durationStream?.listen((duration) {
        setState(() {
          _recordingDuration = duration;
        });

        // Check if max duration is reached
        if (widget.maxDuration != null && duration >= widget.maxDuration!) {
          _handleStopRecording();
        }
      });

      _audioService.waveformStream?.listen((waveform) {
        if (!_audioService.isPaused) {
          setState(() {
            _waveformData = waveform;
          });
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  bool _isNearMaxDuration() {
    if (widget.maxDuration == null) {
      return false;
    }
    // Show warning when within 10 seconds of max duration
    final warningThreshold = widget.maxDuration! - const Duration(seconds: 10);
    return _recordingDuration >= warningThreshold;
  }

  @override
  Widget build(BuildContext context) {
    final isRecordingPaused =
        _audioService.isPaused || !_audioService.isRecording;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(
              alpha: 0.2,
            ), // Shadow color and opacity
            spreadRadius: 1, // How far the shadow spreads
            blurRadius: 7, // How blurry the shadow is
            offset: const Offset(1, 2), // Offset of the shadow (x, y)
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with timer and waveform
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isRecordingPaused)
                  // Waveform visualization with progress
                  Expanded(
                    child: SizedBox(
                      height: 30,
                      //width: 100,
                      child: Stack(
                        children: [
                          GestureDetector(
                            key: _waveformKey,
                            child: CustomPaint(
                              painter: WaveformPainter(
                                _waveformData,
                                color: Theme.of(context).primaryColor,
                              ),
                              size: Size.infinite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (isRecordingPaused && _recordingPath != null)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceDim,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: WavedAudioPlayer(
                      source: DeviceFileSource(_recordingPath! ,mimeType: "audio/mp3"),
                      iconColor: Theme.of(context).colorScheme.onPrimary,
                      iconBackgoundColor: Theme.of(context).primaryColor,
                      playedColor: Theme.of(context).primaryColor,
                      unplayedColor: Colors.grey,
                      waveHeight: 20,
                      //waveWidth: 100,
                      barWidth: 2,
                      buttonSize: 30,
                      onError: (error) {
                        widget.onPlayVoiceError?.call(error.message);
                      },
                    ),
                  ),

                const SizedBox(width: 12),

                // Timer
                if (!isRecordingPaused)
                  Text(
                    _formatDuration(_recordingDuration),
                    style: TextStyle(
                      color: _isNearMaxDuration()
                          ? Colors.orange
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(width: 8),
              ],
            ),
          ),
          // Control buttons
          Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel button
                GestureDetector(
                  onTap: widget.onCancel,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.canCelOrPauseColor ?? Theme.of(context).colorScheme.error,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.onError,
                      size: 20,
                    ),
                  ),
                ),
                if (!isRecordingPaused)
                  GestureDetector(
                    onTap: _handleStopRecording,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.canCelOrPauseColor ?? Theme.of(context).colorScheme.error,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.pause,
                        color: Theme.of(context).colorScheme.onError,
                        size: 28,
                      ),
                    ),
                  ),
              // Send button
                GestureDetector(
                  onTap: () async {
                    String? pathToSend = _recordingPath;
                    // Ensure recording is stopped to have a finalized file and duration
                    if (pathToSend == null && _audioService.isRecording) {
                      pathToSend = await _audioService.stopRecording();
                    }

                    Duration? durationToSend = _recordingDuration;
                    int? fileSizeBytes;
                    if (pathToSend != null) {
                      try {
                        final file = File(pathToSend);
                        if (await file.exists()) {
                          fileSizeBytes = await file.length();
                        }
                      } catch (_) {
                        fileSizeBytes = null;
                      }
                    }

                    widget.onSend(pathToSend, durationToSend, fileSizeBytes);
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.onPrimary,
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

  void _handleStopRecording() async {
    _recordingPath = await _audioService.stopRecording();
    setState(() {});
  }

  Future<bool> _isMicUsed() async {
    final activeMics = await MicInfo.getActiveMicrophones();
    return Platform.isIOS && activeMics.length > 1 ||
        Platform.isAndroid && activeMics.isNotEmpty;
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color? color;

  WaveformPainter(this.waveformData, {this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;

    if (waveformData.isEmpty) return;

    final paint = Paint()
      ..color = color ?? const Color(0xFF00C851)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / waveformData.length;

    for (int i = 0; i < waveformData.length; i++) {
      final barHeight = (waveformData[i].abs() * centerY * 0.8).clamp(
        2.0,
        centerY * 0.8,
      );
      final x = i * barWidth + barWidth / 2;

      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
