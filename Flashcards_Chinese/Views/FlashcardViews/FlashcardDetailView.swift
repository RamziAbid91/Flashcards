//
//  FlashcardDetailView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI

struct FlashcardDetailView: View {
    let card: Flashcard
    @ObservedObject var deck: FlashcardDeck
    
    @State private var isFavorite: Bool
    
    init(card: Flashcard, deck: FlashcardDeck) {
        self.card = card
        self.deck = deck
        self._isFavorite = State(initialValue: card.isFavorite)
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    characterSection
                    translationsSection
                    exampleSection
                    favoriteButton
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Flashcard Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var characterSection: some View {
        VStack(spacing: 10) {
            Text(card.chinese)
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(Theme.textColor)
            
            Text(card.pinyin)
                .font(.title2)
                .foregroundColor(Theme.pinyinColor)
            
            Text("Pron: \(card.pronunciation)")
                .font(.subheadline)
                .foregroundColor(Theme.secondaryTextColor)
                .italic()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Theme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Theme.cardShadowColor, radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private var translationsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Translations").font(.headline).foregroundColor(Theme.textColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("English:").font(.subheadline).foregroundColor(Theme.secondaryTextColor)
                Text(card.english).font(.body).foregroundColor(Theme.textColor)
            }
            
            Divider().padding(.vertical, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("French:").font(.subheadline).foregroundColor(Theme.secondaryTextColor)
                Text(card.french).font(.body).foregroundColor(Theme.textColor)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Theme.cardShadowColor, radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private var exampleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Example Usage").font(.headline).foregroundColor(Theme.textColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(card.exampleSentence).font(.body).foregroundColor(Theme.textColor)
                Text(card.examplePinyin).font(.subheadline).foregroundColor(Theme.pinyinColor)
                Text(card.exampleTranslation).font(.subheadline).italic().foregroundColor(Theme.secondaryTextColor)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Theme.cardShadowColor, radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private var favoriteButton: some View {
        Button {
            isFavorite.toggle()
            deck.toggleFavorite(card: card)
        } label: {
            Label(isFavorite ? "Remove from Favorites" : "Add to Favorites",
                  systemImage: isFavorite ? "heart.fill" : "heart")
                .font(.headline)
                .foregroundColor(isFavorite ? .white : Theme.favoriteColor)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isFavorite ? Theme.favoriteColor : Theme.cardBackgroundColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.favoriteColor, lineWidth: 1.5)
                )
        }
        .padding(.horizontal)
    }
}

struct FlashcardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FlashcardDetailView(card: FlashcardDeck.defaultCards().first!, deck: FlashcardDeck())
                
        }
    }
}
