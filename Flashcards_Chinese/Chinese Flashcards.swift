//
//  Flashcards_ChineseApp.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-05-22.

import SwiftUI

@main
struct ChineseFlashcardsApp: App {
    // The deck is now created here and passed down.
    @StateObject private var deck = FlashcardDeck()
    
    var body: some Scene {
        WindowGroup {
            MainTabView(deck: deck)
        }
    }
}
