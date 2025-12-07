# Voice Recorder

A cross-platform audio recording application built with Flutter.

## Overview

Voice Recorder is a modern, elegant audio recording app designed for both **mobile** (iOS/Android) and **desktop** (Linux, Windows, macOS) platforms. It provides a sleek, dark-themed interface for recording, saving, and managing audio files.

## Features

- **Record Audio**: One-tap recording with real-time duration display
- **Live Visualizer**: Glowing audio waveform that responds to microphone input
- **Manage Recordings**: View and manage all saved recordings in one place
- **Multi-format Support**: Save recordings in AAC, Opus, or WAV formats
- **Localization**: Full support for English, Uzbek, and Russian languages
- **Cross-Platform**: Responsive UI that adapts to mobile and desktop environments

## Tech Stack

- **Flutter** - UI framework
- **GetX** - State management, dependency injection, routing
- **record** - Audio recording package
- **window_manager** - Desktop window management
- **path_provider** - Local file system access

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on mobile
flutter run

# Run on desktop (Linux/Windows/macOS)
flutter run -d linux
```

## License

MIT License
