//
//  AddCardView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI

struct AddCardView: View {
    @ObservedObject var deck: FlashcardDeck
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: Int
    
    @State private var chinese = ""
    @State private var pinyin = ""
    @State private var pronunciation = ""
    @State private var english = ""
    @State private var french = ""
    @State private var exampleSentence = ""
    @State private var examplePinyin = ""
    @State private var exampleTranslation = ""
    @State private var category = "Basic Words"
    @State private var difficulty = 1
    
    private var isValid: Bool {
        !chinese.isEmpty && !pinyin.isEmpty && !english.isEmpty
    }
    
    private func saveCard() {
        deck.addCard(
            chinese: chinese,
            pinyin: pinyin,
            english: english,
            french: french,
            pronunciation: pronunciation,
            category: category,
            difficulty: difficulty,
            exampleSentence: exampleSentence,
            examplePinyin: examplePinyin,
            exampleTranslation: exampleTranslation
        )
        HapticManager.shared.notification(type: .success)
        dismiss()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // ... existing code ...
                    }
                    .padding()
                }
            }
            .navigationTitle("Add New Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.accentColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            selectedTab = 3 // Switch to Admin Panel
                        }) {
                            Image(systemName: "gear.circle.fill")
                                .foregroundColor(Theme.accentColor)
                        }
                        
                        Button("Save") {
                            saveCard()
                        }
                        .foregroundColor(Theme.accentColor)
                        .disabled(!isValid)
                    }
                }
            }
        }
    }
} 