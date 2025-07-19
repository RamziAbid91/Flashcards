//
//  FavoriteCardRow.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI

struct FavoriteCardRow: View {
    let card: Flashcard
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.chinese)
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.textColor)
                Text(card.pinyin)
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.pinyinColor)
                Text(card.english)
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
            }
            Spacer()
            Image(systemName: "heart.fill")
                .foregroundColor(themeManager.currentTheme.favoriteColor)
        }
        .padding(.vertical, 8)
        .animation(ThemeTransition.smooth, value: themeManager.isDarkMode)
    }
}

struct FavoriteCardRow_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteCardRow(card: FlashcardDeck.defaultCards().first!)
            .padding()
          
    }
}
