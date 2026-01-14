//
//  SettingsView.swift
//  Vinnies
//
//  Settings panel for configuring music library and preferences
//

import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @ObservedObject var libraryScanner: LibraryScanner

    @AppStorage("musicFolderPath") private var musicFolderPath: String = ""
    @AppStorage("bpmTolerance") private var bpmTolerance: Double = 3.0

    @State private var isAnalyzing = false
    @State private var analyzeProgress = 0
    @State private var analyzeTotal = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("SETTINGS")
                    .font(.retroHeader())
                    .foregroundColor(.retroCyan)

                Spacer()

                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.retroTextDim)
                }
                .buttonStyle(.plain)
            }

            RetroDivider()

            // Music folder selection
            VStack(alignment: .leading, spacing: 8) {
                Text("MUSIC FOLDER")
                    .font(.retro(9))
                    .foregroundColor(.retroText)

                HStack {
                    Text(musicFolderPath.isEmpty ? "Not selected" : shortenPath(musicFolderPath))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.retroTextDim)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()

                    Button("BROWSE") {
                        selectFolder()
                    }
                    .font(.retro(8))
                    .foregroundColor(.retroYellow)
                    .buttonStyle(.plain)
                }
                .retroCard(padding: 8)
            }

            // BPM tolerance slider
            VStack(alignment: .leading, spacing: 8) {
                Text("BPM TOLERANCE: ±\(Int(bpmTolerance))")
                    .font(.retro(9))
                    .foregroundColor(.retroText)

                Slider(value: $bpmTolerance, in: 1...10, step: 1)
                    .tint(.retroCyan)
            }

            // Library stats
            if !libraryScanner.tracks.isEmpty {
                HStack {
                    Text("LIBRARY:")
                        .font(.retro(9))
                        .foregroundColor(.retroTextDim)
                    Text("\(libraryScanner.tracks.count) tracks")
                        .font(.retro(9))
                        .foregroundColor(.retroText)

                    let analyzedCount = libraryScanner.tracks.filter { $0.bpm != nil }.count
                    Text("(\(analyzedCount) analyzed)")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.retroTextDim)
                }
            }

            // Scan & Analyze buttons
            VStack(spacing: 8) {
                if libraryScanner.isScanning {
                    VStack(spacing: 4) {
                        ProgressView(value: libraryScanner.progress)
                            .tint(.retroCyan)
                        Text("Scanning: \(libraryScanner.scannedCount)/\(libraryScanner.totalCount)")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.retroTextDim)
                    }
                } else if isAnalyzing {
                    VStack(spacing: 4) {
                        ProgressView(value: Double(analyzeProgress) / Double(max(1, analyzeTotal)))
                            .tint(.retroYellow)
                        Text("Analyzing BPM: \(analyzeProgress)/\(analyzeTotal)")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.retroTextDim)
                    }
                } else {
                    HStack(spacing: 12) {
                        Button("SCAN FOLDER") {
                            scanLibrary()
                        }
                        .retroButton(color: .retroCyan)
                        .disabled(musicFolderPath.isEmpty)

                        Button("ANALYZE BPM") {
                            analyzeLibrary()
                        }
                        .retroButton(color: .retroYellow)
                        .disabled(libraryScanner.tracks.isEmpty)
                    }
                }
            }

            // aubio status
            if !AudioAnalyzer.isAubioInstalled() {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.retroOrange)
                    Text("aubio not found. Run: brew install aubio")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.retroOrange)
                }
            }

            Spacer()
        }
        .padding(16)
        .frame(width: 360, height: 400)
        .background(Color.retroBackground)
    }

    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Select your music folder"

        if panel.runModal() == .OK, let url = panel.url {
            musicFolderPath = url.path
        }
    }

    private func scanLibrary() {
        guard !musicFolderPath.isEmpty else { return }
        let url = URL(fileURLWithPath: musicFolderPath)

        Task {
            await libraryScanner.scanFolder(url)
        }
    }

    private func analyzeLibrary() {
        let unanalyzed = libraryScanner.tracks.filter { $0.bpm == nil }
        guard !unanalyzed.isEmpty else { return }

        isAnalyzing = true
        analyzeTotal = unanalyzed.count
        analyzeProgress = 0

        Task {
            for (index, track) in unanalyzed.enumerated() {
                let analyzed = await AudioAnalyzer.analyzeTrack(track)

                await MainActor.run {
                    // Update the track in the library
                    if let idx = libraryScanner.tracks.firstIndex(where: { $0.path == track.path }) {
                        libraryScanner.tracks[idx] = analyzed
                    }
                    analyzeProgress = index + 1
                }
            }

            await MainActor.run {
                isAnalyzing = false
            }
        }
    }

    private func shortenPath(_ path: String) -> String {
        let components = path.split(separator: "/")
        if components.count > 3 {
            return ".../" + components.suffix(2).joined(separator: "/")
        }
        return path
    }
}
