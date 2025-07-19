//
//  Chinese_FlashcardsApp.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-05-22.

import SwiftUI

@main
struct ChineseFlashcardsApp: App {
    // The deck is now created here and passed down.
    @StateObject private var deck = FlashcardDeck()
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView(deck: deck)
                .environmentObject(themeManager)
                .background(themeManager.currentTheme.backgroundColor)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                .onReceive(themeManager.$isDarkMode) { isDark in
                    updateAppAppearance(isDark: isDark)
                }
                .onAppear {
                    updateAppAppearance(isDark: themeManager.isDarkMode)
                }
        }
    }
    
    private func updateAppAppearance(isDark: Bool) {
        #if canImport(UIKit)
        DispatchQueue.main.async {
            // Update the interface style based on theme setting
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = isDark ? .dark : .light
                    
                    // Force refresh of all UI elements
                    window.rootViewController?.view.setNeedsDisplay()
                    window.rootViewController?.viewDidLoad()
                }
            }
        }
        #endif
    }
}
