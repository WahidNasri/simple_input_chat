# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Simple Chat Input Widget
- Voice recording with real-time waveform visualization
- Audio playback with seekable waveform controls
- Maximum duration control with visual warnings
- Microphone usage detection to prevent conflicts
- Theme-aware design with customizable colors
- Cross-platform support for Android and iOS
- Automatic permission handling
- Error handling for audio playback issues
- Comprehensive documentation and examples

### Features
- **VoiceRecordingWidget**: Main widget for voice recording functionality
- **TextInputWidget**: Text input with voice recording trigger
- **AudioRecordingService**: Service for handling audio recording operations
- **WaveformPainter**: Custom painter for real-time waveform visualization
- **Mic Usage Detection**: Prevents recording when microphone is in use
- **Duration Control**: Configurable maximum recording duration
- **Visual Feedback**: Progress indicators and warning colors
- **Customizable UI**: Theme-aware design with custom colors

### Dependencies
- `permission_handler: ^12.0.1` - For microphone permissions
- `record: ^6.1.2` - For audio recording
- `path_provider: ^2.1.5` - For file system access
- `audioplayers: ^6.5.1` - For audio playback
- `waved_audio_player: ^1.3.0` - For waveform visualization
- `mic_info: ^0.0.6` - For microphone usage detection

### Platform Support
- Android API 21+ (Android 5.0+)
- iOS 12.0+
- Flutter SDK 3.8.1+

### Documentation
- Comprehensive README with setup instructions
- Example app demonstrating usage
- Platform-specific configuration guides
- Troubleshooting section
- API documentation
