# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter desktop application for managing stand-up meetings. It's a timer app that rotates through selected team members, giving each person a fixed countdown period (default 2 minutes). The app uses the Yaru theme for Ubuntu/Linux desktop integration.

## Key Architecture

- **Main App Structure**: Single-page Flutter app with two main views - setup/ready state and active timer state
- **State Management**: Uses basic Flutter StatefulWidget, no external state management
- **UI Components**: 
  - Left sidebar: Toggleable name selection buttons
  - Main area: Circular countdown timer with controls
  - Uses Yaru theme components for native Ubuntu look
- **Timer Logic**: Built around `circular_countdown_timer` package with custom controller
- **Name Management**: Names are shuffled on app startup, stored in `_allNames` list at top of main.dart

## Common Development Commands

```bash
# Run the app
flutter run -d linux

# Install dependencies
flutter pub get

# Run tests
flutter test

# Analyze code
flutter analyze

# Build for release
flutter build linux
```

## Key Configuration Points

- **Timer Duration**: Modify `_duration` variable in `_TimerPageState` (currently 120 seconds)
- **Default Names**: Edit `_allNames` list at top of main.dart:18-22
- **Window Size**: Set in main() function via `DesktopWindow.setWindowSize()`
- **Dependencies**: Key packages include yaru (Ubuntu theme), circular_countdown_timer, desktop_window, window_size

## Development Notes

- App is designed specifically for Linux desktop (Ubuntu/Yaru integration)
- Comic.dart contains XKCD integration (currently unused in main UI)
- Uses secure random for name shuffling
- Theme colors automatically adapt to system light/dark mode
- Window title bar uses YaruWindowTitleBar for native integration