//
//  TrackRow.swift
//  Vinnies
//
//  A row displaying a track recommendation
//

import SwiftUI

struct TrackRow: View {
    let result: MatchResult
    var onTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            // Track info
            VStack(alignment: .leading, spacing: 2) {
                Text(result.track.title ?? "Unknown Track")
                    .font(.retro(9))
                    .foregroundColor(.retroText)
                    .lineLimit(1)

                if let artist = result.track.artist {
                    Text(artist)
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.retroTextDim)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Match type indicator
            if result.matchType != .direct {
                Text(result.matchType.rawValue)
                    .font(.retro(8))
                    .foregroundColor(.retroCyan)
            }

            // BPM
            if let bpm = result.track.bpm {
                Text("\(Int(bpm))")
                    .font(.retro(9))
                    .foregroundColor(.retroYellow)
                    .frame(width: 35, alignment: .trailing)
            }

            // Key
            if let camelot = result.track.camelot {
                Text(camelot)
                    .font(.retro(9))
                    .foregroundColor(.retroMagenta)
                    .frame(width: 30, alignment: .trailing)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.retroBackgroundLight)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.retroBorder, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if let onTap = onTap {
                onTap()
            } else {
                revealInFinder()
            }
        }
    }

    private func revealInFinder() {
        let url = URL(fileURLWithPath: result.track.path)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}

#Preview {
    VStack(spacing: 4) {
        TrackRow(result: MatchResult(
            track: Track(
                path: "/music/track1.mp3",
                title: "Get Lucky",
                artist: "Daft Punk",
                bpm: 116,
                camelot: "4A"
            ),
            score: 0.95,
            matchType: .direct
        ))

        TrackRow(result: MatchResult(
            track: Track(
                path: "/music/track2.mp3",
                title: "Around The World",
                artist: "Daft Punk",
                bpm: 58,
                camelot: "5A"
            ),
            score: 0.85,
            matchType: .halfTime
        ))
    }
    .padding()
    .background(Color.retroBackground)
}
