//
//  MainTabView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var deck: FlashcardDeck
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                HomeView(deck: deck)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            // Flashcards Tab
            NavigationView {
                FlashcardModeView(deck: deck)
            }
            .tabItem {
                Label("Cards", systemImage: "rectangle.on.rectangle.angled.fill")
            }
            .tag(1)
            
            // Quiz Tab
            NavigationView {
                QuizModeView(deck: deck)
            }
            .tabItem {
                Label("Quiz", systemImage: "questionmark.circle.fill")
            }
            .tag(2)
            
            // Favorites Tab
            NavigationView {
                FavoritesView(deck: deck)
            }
            .tabItem {
                Label("Favorites", systemImage: "heart.fill")
            }
            .tag(3)
            
            // Admin Panel Tab
            NavigationView {
                AdminPanelView(deck: deck)
            }
            .tabItem {
                Label("Add Flashcard", systemImage: "plus.circle.fill")
            }
            .tag(4)
            
            // Settings Tab
            NavigationView {
                SettingsView(deck: deck)
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(5)
        }
        .accentColor(Theme.primaryColor)
        .onAppear {
            // Set the tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Theme.cardBackgroundColor)
            
            // Use this appearance for both normal and scrolled states
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// Preview provider
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(deck: FlashcardDeck())
    }
}


