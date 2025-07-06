
//
//  MainMenuButton.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI

struct MainMenuButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
                .frame(width: 30, alignment: .center)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textColor)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryTextColor)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.secondaryTextColor.opacity(0.6))
        }
        .padding()
        .background(Theme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Theme.cardShadowColor, radius: 4, x: 0, y: 2)
    }
}

struct MainMenuButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MainMenuButton(
                title: "Flashcards",
                subtitle: "Study & Review",
                icon: "rectangle.stack.fill",
                color: Theme.primaryColor
            )
        }
        .padding()
        .background(Theme.backgroundColor)
    }
}
