//
//  PopoverView.swift
//  Vinnies
//
//  Main popover UI for the menu bar app
//

import SwiftUI

struct PopoverView: View {
    @StateObject private var libraryScanner = LibraryScanner()

    @State private var showSettings = false
    @State private var matches: [MatchResult] = []

    // Currently selected track (simulated "now playing")
    @State private var currentTrack: Track?
    @State private var currentBPM: Double?
    @State private var currentCamelot: String?

    @AppStorage("bpmTolerance") private var bpmTolerance: Double = 3.0

    var body: some View {
        ZStack {
            mainView
                .opacity(showSettings ? 0 : 1)

            if showSettings {
                SettingsView(
                    isPresented: $showSettings,
                    libraryScanner: libraryScanner
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showSettings)
    }

    private var mainView: some View {
        VStack(spacing: 12) {
            // Header
            headerView

            RetroDivider()

            // Now Playing
            NowPlayingView(
                title: currentTrack?.title,
                artist: currentTrack?.artist,
                bpm: currentBPM,
                camelot: currentCamelot
            )

            // Instructions or Matches
            if libraryScanner.tracks.isEmpty {
                emptyLibraryView
            } else if currentTrack == nil {
                selectTrackView
            } else {
                matchesView
            }

            Spacer()

            // Status bar
            statusBar
        }
        .padding(16)
        .frame(width: 360, height: 480)
        .background(Color.retroBackground)
    }

    private var headerView: some View {
        HStack {
            Text("VINNIE'S")
                .font(.retroHeader())
                .foregroundColor(.retroCyan)

            Spacer()

            Button(action: { showSettings = true }) {
                Image(systemName: "gear")
                    .foregroundColor(.retroTextDim)
            }
            .buttonStyle(.plain)
        }
    }

    private var emptyLibraryView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "music.note.list")
                .font(.system(size: 40))
                .foregroundColor(.retroBorder)

            Text("No tracks loaded")
                .font(.retro(10))
                .foregroundColor(.retroTextDim)

            Text("Open settings to scan\nyour music folder")
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.retroBorder)
                .multilineTextAlignment(.center)

            Button("OPEN SETTINGS") {
                showSettings = true
            }
            .retroButton(color: .retroCyan)
            .padding(.top, 8)

            Spacer()
        }
    }

    private var selectTrackView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SELECT A TRACK")
                .font(.retro(10))
                .foregroundColor(.retroCyan)

            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(libraryScanner.tracks.filter { $0.bpm != nil }) { track in
                        trackSelectRow(track)
                    }
                }
            }
        }
    }

    private func trackSelectRow(_ track: Track) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(track.title ?? "Unknown")
                    .font(.retro(9))
                    .foregroundColor(.retroText)
                    .lineLimit(1)

                if let artist = track.artist {
                    Text(artist)
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.retroTextDim)
                        .lineLimit(1)
                }
            }

            Spacer()

            if let bpm = track.bpm {
                Text("\(Int(bpm))")
                    .font(.retro(9))
                    .foregroundColor(.retroYellow)
            }
        }
        .padding(8)
        .background(Color.retroBackgroundLight)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.retroBorder, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            selectTrack(track)
        }
    }

    private var matchesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("MIX WITH")
                    .font(.retro(10))
                    .foregroundColor(.retroCyan)

                Spacer()

                Button(action: clearSelection) {
                    Text("CLEAR")
                        .font(.retro(8))
                        .foregroundColor(.retroTextDim)
                }
                .buttonStyle(.plain)
            }

            if matches.isEmpty {
                Text("No compatible tracks found")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.retroTextDim)
                    .padding(.top, 20)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(matches) { result in
                            TrackRow(result: result)
                        }
                    }
                }
            }
        }
    }

    private var statusBar: some View {
        HStack {
            Circle()
                .fill(libraryScanner.tracks.isEmpty ? Color.retroOrange : Color.retroGreen)
                .frame(width: 8, height: 8)

            let analyzedCount = libraryScanner.tracks.filter { $0.bpm != nil }.count
            Text("\(analyzedCount) tracks ready")
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.retroTextDim)

            Spacer()

            if let bpm = currentBPM {
                Text("BPM: \(Int(bpm))")
                    .font(.retro(9))
                    .foregroundColor(.retroYellow)
            }
        }
    }

    // MARK: - Actions

    private func selectTrack(_ track: Track) {
        currentTrack = track
        currentBPM = track.bpm
        currentCamelot = track.camelot
        updateMatches()
    }

    private func clearSelection() {
        currentTrack = nil
        currentBPM = nil
        currentCamelot = nil
        matches = []
    }

    private func updateMatches() {
        guard let bpm = currentBPM else {
            matches = []
            return
        }

        // Find matching tracks (excluding current track)
        let library = libraryScanner.tracks.filter { $0.path != currentTrack?.path }
        matches = MatchingEngine.findMatches(
            currentBPM: bpm,
            currentCamelot: currentCamelot,
            library: library,
            bpmTolerance: bpmTolerance
        )
    }
}

#Preview {
    PopoverView()
}
