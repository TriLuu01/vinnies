//
//  LibraryScanner.swift
//  Vinnies
//
//  Scans a folder for audio files and extracts metadata
//

import Foundation
import AVFoundation
import Combine

class LibraryScanner: ObservableObject {
    @Published var isScanning = false
    @Published var progress: Double = 0
    @Published var scannedCount = 0
    @Published var totalCount = 0
    @Published var tracks: [Track] = []

    private let supportedExtensions = ["mp3", "m4a", "flac", "wav", "aiff", "aac", "ogg"]

    /// Scan a folder for audio files
    func scanFolder(_ url: URL) async {
        await MainActor.run {
            isScanning = true
            progress = 0
            scannedCount = 0
            tracks = []
        }

        let files = findAudioFiles(in: url)

        await MainActor.run {
            totalCount = files.count
        }

        for (index, file) in files.enumerated() {
            if let track = await processFile(file) {
                await MainActor.run {
                    tracks.append(track)
                }
            }

            await MainActor.run {
                progress = Double(index + 1) / Double(files.count)
                scannedCount = index + 1
            }
        }

        await MainActor.run {
            isScanning = false
        }
    }

    /// Find all audio files in a directory recursively
    private func findAudioFiles(in directory: URL) -> [URL] {
        var audioFiles: [URL] = []
        let fileManager = FileManager.default

        guard let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return [] }

        for case let fileURL as URL in enumerator {
            if supportedExtensions.contains(fileURL.pathExtension.lowercased()) {
                audioFiles.append(fileURL)
            }
        }

        return audioFiles
    }

    /// Process a single audio file and extract metadata
    private func processFile(_ url: URL) async -> Track? {
        let asset = AVURLAsset(url: url)

        var title: String?
        var artist: String?

        // Extract metadata from file
        do {
            let metadata = try await asset.load(.commonMetadata)

            for item in metadata {
                if let key = item.commonKey {
                    switch key {
                    case .commonKeyTitle:
                        title = try? await item.load(.stringValue)
                    case .commonKeyArtist:
                        artist = try? await item.load(.stringValue)
                    default:
                        break
                    }
                }
            }
        } catch {
            // Metadata extraction failed, continue with filename
        }

        // Fallback to filename if no title found
        if title == nil || title?.isEmpty == true {
            title = url.deletingPathExtension().lastPathComponent
        }

        return Track(
            path: url.path,
            title: title,
            artist: artist,
            bpm: nil,
            key: nil,
            mode: nil,
            camelot: nil,
            energy: nil,
            lastAnalyzed: nil
        )
    }

    /// Save tracks to a JSON file for persistence
    func saveTracks(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(tracks)
        try data.write(to: url)
    }

    /// Load tracks from a JSON file
    func loadTracks(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        tracks = try decoder.decode([Track].self, from: data)
    }
}
