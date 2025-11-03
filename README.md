# Simple Chat Input Widget

A Flutter widget that provides a WhatsApp-like chat input experience with voice recording capabilities, including real-time waveform visualization and audio playback.

## Features

- 🎤 **Voice Recording**: Record audio messages with real-time waveform visualization
- 🎵 **Audio Playback**: Play recorded messages with seekable waveform controls
- ⏱️ **Duration Control**: Set maximum recording duration with visual warnings
- 🎨 **Customizable UI**: Theme-aware design with customizable colors
- 📱 **Cross-Platform**: Works on both Android and iOS
- 🔒 **Permission Handling**: Automatic microphone permission requests
- 🎯 **Mic Usage Detection**: Prevents recording when microphone is in use

## Installation

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Required dependencies
  permission_handler: ^12.0.1
  record: ^6.1.2
  path_provider: ^2.1.5
  audioplayers: ^6.5.1
  waved_audio_player: ^1.3.0
  mic_info: ^0.0.6
```

Run `flutter pub get` to install the dependencies.

## Platform Setup

### Android Setup

#### 1. Add Permissions to AndroidManifest.xml

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Microphone permission for recording -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    
    <!-- Storage permissions for saving recordings -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    
    <!-- Internet permission for audio playback -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <!-- Wake lock permission for continuous recording -->
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    
    <application
        android:label="simple_chat_input"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme" />
              
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

#### 2. Update build.gradle (if needed)

Ensure your `android/app/build.gradle` has the correct minSdkVersion:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21  // Required for permission_handler
        targetSdkVersion 34
    }
}
```

### iOS Setup

#### 1. Add Permissions to Info.plist

Add the following keys to `ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Microphone usage description -->
    <key>NSMicrophoneUsageDescription</key>
    <string>This app needs access to microphone to record voice messages</string>
    
    <!-- Camera usage description (if you plan to add camera features) -->
    <key>NSCameraUsageDescription</key>
    <string>This app needs access to camera to take photos</string>
    
    <!-- Photo library usage description (if you plan to add photo selection) -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app needs access to photo library to select images</string>
    
    <!-- Other existing keys... -->
</dict>
</plist>
```

#### 2. Update Podfile

Add the following to your `ios/Podfile`:

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'  # Minimum iOS version required

# Add this line to enable bitcode
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # Enable bitcode for all targets
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'YES'
      
      # Set minimum deployment target
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

#### 3. Run Pod Install

After updating the Podfile, run:

```bash
cd ios
pod install
cd ..
```

## Usage

### Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:simple_chat_input/widgets/voice_recording_widget.dart';

class MyChatPage extends StatefulWidget {
  @override
  _MyChatPageState createState() => _MyChatPageState();
}

class _MyChatPageState extends State<MyChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Your chat messages here
              ],
            ),
          ),
          
          // Voice Recording Widget
          VoiceRecordingWidget(
            onCancel: () {
              // Handle cancel action
              print('Recording cancelled');
            },
            onSend: (String? recordingPath, Duration? duration, int? fileSizeBytes) {
              // Handle send action with extra metadata
              if (recordingPath != null) {
                print('Voice message: path=$recordingPath, duration=${duration?.inMilliseconds}ms, size=${fileSizeBytes ?? 0} bytes');
                // Send the voice message
              }
            },
            onIsMicUsed: () {
              // Handle when microphone is already in use
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Microphone is already in use by another app'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            onPlayVoiceError: (String error) {
              // Handle audio playback errors
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Playback error: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### Advanced Configuration

```dart
VoiceRecordingWidget(
  onCancel: _handleCancel,
  onSend: _handleSend,
  onIsMicUsed: _handleMicInUse,
  onPlayVoiceError: _handlePlaybackError,
  
  // Optional parameters
  maxDuration: Duration(minutes: 2),  // Maximum recording duration
  primaryColor: Colors.blue,          // Custom primary color
  canCelOrPauseColor: Colors.red,     // Custom cancel/pause button color
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `onCancel` | `VoidCallback` | ✅ | Called when user cancels recording |
| `onSend` | `Function(String?)` | ✅ | Called when user sends recording (receives file path) |
| `onIsMicUsed` | `Function()` | ✅ | Called when microphone is already in use |
| `onPlayVoiceError` | `Function(String)?` | ❌ | Called when audio playback fails |
| `maxDuration` | `Duration?` | ❌ | Maximum recording duration (default: 1 minute) |
| `primaryColor` | `Color?` | ❌ | Custom primary color for UI elements |
| `canCelOrPauseColor` | `Color?` | ❌ | Custom color for cancel/pause buttons |

## Features Explained

### Voice Recording
- Real-time waveform visualization during recording
- Visual timer showing recording duration
- Automatic stop when maximum duration is reached
- Warning indicators when approaching time limit

### Audio Playback
- Play/pause controls for recorded audio
- Seekable waveform for navigation
- Visual progress indicators
- Error handling for playback issues

### Microphone Detection
- Automatically detects if microphone is in use
- Prevents recording conflicts with other apps
- Shows appropriate user feedback

### Customization
- Theme-aware design that adapts to your app's theme
- Customizable colors for different UI elements
- Flexible duration limits
- Responsive design for different screen sizes

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Ensure all required permissions are added to AndroidManifest.xml and Info.plist
   - Test on physical device (permissions don't work on simulators)

2. **Audio Playback Issues**
   - Check if the recorded file path is valid
   - Ensure the audio file format is supported (MP3, M4A, etc.)

3. **Microphone Detection Not Working**
   - Make sure `mic_info` package is properly installed
   - Test on physical device

4. **iOS Build Issues**
   - Run `pod install` after adding dependencies
   - Clean and rebuild the project
   - Check iOS deployment target (minimum 12.0)

### Debug Tips

- Enable debug logging to see detailed error messages
- Test on both Android and iOS devices
- Check device permissions in system settings
- Verify file paths are accessible

## Dependencies

This package depends on:
- `permission_handler`: For handling microphone permissions
- `record`: For audio recording functionality
- `path_provider`: For file system access
- `audioplayers`: For audio playback
- `waved_audio_player`: For waveform visualization
- `mic_info`: For microphone usage detection

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you encounter any issues or have questions, please open an issue on the GitHub repository.