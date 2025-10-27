import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/audio_recording_service.dart';

class VoiceRecordingWidget extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onSend;
  final VoidCallback onPause;
  final VoidCallback onResume;

  const VoiceRecordingWidget({
    super.key,
    required this.onCancel,
    required this.onSend,
    required this.onPause,
    required this.onResume,
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
  Duration _playbackPosition = Duration.zero;
  List<double> _waveformData = [];
  bool _isPlaying = false;
  String? _recordingPath;
  Offset? _tapPosition;
  bool _showTapFeedback = false;
  bool _isDragging = false;
  Duration _dragPosition = Duration.zero;
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
    final success = await _audioService.startRecording();
    if (success) {
      _durationSubscription = _audioService.durationStream?.listen((duration) {
        setState(() {
          _recordingDuration = duration;
        });
      });

      _audioService.waveformStream?.listen((waveform) {
        if(!_audioService.isPaused) {
          setState(() {
          _waveformData = waveform;
        });
        }
      });
    }
  }


  Future<void> _playPause() async {
    if (_isPlaying) {
      await _resetPlayer();
    } else {
      if (_recordingPath == null) {
        // First time playing, need to stop recording and get the file
        _recordingPath = await _audioService.stopRecording();
        if (_recordingPath != null) {
          await _audioPlayer.setSourceDeviceFile(_recordingPath!);
        }
      } else {
        // Reset player state for replay
        await _audioPlayer.stop();
        await _audioPlayer.setSourceDeviceFile(_recordingPath!);
      }
      
      // Set up listeners before starting
      _playbackSubscription?.cancel();
      _playbackSubscription = _audioPlayer.onPositionChanged.listen((position) {
        if (!_isDragging) {
          setState(() {
            _playbackPosition = position;
          });
        }
      });
      
      // Listen for playback completion
      _audioPlayer.onPlayerComplete.listen((event) {
        _resetPlayer();
      });
      
      // Start playing
      try {
        await _audioPlayer.resume();
        setState(() {
          _isPlaying = true;
        });
      } catch (e) {
        print('Error starting playback: $e');
        // If resume fails, try starting from the beginning
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.resume();
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  void _onWaveformTap(TapDownDetails details) async {
    if (_recordingDuration.inMilliseconds == 0) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    // Get the actual waveform area bounds
    final waveformArea = _getWaveformArea();
    if (waveformArea == null) return;
    
    // Calculate the tap position relative to the actual waveform area
    final tapX = localPosition.dx - waveformArea.left;
    final progress = (tapX / waveformArea.width).clamp(0.0, 1.0);
    
    // Calculate the target position in milliseconds
    final targetPosition = Duration(
      milliseconds: (progress * _recordingDuration.inMilliseconds).round(),
    );
    
    // Show tap feedback
    setState(() {
      _tapPosition = localPosition;
      _showTapFeedback = true;
    });
    
    // Hide tap feedback after animation
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _showTapFeedback = false;
        });
      }
    });
    
    // Seek to the target position
    await _audioPlayer.seek(targetPosition);
    setState(() {
      _playbackPosition = targetPosition;
    });
  }

  void _onDragStart(DragStartDetails details) {
    if (_recordingDuration.inMilliseconds == 0) return;
    
    setState(() {
      _isDragging = true;
      _dragPosition = _playbackPosition;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_recordingDuration.inMilliseconds == 0) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    // Get the actual waveform area bounds
    final waveformArea = _getWaveformArea();
    if (waveformArea == null) return;
    
    // Calculate the drag position relative to the actual waveform area
    final dragX = localPosition.dx - waveformArea.left;
    final progress = (dragX / waveformArea.width).clamp(0.0, 1.0);
    
    // Calculate the target position in milliseconds
    final targetPosition = Duration(
      milliseconds: (progress * _recordingDuration.inMilliseconds).round(),
    );
    
    setState(() {
      _dragPosition = targetPosition;
    });
  }

  Rect? _getWaveformArea() {
    final RenderBox? waveformBox = _waveformKey.currentContext?.findRenderObject() as RenderBox?;
    if (waveformBox == null) return null;
    
    // Get the exact bounds of the waveform widget
    final waveformSize = waveformBox.size;
    
    return Rect.fromLTWH(
      0,
      0,
      waveformSize.width,
      waveformSize.height,
    );
  }

  void _onDragEnd(DragEndDetails details) async {
    if (_recordingDuration.inMilliseconds == 0) return;
    
    // Seek to the final drag position
    await _audioPlayer.seek(_dragPosition);
    
    setState(() {
      _isDragging = false;
      _playbackPosition = _dragPosition;
    });
  }

  Future<void> _resetPlayer() async {
    await _audioPlayer.stop();
    if (_recordingPath != null) {
      await _audioPlayer.setSourceDeviceFile(_recordingPath!);
    }
    setState(() {
      _isPlaying = false;
      _playbackPosition = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isRecordingPaused = _audioService.isPaused || !_audioService.isRecording;

    return Container(
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
          // Header with timer and waveform
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Play button (only shown when paused)
                if (isRecordingPaused)
                  GestureDetector(
                    onTap: _playPause,
                    child: Container(
                      width: 40,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF424242),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                
                if (isRecordingPaused) const SizedBox(width: 12),
                
                // Waveform visualization with progress
                Expanded(
                  child: SizedBox(
                    height: 30,
                    child: Stack(
                      children: [
                        GestureDetector(
                          key: _waveformKey,
                          onTapDown: isRecordingPaused ? _onWaveformTap : null,
                          onPanStart: isRecordingPaused ? _onDragStart : null,
                          onPanUpdate: isRecordingPaused ? _onDragUpdate : null,
                          onPanEnd: isRecordingPaused ? _onDragEnd : null,
                          child: CustomPaint(
                            painter: WaveformPainter(
                              _waveformData, 
                              isRecordingPaused: isRecordingPaused,
                              playbackPosition: _isDragging ? _dragPosition : _playbackPosition,
                              totalDuration: _recordingDuration,
                              tapPosition: _tapPosition,
                              showTapFeedback: _showTapFeedback,
                              isDragging: _isDragging,
                            ),
                            size: Size.infinite,
                          ),
                        ),
                        // Seekable indicator
                        if (isRecordingPaused)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C851).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _isDragging ? 'Dragging...' : 'Drag to seek',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Timer
                Text(
                  _formatDuration(isRecordingPaused ? _playbackPosition : _recordingDuration),
                  style: const TextStyle(
                    color: Colors.white,
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
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                // Pause/Resume/Play button
                if(!isRecordingPaused)
                  GestureDetector(
                    onTap: () async {
                      await _audioService.pauseRecording();
                      setState(() {});
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pause,
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

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final bool isRecordingPaused;
  final Duration playbackPosition;
  final Duration totalDuration;
  final Offset? tapPosition;
  final bool showTapFeedback;
  final bool isDragging;

  WaveformPainter(
    this.waveformData, {
    this.isRecordingPaused = false,
    required this.playbackPosition,
    required this.totalDuration,
    this.tapPosition,
    this.showTapFeedback = false,
    this.isDragging = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    
    if (isRecordingPaused) {
      // Draw dotted timeline
      final dottedPaint = Paint()
        ..color = const Color(0xFF9E9E9E)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      
      final dashWidth = 4.0;
      final dashSpace = 4.0;
      double startX = 0;
      
      while (startX < size.width) {
        canvas.drawLine(
          Offset(startX, centerY),
          Offset(startX + dashWidth, centerY),
          dottedPaint,
        );
        startX += dashWidth + dashSpace;
      }
    }
    
    if (waveformData.isEmpty) return;

    final paint = Paint()
      ..color = isRecordingPaused ? const Color(0xFF9E9E9E) : const Color(0xFF00C851)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / waveformData.length;

    for (int i = 0; i < waveformData.length; i++) {
      final barHeight = (waveformData[i].abs() * centerY * 0.8).clamp(2.0, centerY * 0.8);
      final x = i * barWidth + barWidth / 2;
      
      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        paint,
      );
    }
    
    // Draw progress indicator when paused
    if (isRecordingPaused && totalDuration.inMilliseconds > 0) {
      final progressX = (playbackPosition.inMilliseconds / totalDuration.inMilliseconds) * size.width;
      
      // Draw progress line
      final progressLinePaint = Paint()
        ..color = isDragging ? const Color(0xFF00C851).withOpacity(0.7) : const Color(0xFF00C851)
        ..strokeWidth = isDragging ? 3.0 : 2.0
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(
        Offset(0, centerY),
        Offset(progressX, centerY),
        progressLinePaint,
      );
      
      // Draw progress circle
      final progressPaint = Paint()
        ..color = isDragging ? const Color(0xFF00C851).withOpacity(0.8) : const Color(0xFF00C851)
        ..style = PaintingStyle.fill;
      
      final circleRadius = isDragging ? 8.0 : 6.0;
      canvas.drawCircle(
        Offset(progressX, centerY),
        circleRadius,
        progressPaint,
      );
      
      // Draw inner circle for better visibility
      final innerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(progressX, centerY),
        isDragging ? 4.0 : 3.0,
        innerPaint,
      );
      
      // Draw dragging indicator
      if (isDragging) {
        final draggingPaint = Paint()
          ..color = const Color(0xFF00C851).withOpacity(0.3)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(
          Offset(progressX, centerY),
          circleRadius + 4,
          draggingPaint,
        );
      }
    }
    
    // Draw tap feedback ripple effect
    if (showTapFeedback && tapPosition != null) {
      final ripplePaint = Paint()
        ..color = const Color(0xFF00C851).withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      // Draw expanding circle
      canvas.drawCircle(
        tapPosition!,
        15.0,
        ripplePaint,
      );
      
      // Draw inner circle
      final innerRipplePaint = Paint()
        ..color = const Color(0xFF00C851).withOpacity(0.6)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        tapPosition!,
        8.0,
        innerRipplePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

