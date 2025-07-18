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
    
    init() {
        // Force light mode for the entire app
        #if canImport(UIKit)
            UIView.appearance(whenContainedInInstancesOf: [UIWindow.self]).overrideUserInterfaceStyle = .light
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView(deck: deck)
        }
    }
}
