//
//  FavoriteCardRow.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI

struct FavoriteCardRow: View {
    let card: Flashcard
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.chinese)
                    .font(.headline)
                    .foregroundColor(Theme.textColor)
                Text(card.pinyin)
                    .font(.subheadline)
                    .foregroundColor(Theme.pinyinColor)
                Text(card.english)
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryTextColor)
            }
            Spacer()
            Image(systemName: "heart.fill")
                .foregroundColor(Theme.favoriteColor)
        }
        .padding(.vertical, 8)
    }
}

struct FavoriteCardRow_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteCardRow(card: FlashcardDeck.defaultCards().first!)
            .padding()
          
    }
}
