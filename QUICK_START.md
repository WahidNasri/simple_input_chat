# Quick Start Guide

## Installation

1. Add to your `pubspec.yaml`:
```yaml
dependencies:
  simple_chat_input:
    path: ../path/to/simple_chat_input
```

2. Run `flutter pub get`

## Basic Usage

```dart
import 'package:simple_chat_input/simple_chat_input.dart';

VoiceRecordingWidget(
  onCancel: () => print('Cancelled'),
  onSend: (path) => print('Sent: $path'),
  onIsMicUsed: () => print('Mic in use'),
  maxDuration: Duration(minutes: 2),
)
```

## Platform Setup

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone to record voice messages</string>
```

## Run Example

```bash
cd example
flutter run
```

See README.md for complete documentation.
