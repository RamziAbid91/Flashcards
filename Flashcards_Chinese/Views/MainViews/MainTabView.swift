//
//  MainTabView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-05-22.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var deck: FlashcardDeck
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView(deck: deck)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            NavigationView {
                FlashcardModeView(deck: deck)
            }
            .tabItem {
                Image(systemName: "rectangle.stack.fill")
                Text("Study")
            }
            
            NavigationView {
                QuizModeView(deck: deck)
            }
            .tabItem {
                Image(systemName: "questionmark.circle.fill")
                Text("Quiz")
            }
            
            NavigationView {
                FavoritesView(deck: deck)
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text("Favorites")
            }
            
            NavigationView {
                AdminPanelView(deck: deck)
            }
            .tabItem {
                Image(systemName: "person.2.fill")
                Text("Admin")
            }
            
            NavigationView {
                SettingsView(deck: deck)
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
        }
        .accentColor(Theme.primaryColor)
        .onAppear {
            // Configure tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Theme.cardBackgroundColor)
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(deck: FlashcardDeck())
    }
}


