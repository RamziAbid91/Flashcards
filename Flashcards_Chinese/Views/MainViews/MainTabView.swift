//
//  MainTabView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-05-22.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var deck: FlashcardDeck
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView(deck: deck)
                    .background(themeManager.currentTheme.backgroundColor)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            NavigationView {
                FlashcardModeView(deck: deck)
                    .background(themeManager.currentTheme.backgroundColor)
            }
            .tabItem {
                Image(systemName: "rectangle.stack.fill")
                Text("Study")
            }
            
            NavigationView {
                QuizModeView(deck: deck)
                    .background(themeManager.currentTheme.backgroundColor)
            }
            .tabItem {
                Image(systemName: "questionmark.circle.fill")
                Text("Quiz")
            }
            
            NavigationView {
                FavoritesView(deck: deck)
                    .background(themeManager.currentTheme.backgroundColor)
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text("Favorites")
            }
            
            NavigationView {
                AdminPanelView(deck: deck)
                    .background(themeManager.currentTheme.backgroundColor)
            }
            .tabItem {
                Image(systemName: "person.2.fill")
                Text("Admin")
            }
            
            NavigationView {
                SettingsView(deck: deck)
                    .background(themeManager.currentTheme.backgroundColor)
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
        }
        .accentColor(themeManager.currentTheme.primaryColor)
        .background(themeManager.currentTheme.backgroundColor)
        .onChange(of: themeManager.isDarkMode) { _ in
            updateTabBarAppearance()
        }
        .onAppear {
            updateTabBarAppearance()
        }
    }
    
    private func updateTabBarAppearance() {
        // Update tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(themeManager.currentTheme.tabBarColor)
        
        // Remove separator line
        appearance.shadowColor = UIColor.clear
        
        // Configure tab bar item colors
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(themeManager.currentTheme.primaryColor)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(themeManager.currentTheme.primaryColor)]
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(themeManager.currentTheme.tertiaryTextColor)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(themeManager.currentTheme.tertiaryTextColor)]
        
        // Apply to all tab bars immediately
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Update navigation bar appearance immediately
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(themeManager.currentTheme.navigationBarColor)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor(themeManager.currentTheme.textColor)]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(themeManager.currentTheme.textColor)]
        
        // Completely remove navigation bar separator
        navAppearance.shadowColor = UIColor.clear
        navAppearance.shadowImage = UIImage()
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        
        // Force immediate update of existing UI elements
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    // Update all tab bars
                    self.updateAllSubviews(in: window.rootViewController?.view, tabBarAppearance: appearance, navBarAppearance: navAppearance)
                    
                    // Force immediate refresh
                    window.rootViewController?.view.setNeedsLayout()
                    window.rootViewController?.view.layoutIfNeeded()
                }
            }
        }
    }
    
    private func updateAllSubviews(in view: UIView?, tabBarAppearance: UITabBarAppearance, navBarAppearance: UINavigationBarAppearance) {
        guard let view = view else { return }
        
        // Use a queue to avoid deep recursion and improve performance
        var viewsToProcess: [UIView] = [view]
        
        while !viewsToProcess.isEmpty {
            let currentView = viewsToProcess.removeFirst()
            
            // Update tab bars
            if let tabBar = currentView as? UITabBar {
                tabBar.standardAppearance = tabBarAppearance
                tabBar.scrollEdgeAppearance = tabBarAppearance
                tabBar.setNeedsLayout()
            }
            // Update navigation bars
            else if let navBar = currentView as? UINavigationBar {
                navBar.standardAppearance = navBarAppearance
                navBar.compactAppearance = navBarAppearance
                navBar.scrollEdgeAppearance = navBarAppearance
                navBar.setNeedsLayout()
            }
            // Only continue traversing if we haven't found our target elements
            else {
                viewsToProcess.append(contentsOf: currentView.subviews)
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(deck: FlashcardDeck())
    }
}


