//
//  NowPlayingView.swift
//  Vinnies
//
//  Displays the currently playing/selected track
//

import SwiftUI

struct NowPlayingView: View {
    let title: String?
    let artist: String?
    let bpm: Double?
    let camelot: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOW PLAYING")
                .font(.retro(10))
                .foregroundColor(.retroCyan)

            VStack(alignment: .leading, spacing: 6) {
                // Track title
                Text(title ?? "Select a track...")
                    .font(.retro(11))
                    .foregroundColor(.retroText)
                    .lineLimit(1)

                // Artist
                if let artist = artist {
                    Text(artist)
                        .font(.retroSmall())
                        .foregroundColor(.retroTextDim)
                        .lineLimit(1)
                }

                // BPM and Key
                HStack(spacing: 16) {
                    if let bpm = bpm {
                        HStack(spacing: 4) {
                            Text("BPM")
                                .font(.retroSmall())
                                .foregroundColor(.retroTextDim)
                            Text("\(Int(bpm))")
                                .font(.retro(11))
                                .foregroundColor(.retroYellow)
                        }
                    }

                    if let camelot = camelot {
                        HStack(spacing: 4) {
                            Text("KEY")
                                .font(.retroSmall())
                                .foregroundColor(.retroTextDim)
                            Text(camelot)
                                .font(.retro(11))
                                .foregroundColor(.retroMagenta)
                        }
                    }
                }
            }
            .retroCard(padding: 10)
        }
    }
}

#Preview {
    VStack {
        NowPlayingView(
            title: "Blinding Lights",
            artist: "The Weeknd",
            bpm: 171,
            camelot: "6A"
        )

        NowPlayingView(
            title: nil,
            artist: nil,
            bpm: nil,
            camelot: nil
        )
    }
    .padding()
    .background(Color.retroBackground)
}
