//
//  FavoritesView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var deck: FlashcardDeck
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var searchText = ""
    
    // MARK: - Computed Properties with Explicit Observation
    private var favoriteCards: [Flashcard] {
        deck.favoriteCards
    }
    
    var filteredFavorites: [Flashcard] {
        if searchText.isEmpty {
            return favoriteCards
        } else {
            // Use cached favorites and filter only when needed
            return favoriteCards.filter {
                $0.chinese.localizedCaseInsensitiveContains(searchText) ||
                $0.pinyin.localizedCaseInsensitiveContains(searchText) ||
                $0.english.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundColor.ignoresSafeArea()
            
            VStack {
                if favoriteCards.isEmpty {
                    emptyStateView
                } else if filteredFavorites.isEmpty {
                    noResultsView
                } else {
                    favoritesList
                }
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search favorites...")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !favoriteCards.isEmpty {
                    EditButton()
                        .tint(themeManager.currentTheme.primaryColor)
                }
            }
        }
        .animation(ThemeTransition.smooth, value: themeManager.isDarkMode)
        // Force refresh when deck changes
        .onReceive(deck.$cards) { _ in
            // This ensures the view updates when cards change
        }
        .onAppear {
            // Force refresh when view appears to ensure latest data
            deck.objectWillChange.send()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 50))
                .foregroundColor(themeManager.currentTheme.placeholderTextColor)
            Text("No Favorites Yet")
                .font(.title3)
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            Text("Tap the heart icon on a flashcard to save it here.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(themeManager.currentTheme.tertiaryTextColor)
        }
        .padding()
    }
    
    private var noResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(themeManager.currentTheme.placeholderTextColor)
            Text("No Matches Found")
                .font(.title3)
                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            Text("No favorites match \"\(searchText)\".")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(themeManager.currentTheme.tertiaryTextColor)
        }
        .padding()
    }
    
    private var favoritesList: some View {
        List {
            ForEach(filteredFavorites) { card in
                NavigationLink(destination: FlashcardDetailView(card: card, deck: deck)) {
                    FavoriteCardRow(card: card)
                }
            }
            .onDelete { offsets in
                let cardsToDelete = offsets.map { filteredFavorites[$0] }
                for card in cardsToDelete {
                    deck.toggleFavorite(card: card)
                }
            }
            .listRowBackground(themeManager.currentTheme.cardBackgroundColor)
        }
        .listStyle(.plain)
        .themedListBackground()
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a deck and favorite some cards for the preview
        let previewDeck = FlashcardDeck()
        if !previewDeck.cards.isEmpty {
            previewDeck.toggleFavorite(card: previewDeck.cards[0])
            previewDeck.toggleFavorite(card: previewDeck.cards[1])
        }
        
        return NavigationView {
            FavoritesView(deck: previewDeck)
                
        }
    }
}
