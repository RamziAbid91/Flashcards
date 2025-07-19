//
//  HomeView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var deck: FlashcardDeck
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            // Dynamic gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    themeManager.currentTheme.primaryColor.opacity(themeManager.isDarkMode ? 0.2 : 0.1),
                    themeManager.currentTheme.backgroundColor
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 50)
                    
                    // App Icon and Title with animation
                    VStack(spacing: 20) {
                        Image(systemName: "character.bubble.fill.zh")
                            .font(.system(size: 70, weight: .semibold))
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                            .scaleEffect(themeManager.isDarkMode ? 1.1 : 1.0)
                            .animation(ThemeTransition.spring, value: themeManager.isDarkMode)
                        
                        VStack(spacing: 8) {
                            Text("中文一点通")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            
                            Text("Chinese Flashcards")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        }
                    }
                    
                    // Welcome Text
                    VStack(spacing: 16) {
                        Text("Welcome to Chinese Flashcards")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(themeManager.currentTheme.textColor)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        
                        Text("Use the tabs below to navigate between different features")
                            .font(.subheadline)
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal)
            }
        }
        .animation(ThemeTransition.smooth, value: themeManager.isDarkMode)
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(deck: FlashcardDeck())
    }
}
