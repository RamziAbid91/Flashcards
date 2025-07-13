//
//  SettingsView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var deck: FlashcardDeck
    
    // App Storage for user preferences
    @AppStorage("showFrenchInFlashcards") private var showFrench = false
    @AppStorage("showShuffleButton") private var showShuffleButton = false
    @AppStorage("Vibration Effects") private var enableHaptics = true
    
    // State for alerts
    @State private var showingResetAlert = false
    @State private var resetAlertMessage = ""
    
    var body: some View {
        Form {
            // MARK: - Display Settings
            Section(header: Text("Display").font(.headline)) {
                Toggle("Show French Translations", isOn: $showFrench)
                    .tint(Theme.primaryColor)
                Toggle("Show Shuffle Button", isOn: $showShuffleButton)
                    .tint(Theme.primaryColor)
            }

            // MARK: - Interaction Settings
            Section(header: Text("Interaction").font(.headline)) {
                Toggle("Vibration Effects", isOn: $enableHaptics)
                    .tint(Theme.primaryColor)
            }
            
            // MARK: - Data Management
            Section(header: Text("Data").font(.headline)) {
                Button("Reset All Favorites", role: .destructive, action: resetFavorites)
                    .foregroundColor(Theme.destructiveColor)
                
                Button("Restore Default Cards", action: restoreDefaultCards)
                    .foregroundColor(Theme.primaryColor)
                
                Button("Restore Default Order", action: restoreDefaultOrder)
                    .foregroundColor(Theme.primaryColor)
            }

            // MARK: - About Section
            Section(header: Text("About").font(.headline)) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.appVersion)
                        .foregroundColor(Theme.secondaryTextColor)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .background(Theme.backgroundColor)
        .scrollContentBackground(.hidden)
        .alert("Reset Completed", isPresented: $showingResetAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(resetAlertMessage)
        }
    }
    
    private func resetFavorites() {
        deck.cards.indices.forEach { index in
            // Because Flashcard is a class, we modify it directly
            deck.cards[index].isFavorite = false
        }
        deck.saveCards()
        HapticManager.shared.notification(type: .success)
        resetAlertMessage = "All favorites have been reset."
        showingResetAlert = true
    }
      
    private func restoreDefaultCards() {
        deck.resetToDefaultCards()
        HapticManager.shared.notification(type: .success)
        resetAlertMessage = "Default flashcard set has been restored."
        showingResetAlert = true
    }
    
    private func restoreDefaultOrder() {
        deck.restoreDefaultOrder()
        HapticManager.shared.notification(type: .success)
        resetAlertMessage = "Cards have been restored to default order."
        showingResetAlert = true
    }
}

// This helper extension can remain in this file or be moved to its own file.
extension Bundle {
    var appVersion: String {
        guard let version = infoDictionary?["CFBundleShortVersionString"] as? String,
              let build = infoDictionary?["CFBundleVersion"] as? String else {
            return "1.0.0"
        }
        return "\(version) (\(build))"
    }
}


// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(deck: FlashcardDeck())
        }
    }
}
