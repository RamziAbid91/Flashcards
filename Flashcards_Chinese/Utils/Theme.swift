//
//  Theme.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI

// Reverted to a simple, static struct for the default "Calm" theme.
struct Theme {
    static let backgroundColor = Color(hex: "FAF9F6")
    static let cardBackgroundColor = Color(hex: "FFFFFF")
    static let secondaryBackgroundColor = Color(hex: "F5F5F5")
    static let tertiaryBackgroundColor = Color(hex: "F5F5F5")

    static let textColor = Color(hex: "263238")
    static let secondaryTextColor = Color(hex: "424242")
    static let tertiaryTextColor = Color(hex: "616161")
    static let pinyinColor = Color(hex: "0277BD")
    static let placeholderTextColor = Color.gray.opacity(0.6)

    static let primaryColor = Color(hex: "0277BD")
    static let favoriteColor = Color(hex: "E57373")
    static let destructiveColor = Color(hex: "EF5350")
    static let accentColor = Color(hex: "66BB6A")

    static let cardBorderColor = Color.black.opacity(0.1)
    static let cardShadowColor = Color.black.opacity(0.08)
}

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
