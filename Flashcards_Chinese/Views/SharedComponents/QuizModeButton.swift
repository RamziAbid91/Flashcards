//
//  QuizModeButton.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI

struct QuizModeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textColor)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Theme.tertiaryTextColor)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.tertiaryTextColor.opacity(0.7))
        }
        .padding()
        .background(Theme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Theme.cardShadowColor, radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct QuizModeButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            QuizModeButton(
                title: "Meaning Quiz",
                subtitle: "Test your understanding of Chinese words",
                icon: "text.book.closed.fill",
                color: .blue
            )
            
            QuizModeButton(
                title: "Pinyin Quiz",
                subtitle: "Practice writing pinyin for Chinese words",
                icon: "pencil.line",
                color: .green
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        
    }
}
