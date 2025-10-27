import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecordingService {
  static final AudioRecordingService _instance = AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;
  AudioRecordingService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  Timer? _timer;
  StreamController<List<double>>? _waveformController;
  StreamController<Duration>? _durationController;
  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _recordingDuration = Duration.zero;

  // Getters
  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  Duration get recordingDuration => _recordingDuration;
  Stream<List<double>>? get waveformStream => _waveformController?.stream;
  Stream<Duration>? get durationStream => _durationController?.stream;

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } else if (Platform.isIOS) {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    }
    return false;
  }

  Future<bool> startRecording() async {
    if (_isRecording) return false;

    final hasPermission = await requestPermissions();
    if (!hasPermission) return false;

    try {
      final directory = await getApplicationDocumentsDirectory();
      _currentRecordingPath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      _isPaused = false;
      _recordingDuration = Duration.zero;

      _durationController = StreamController<Duration>.broadcast();
      _waveformController = StreamController<List<double>>.broadcast();

      _startTimer();
      _startWaveformSimulation();

      return true;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
    }
  }

  Future<void> pauseRecording() async {
    if (!_isRecording || _isPaused) return;

    try {
      await _recorder.pause();
      _isPaused = true;
      _timer?.cancel();
    } catch (e) {
      print('Error pausing recording: $e');
    }
  }

  Future<void> resumeRecording() async {
    if (!_isRecording || !_isPaused) return;

    try {
      await _recorder.resume();
      _isPaused = false;
      _startTimer();
    } catch (e) {
      print('Error resuming recording: $e');
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final path = await _recorder.stop();
      _isRecording = false;
      _isPaused = false;
      _timer?.cancel();
      _waveformController?.close();
      _durationController?.close();
      
      return path;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  Future<void> cancelRecording() async {
    if (!_isRecording) return;

    try {
      await _recorder.cancel();
      _isRecording = false;
      _isPaused = false;
      _timer?.cancel();
      _waveformController?.close();
      _durationController?.close();

      // Delete the recording file if it exists
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error canceling recording: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _recordingDuration = Duration(
        milliseconds: _recordingDuration.inMilliseconds + 100,
      );
      _durationController?.add(_recordingDuration);
    });
  }

  void _startWaveformSimulation() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }

      // Generate simulated waveform data
      final random = Random();
      final waveform = List.generate(20, (index) {
        return random.nextDouble() * 2 - 1; // Values between -1 and 1
      });
      
      _waveformController?.add(waveform);
    });
  }

  void dispose() {
    _timer?.cancel();
    _waveformController?.close();
    _durationController?.close();
    _recorder.dispose();
  }
}
