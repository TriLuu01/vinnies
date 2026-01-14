//
//  AudioAnalyzer.swift
//  Vinnies
//
//  Analyzes audio files for BPM using aubiotrack CLI
//

import Foundation

class AudioAnalyzer {

    /// Paths to aubiotrack binary (installed via Homebrew)
    private static let aubiotrackPaths = [
        "/opt/homebrew/bin/aubiotrack",      // Apple Silicon
        "/usr/local/bin/aubiotrack",          // Intel Mac
        "/opt/homebrew/Cellar/aubio/0.4.9_4/bin/aubiotrack"  // Direct path
    ]

    /// Find the aubiotrack binary
    private static func findAubiotrack() -> String? {
        for path in aubiotrackPaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        return nil
    }

    /// Analyze BPM of an audio file using aubiotrack
    /// aubiotrack outputs beat timestamps - we calculate BPM from the intervals
    static func analyzeBPM(filePath: String) async -> Double? {
        guard let aubioPath = findAubiotrack() else {
            print("aubiotrack not found. Install with: brew install aubio")
            return nil
        }

        return await withCheckedContinuation { continuation in
            let process = Process()
            let pipe = Pipe()
            let errorPipe = Pipe()

            process.executableURL = URL(fileURLWithPath: aubioPath)
            process.arguments = ["-i", filePath]
            process.standardOutput = pipe
            process.standardError = errorPipe

            do {
                try process.run()
                process.waitUntilExit()

                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8) {
                    // aubiotrack outputs beat timestamps (one per line)
                    // Calculate BPM from the time intervals between beats
                    let timestamps = output
                        .split(separator: "\n")
                        .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
                        .filter { $0 > 0 }

                    if timestamps.count >= 2 {
                        // Calculate intervals between consecutive beats
                        var intervals: [Double] = []
                        for i in 1..<timestamps.count {
                            let interval = timestamps[i] - timestamps[i-1]
                            if interval > 0.1 && interval < 2.0 { // Reasonable beat interval
                                intervals.append(interval)
                            }
                        }

                        if !intervals.isEmpty {
                            // Average interval in seconds
                            let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
                            // Convert to BPM (beats per minute)
                            let bpm = 60.0 / avgInterval

                            // Sanity check: BPM should be between 60 and 200 for most music
                            // If outside range, try doubling or halving
                            var finalBPM = bpm
                            if bpm < 60 {
                                finalBPM = bpm * 2
                            } else if bpm > 200 {
                                finalBPM = bpm / 2
                            }

                            continuation.resume(returning: finalBPM)
                            return
                        }
                    }
                }
                continuation.resume(returning: nil)
            } catch {
                print("BPM analysis failed for \(filePath): \(error)")
                continuation.resume(returning: nil)
            }
        }
    }

    /// Analyze a track and return an updated version with BPM
    static func analyzeTrack(_ track: Track) async -> Track {
        var updatedTrack = track

        if let bpm = await analyzeBPM(filePath: track.path) {
            updatedTrack.bpm = bpm
        }

        updatedTrack.lastAnalyzed = Date()

        return updatedTrack
    }

    /// Analyze multiple tracks with progress callback
    static func analyzeTracks(
        _ tracks: [Track],
        onProgress: @escaping (Int, Int, Track) -> Void
    ) async -> [Track] {
        var analyzedTracks: [Track] = []
        let total = tracks.count

        for (index, track) in tracks.enumerated() {
            let analyzed = await analyzeTrack(track)
            analyzedTracks.append(analyzed)
            onProgress(index + 1, total, analyzed)
        }

        return analyzedTracks
    }

    /// Check if aubio is installed
    static func isAubioInstalled() -> Bool {
        return findAubiotrack() != nil
    }
}
