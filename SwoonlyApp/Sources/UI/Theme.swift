import SwiftUI
import UIKit

// MARK: - Swoonly design language — "Warm Paper / Soft Noir"
// Quiet UI per house style: solid surfaces only (NO glass / blur / material), hairline borders,
// restrained shadow, single rose accent (~8% coverage). Hero metaphor: the cover wall / a book at night.

enum Theme {
    private static func ui(_ hex: UInt) -> UIColor {
        UIColor(red: CGFloat((hex >> 16) & 0xff)/255, green: CGFloat((hex >> 8) & 0xff)/255,
                blue: CGFloat(hex & 0xff)/255, alpha: 1)
    }
    /// Adaptive color: light value / dark value.
    static func dyn(_ light: UInt, _ dark: UInt) -> Color {
        Color(UIColor { tc in tc.userInterfaceStyle == .dark ? ui(dark) : ui(light) })
    }

    static let canvas        = dyn(0xF5F3EF, 0x101114)
    static let surface       = dyn(0xFCFBF8, 0x181A1F)
    static let elevated      = dyn(0xFFFFFF, 0x22252B)
    static let textPrimary   = dyn(0x24221F, 0xF0EEE9)
    static let textSecondary = dyn(0x6F6A63, 0xAAA7A1)
    static let hairline      = Color.primary.opacity(0.08)

    // Single brand accent — dusty rose (romance), used sparingly for CTAs / selection.
    static let accent     = Color(red: 0.831, green: 0.345, blue: 0.443) // #D45871
    static let accentSoft = accent.opacity(0.14)
    static let success    = Color(red: 0.36, green: 0.62, blue: 0.45)
    static let lock       = textSecondary

    static func color(hex: String) -> Color {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var v: UInt64 = 0; Scanner(string: h).scanHexInt64(&v)
        return Color(red: Double((v>>16)&0xff)/255, green: Double((v>>8)&0xff)/255, blue: Double(v&0xff)/255)
    }
}

/// Standard solid card: surface fill + hairline + soft shadow. No glass.
struct Card<Content: View>: View {
    var padding: CGFloat = 16
    var radius: CGFloat = 16
    @ViewBuilder var content: Content
    var body: some View {
        content.padding(padding).frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: radius, style: .continuous).fill(Theme.surface))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).strokeBorder(Theme.hairline, lineWidth: 0.8))
            .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
}
extension View {
    func card(_ p: CGFloat = 16, radius: CGFloat = 16) -> some View { Card(padding: p, radius: radius) { self } }
}

/// Reader paper themes (user-chosen, explicit — not the app chrome).
enum ReaderTheme: String, CaseIterable, Identifiable {
    case paper, sepia, night
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
    var bg: Color {
        switch self { case .paper: return Color(red: 0.984, green: 0.973, blue: 0.949)
        case .sepia: return Color(red: 0.953, green: 0.906, blue: 0.808)
        case .night: return Color(red: 0.071, green: 0.075, blue: 0.086) }
    }
    var text: Color {
        switch self { case .paper: return Color(red: 0.165, green: 0.145, blue: 0.133)
        case .sepia: return Color(red: 0.227, green: 0.184, blue: 0.133)
        case .night: return Color(red: 0.847, green: 0.835, blue: 0.808) }
    }
}

extension Font {
    /// Serif reading face for story prose (New York).
    static func reading(_ s: CGFloat) -> Font { .system(size: s, weight: .regular, design: .serif) }
}
