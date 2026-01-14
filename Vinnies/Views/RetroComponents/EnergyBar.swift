//
//  EnergyBar.swift
//  Vinnies
//
//  Retro-styled energy level indicator
//

import SwiftUI

struct EnergyBar: View {
    let value: Double // 0.0 to 1.0
    var segments: Int = 10
    var height: CGFloat = 10

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<segments, id: \.self) { index in
                Rectangle()
                    .fill(fillColor(for: index))
                    .frame(width: 6, height: height)
            }
        }
    }

    private func fillColor(for index: Int) -> Color {
        let threshold = Double(index) / Double(segments)
        if value > threshold {
            // Gradient from cyan to yellow to orange/red
            let progress = Double(index) / Double(segments)
            if progress < 0.5 {
                return .retroCyan
            } else if progress < 0.75 {
                return .retroYellow
            } else {
                return .retroOrange
            }
        } else {
            return Color.retroBorder.opacity(0.5)
        }
    }
}

// MARK: - BPM Display

struct BPMBadge: View {
    let bpm: Double
    var matchType: MatchType = .direct

    var body: some View {
        HStack(spacing: 4) {
            if matchType != .direct {
                Text(matchType.rawValue)
                    .font(.retro(8))
                    .foregroundColor(.retroCyan)
            }
            Text("\(Int(bpm))")
                .font(.retro(10))
                .foregroundColor(.retroYellow)
        }
    }
}

// MARK: - Key Badge

struct KeyBadge: View {
    let camelot: String

    var body: some View {
        Text(camelot)
            .font(.retro(10))
            .foregroundColor(.retroMagenta)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        EnergyBar(value: 0.3)
        EnergyBar(value: 0.6)
        EnergyBar(value: 0.9)

        HStack {
            BPMBadge(bpm: 128)
            BPMBadge(bpm: 64, matchType: .halfTime)
            KeyBadge(camelot: "7A")
        }
    }
    .padding()
    .background(Color.retroBackground)
}
