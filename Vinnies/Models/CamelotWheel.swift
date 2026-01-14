//
//  CamelotWheel.swift
//  Vinnies
//
//  The Camelot Wheel is a tool for harmonic mixing.
//  It maps musical keys to a numbered wheel (1-12) with A (minor) and B (major).
//

import Foundation

struct CamelotWheel {
    // Mapping from (key, mode) to Camelot notation
    // Key: 0=C, 1=C#, 2=D, ..., 11=B
    // Mode: 0=minor, 1=major

    private static let majorToCamelot: [Int: String] = [
        0: "8B",   // C major
        1: "3B",   // C#/Db major
        2: "10B",  // D major
        3: "5B",   // D#/Eb major
        4: "12B",  // E major
        5: "7B",   // F major
        6: "2B",   // F#/Gb major
        7: "9B",   // G major
        8: "4B",   // G#/Ab major
        9: "11B",  // A major
        10: "6B",  // A#/Bb major
        11: "1B"   // B major
    ]

    private static let minorToCamelot: [Int: String] = [
        0: "5A",   // C minor
        1: "12A",  // C# minor
        2: "7A",   // D minor
        3: "2A",   // D#/Eb minor
        4: "9A",   // E minor
        5: "4A",   // F minor
        6: "11A",  // F# minor
        7: "6A",   // G minor
        8: "1A",   // G#/Ab minor
        9: "8A",   // A minor
        10: "3A",  // A#/Bb minor
        11: "10A"  // B minor
    ]

    /// Convert Spotify key/mode to Camelot notation
    static func toCamelot(key: Int, mode: Int) -> String {
        if mode == 1 {
            return majorToCamelot[key] ?? "1A"
        } else {
            return minorToCamelot[key] ?? "1A"
        }
    }

    /// Parse Camelot string into number and letter
    static func parse(_ camelot: String) -> (number: Int, letter: Character)? {
        guard camelot.count >= 2 else { return nil }
        let letter = camelot.last!
        let numberStr = String(camelot.dropLast())
        guard let number = Int(numberStr), number >= 1, number <= 12 else { return nil }
        guard letter == "A" || letter == "B" else { return nil }
        return (number, letter)
    }

    /// Calculate compatibility between two Camelot keys (0.0 to 1.0)
    /// Perfect mixing moves:
    /// - Same key (7A → 7A): 1.0
    /// - Adjacent (7A → 6A or 8A): 0.9
    /// - Relative major/minor (7A → 7B): 0.85
    static func compatibility(_ a: String, _ b: String) -> Double {
        guard let parsedA = parse(a), let parsedB = parse(b) else { return 0 }

        let numA = parsedA.number
        let numB = parsedB.number
        let letterA = parsedA.letter
        let letterB = parsedB.letter

        // Same key - perfect match
        if numA == numB && letterA == letterB {
            return 1.0
        }

        // Relative major/minor (same number, different letter)
        if numA == numB && letterA != letterB {
            return 0.85
        }

        // Calculate wheel distance (wraps around at 12)
        let distance = min(
            abs(numA - numB),
            12 - abs(numA - numB)
        )

        // Same letter (both minor or both major)
        if letterA == letterB {
            switch distance {
            case 1: return 0.9   // Adjacent - great for mixing
            case 2: return 0.6   // Two steps - works but noticeable
            case 3: return 0.4
            case 4: return 0.3
            case 5: return 0.2
            default: return 0.1  // Opposite side of wheel
            }
        }

        // Different letter with distance
        // Less compatible as distance increases
        return max(0.1, 0.7 - Double(distance) * 0.12)
    }

    /// Get all compatible keys for mixing
    static func compatibleKeys(for camelot: String) -> [String] {
        guard let parsed = parse(camelot) else { return [] }

        let num = parsed.number
        let letter = parsed.letter
        let otherLetter: Character = letter == "A" ? "B" : "A"

        // Wrap around the wheel
        let prev = num == 1 ? 12 : num - 1
        let next = num == 12 ? 1 : num + 1

        return [
            "\(num)\(letter)",      // Same key
            "\(prev)\(letter)",     // -1 step
            "\(next)\(letter)",     // +1 step
            "\(num)\(otherLetter)"  // Relative major/minor
        ]
    }
}
