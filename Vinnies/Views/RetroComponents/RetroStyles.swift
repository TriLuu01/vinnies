//
//  RetroStyles.swift
//  Vinnies
//
//  Retro PS1/Mega Man X4 inspired styling
//

import SwiftUI

// MARK: - Colors

extension Color {
    // Background colors
    static let retroBackground = Color(hex: "0a0a0a")
    static let retroBackgroundLight = Color(hex: "1a1a1a")
    static let retroBorder = Color(hex: "404040")

    // Text colors
    static let retroText = Color(hex: "e0e0e0")
    static let retroTextDim = Color(hex: "808080")

    // Accent colors (MMX4 palette)
    static let retroCyan = Color(hex: "00ffff")
    static let retroMagenta = Color(hex: "ff00ff")
    static let retroYellow = Color(hex: "ffff00")
    static let retroGreen = Color(hex: "00ff00")
    static let retroOrange = Color(hex: "ff8800")
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Fonts

extension Font {
    /// Retro monospaced font
    static func retro(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .monospaced)
    }

    /// Smaller retro font for details
    static func retroSmall() -> Font {
        .system(size: 9, weight: .medium, design: .monospaced)
    }

    /// Header retro font
    static func retroHeader() -> Font {
        .system(size: 12, weight: .bold, design: .monospaced)
    }
}

// MARK: - View Modifiers

struct RetroCardModifier: ViewModifier {
    var padding: CGFloat = 12

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.retroBackgroundLight)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.retroBorder, lineWidth: 2)
            )
    }
}

struct RetroButtonModifier: ViewModifier {
    var color: Color = .retroCyan

    func body(content: Content) -> some View {
        content
            .font(.retro(10))
            .foregroundColor(.retroBackground)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .cornerRadius(2)
    }
}

extension View {
    func retroCard(padding: CGFloat = 12) -> some View {
        modifier(RetroCardModifier(padding: padding))
    }

    func retroButton(color: Color = .retroCyan) -> some View {
        modifier(RetroButtonModifier(color: color))
    }
}

// MARK: - Retro Divider

struct RetroDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.retroBorder)
            .frame(height: 2)
    }
}
