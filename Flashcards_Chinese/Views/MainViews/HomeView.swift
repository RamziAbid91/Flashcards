//
//  HomeView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var deck: FlashcardDeck

    var body: some View {
        ZStack {
            // Use a subtle gradient for the background
            LinearGradient(gradient: Gradient(colors: [Theme.primaryColor.opacity(0.1), Theme.backgroundColor]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                // App Icon and Title
                Image(systemName: "character.bubble.fill.zh")
                    .font(.system(size: 70, weight: .semibold))
                    .foregroundColor(Theme.primaryColor)
                    .padding(.bottom, 5)
                
                Text("中文一点通")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.primaryColor)
                
                Text("Chinese Flashcards")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.secondaryTextColor)
                    .padding(.bottom, 20)
                
                // Welcome Message
                VStack(spacing: 12) {
                    Text("Welcome to Chinese Flashcards!")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(Theme.textColor)
                    
                    Text("Use the tabs below to navigate between different features.")
                        .font(.subheadline)
                        .foregroundColor(Theme.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                Spacer()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(deck: FlashcardDeck())
    }
}
