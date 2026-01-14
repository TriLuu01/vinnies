//
//  MatchingEngine.swift
//  Vinnies
//
//  Finds tracks that mix well with the currently playing song.
//

import Foundation

enum MatchType: String {
    case direct = ""
    case halfTime = "½×"
    case doubleTime = "2×"
}

struct MatchResult: Identifiable {
    var id: String { track.path }
    let track: Track
    let score: Double
    let matchType: MatchType
}

class MatchingEngine {

    /// Find tracks from library that match the current BPM and key
    static func findMatches(
        currentBPM: Double,
        currentCamelot: String?,
        library: [Track],
        bpmTolerance: Double = 3.0,
        limit: Int = 15
    ) -> [MatchResult] {

        var results: [MatchResult] = []

        for track in library {
            guard let trackBPM = track.bpm else { continue }

            var matchType: MatchType?
            var bpmScore: Double = 0

            // Direct match (within tolerance)
            if abs(trackBPM - currentBPM) <= bpmTolerance {
                matchType = .direct
                bpmScore = 1.0 - (abs(trackBPM - currentBPM) / bpmTolerance) * 0.3
            }
            // Half-time match (track is half the BPM)
            else if abs(trackBPM - currentBPM / 2) <= bpmTolerance / 2 {
                matchType = .halfTime
                bpmScore = 0.85
            }
            // Double-time match (track is double the BPM)
            else if abs(trackBPM - currentBPM * 2) <= bpmTolerance * 2 {
                matchType = .doubleTime
                bpmScore = 0.85
            }

            // Skip if no BPM match
            guard let type = matchType else { continue }

            // Key compatibility score
            var keyScore: Double = 0.5 // Default if no key info
            if let trackCamelot = track.camelot, let current = currentCamelot {
                keyScore = CamelotWheel.compatibility(current, trackCamelot)
            }

            // Energy score (placeholder - could use actual energy data)
            let energyScore: Double = 0.8

            // Weighted total score
            // BPM is most important for beatmatching
            // Key is important for harmonic mixing
            // Energy helps with flow
            let totalScore = (bpmScore * 0.5) + (keyScore * 0.4) + (energyScore * 0.1)

            results.append(MatchResult(
                track: track,
                score: totalScore,
                matchType: type
            ))
        }

        // Sort by score descending and limit results
        return Array(
            results
                .sorted { $0.score > $1.score }
                .prefix(limit)
        )
    }

    /// Check if two BPMs are compatible for mixing
    static func bpmCompatible(_ bpm1: Double, _ bpm2: Double, tolerance: Double = 3.0) -> (compatible: Bool, type: MatchType) {
        // Direct match
        if abs(bpm1 - bpm2) <= tolerance {
            return (true, .direct)
        }
        // Half-time
        if abs(bpm1 / 2 - bpm2) <= tolerance / 2 {
            return (true, .halfTime)
        }
        // Double-time
        if abs(bpm1 * 2 - bpm2) <= tolerance * 2 {
            return (true, .doubleTime)
        }
        return (false, .direct)
    }
}
