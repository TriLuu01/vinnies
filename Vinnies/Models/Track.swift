//
//  Track.swift
//  Vinnies
//

import Foundation

struct Track: Identifiable, Codable {
    var id: String { path }
    var path: String
    var title: String?
    var artist: String?
    var bpm: Double?
    var key: Int?           // 0-11 (C to B)
    var mode: Int?          // 0=minor, 1=major
    var camelot: String?    // "7A", "3B", etc.
    var energy: Double?
    var lastAnalyzed: Date?

    init(
        path: String,
        title: String? = nil,
        artist: String? = nil,
        bpm: Double? = nil,
        key: Int? = nil,
        mode: Int? = nil,
        camelot: String? = nil,
        energy: Double? = nil,
        lastAnalyzed: Date? = nil
    ) {
        self.path = path
        self.title = title
        self.artist = artist
        self.bpm = bpm
        self.key = key
        self.mode = mode
        self.camelot = camelot
        self.energy = energy
        self.lastAnalyzed = lastAnalyzed
    }
}
