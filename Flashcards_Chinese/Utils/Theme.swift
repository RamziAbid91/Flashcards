//
//  Theme.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "darkModeEnabled")
        }
    }
    
    private init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "darkModeEnabled")
    }
    
    var currentTheme: AppTheme {
        isDarkMode ? AppTheme.dark : AppTheme.light
    }
}

// MARK: - Theme Definitions
struct AppTheme {
    let backgroundColor: Color
    let cardBackgroundColor: Color
    let secondaryBackgroundColor: Color
    let tertiaryBackgroundColor: Color
    
    let textColor: Color
    let secondaryTextColor: Color
    let tertiaryTextColor: Color
    let pinyinColor: Color
    let placeholderTextColor: Color
    
    let primaryColor: Color
    let favoriteColor: Color
    let destructiveColor: Color
    let accentColor: Color
    
    let cardBorderColor: Color
    let cardShadowColor: Color
    
    // Navigation and Tab Bar Colors
    let navigationBarColor: Color
    let tabBarColor: Color
    
    // Light Theme
    static let light = AppTheme(
        backgroundColor: Color(hex: "FAF9F6"),
        cardBackgroundColor: Color(hex: "FFFFFF"),
        secondaryBackgroundColor: Color(hex: "F5F5F5"),
        tertiaryBackgroundColor: Color(hex: "F5F5F5"),
        
        textColor: Color(hex: "263238"),
        secondaryTextColor: Color(hex: "424242"),
        tertiaryTextColor: Color(hex: "616161"),
        pinyinColor: Color(hex: "0277BD"),
        placeholderTextColor: Color.gray.opacity(0.6),
        
        primaryColor: Color(hex: "0277BD"),
        favoriteColor: Color(hex: "E57373"),
        destructiveColor: Color(hex: "EF5350"),
        accentColor: Color(hex: "66BB6A"),
        
        cardBorderColor: Color.black.opacity(0.1),
        cardShadowColor: Color.black.opacity(0.08),
        
        navigationBarColor: Color(hex: "FFFFFF"),
        tabBarColor: Color(hex: "FFFFFF")
    )
    
    // Dark Theme
    static let dark = AppTheme(
        backgroundColor: Color(hex: "121212"),
        cardBackgroundColor: Color(hex: "1E1E1E"),
        secondaryBackgroundColor: Color(hex: "2A2A2A"),
        tertiaryBackgroundColor: Color(hex: "333333"),
        
        textColor: Color(hex: "FFFFFF"),
        secondaryTextColor: Color(hex: "E0E0E0"),
        tertiaryTextColor: Color(hex: "BDBDBD"),
        pinyinColor: Color(hex: "42A5F5"),
        placeholderTextColor: Color.gray.opacity(0.7),
        
        primaryColor: Color(hex: "42A5F5"),
        favoriteColor: Color(hex: "EF5350"),
        destructiveColor: Color(hex: "F44336"),
        accentColor: Color(hex: "4CAF50"),
        
        cardBorderColor: Color.white.opacity(0.12),
        cardShadowColor: Color.black.opacity(0.3),
        
        navigationBarColor: Color(hex: "1E1E1E"),
        tabBarColor: Color(hex: "1E1E1E")
    )
}

// MARK: - Legacy Theme Support (for backward compatibility)
struct Theme {
    @StateObject private static var themeManager = ThemeManager.shared
    
    static var backgroundColor: Color { ThemeManager.shared.currentTheme.backgroundColor }
    static var cardBackgroundColor: Color { ThemeManager.shared.currentTheme.cardBackgroundColor }
    static var secondaryBackgroundColor: Color { ThemeManager.shared.currentTheme.secondaryBackgroundColor }
    static var tertiaryBackgroundColor: Color { ThemeManager.shared.currentTheme.tertiaryBackgroundColor }
    
    static var textColor: Color { ThemeManager.shared.currentTheme.textColor }
    static var secondaryTextColor: Color { ThemeManager.shared.currentTheme.secondaryTextColor }
    static var tertiaryTextColor: Color { ThemeManager.shared.currentTheme.tertiaryTextColor }
    static var pinyinColor: Color { ThemeManager.shared.currentTheme.pinyinColor }
    static var placeholderTextColor: Color { ThemeManager.shared.currentTheme.placeholderTextColor }
    
    static var primaryColor: Color { ThemeManager.shared.currentTheme.primaryColor }
    static var favoriteColor: Color { ThemeManager.shared.currentTheme.favoriteColor }
    static var destructiveColor: Color { ThemeManager.shared.currentTheme.destructiveColor }
    static var accentColor: Color { ThemeManager.shared.currentTheme.accentColor }
    
    static var cardBorderColor: Color { ThemeManager.shared.currentTheme.cardBorderColor }
    static var cardShadowColor: Color { ThemeManager.shared.currentTheme.cardShadowColor }
}

// MARK: - View Modifiers
struct ThemedCardModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    let padding: CGFloat
    
    init(padding: CGFloat = 16) {
        self.padding = padding
    }
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(themeManager.currentTheme.cardBackgroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(themeManager.currentTheme.cardBorderColor, lineWidth: 1)
            )
            .shadow(
                color: themeManager.currentTheme.cardShadowColor,
                radius: themeManager.isDarkMode ? 8 : 4,
                x: 0,
                y: themeManager.isDarkMode ? 4 : 2
            )
    }
}

struct ThemedBackgroundModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
    }
}

// MARK: - View Extensions
extension View {
    func themedCard(padding: CGFloat = 16) -> some View {
        self.modifier(ThemedCardModifier(padding: padding))
    }
    
    func themedBackground() -> some View {
        self.modifier(ThemedBackgroundModifier())
    }
    
    func themedListBackground() -> some View {
        self.scrollContentBackground(.hidden)
            .background(ThemeManager.shared.currentTheme.backgroundColor)
    }
}

// MARK: - Animation Helpers
struct ThemeTransition {
    static let smooth = Animation.easeInOut(duration: 0.25)
    static let quick = Animation.easeInOut(duration: 0.15)
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.85)
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
