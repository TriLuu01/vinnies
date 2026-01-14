# Vinnie's 🎵

A macOS menu bar app that helps DJs find tracks that mix well together. Select a track from your library and Vinnie's suggests compatible songs based on BPM matching.

![macOS](https://img.shields.io/badge/macOS-12.3+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- **Menu Bar App** - Lives in your menu bar, always one click away
- **Library Scanner** - Scans your music folder for audio files (MP3, FLAC, M4A, WAV, AAC, AIFF)
- **BPM Detection** - Analyzes tempo using aubiotrack
- **Smart Matching** - Finds compatible tracks including:
  - Direct BPM matches (±3 BPM tolerance)
  - Half-time matches (½×)
  - Double-time matches (2×)
- **Camelot Wheel** - Key compatibility scoring for harmonic mixing
- **Retro Aesthetic** - PS1/Mega Man X4 inspired dark theme

## Screenshots

```
╔══════════════════════════════════════╗
║  VINNIE'S                        ⚙  ║
╠══════════════════════════════════════╣
║  NOW PLAYING                        ║
║  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ║
║  ┃  Get Lucky                     ┃ ║
║  ┃  Daft Punk                     ┃ ║
║  ┃  BPM: 116    KEY: 4A           ┃ ║
║  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ║
║                                      ║
║  MIX WITH                           ║
║  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ║
║  ┃  Around The World    ½×  58 4A ┃ ║
║  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ║
╚══════════════════════════════════════╝
```

## Requirements

- macOS 12.3 (Monterey) or later
- Xcode 15+
- [aubio](https://aubio.org/) for BPM detection

## Installation

### 1. Install aubio

```bash
brew install aubio
```

### 2. Clone and build

```bash
git clone https://github.com/TriLuu01/vinnies.git
cd vinnies
open Vinnies.xcodeproj
```

### 3. Build and run

- Open in Xcode
- Select your signing team
- Build and run (⌘R)
- **Note:** Disable App Sandbox in Signing & Capabilities for aubio access

## Usage

1. Click the **music note** icon in your menu bar
2. Click the **gear icon** to open Settings
3. **Browse** to select your music folder
4. Click **SCAN FOLDER** to find audio files
5. Click **ANALYZE BPM** to detect tempo (requires aubio)
6. Close settings and **select a track** to see matching recommendations
7. Click any recommendation to **reveal in Finder**

## Project Structure

```
Vinnies/
├── AppDelegate.swift          # Menu bar setup
├── VinniesApp.swift           # App entry point
├── Models/
│   ├── Track.swift            # Audio file model
│   └── CamelotWheel.swift     # Key compatibility
├── Services/
│   ├── LibraryScanner.swift   # Audio file discovery
│   ├── AudioAnalyzer.swift    # BPM detection
│   └── MatchingEngine.swift   # Track matching
└── Views/
    ├── PopoverView.swift      # Main UI
    ├── NowPlayingView.swift   # Current track display
    ├── TrackRow.swift         # Track list item
    ├── SettingsView.swift     # Settings panel
    └── RetroComponents/
        ├── RetroStyles.swift  # Colors & fonts
        └── EnergyBar.swift    # Visual components
```

## Tech Stack

- **SwiftUI** - User interface
- **aubiotrack** - Beat detection CLI
- **AVFoundation** - Audio metadata extraction

## Future Improvements

- [ ] Key detection integration
- [ ] Persist library to disk
- [ ] System audio capture (auto-detect playing song)
- [ ] Manual BPM override
- [ ] Export playlist functionality

## License

MIT License - feel free to use and modify.

## Acknowledgments

- Built with [Claude Code](https://claude.ai/code)
- Beat detection by [aubio](https://aubio.org/)
- Inspired by rekordbox and Mixed In Key
