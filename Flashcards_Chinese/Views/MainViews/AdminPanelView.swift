//
//  AdminPanelView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI
import Combine

// This is a dedicated ViewModel for our form state.
class AdminFormViewModel: ObservableObject {
    @Published var chinese: String = ""
    @Published var pinyin: String = ""
    @Published var english: String = ""
    @Published var french: String = ""
    @Published var pronunciation: String = ""
    @Published var category: String = "Basic Words"
    @Published var difficulty: Int = 1
    @Published var exampleSentence: String = ""
    @Published var examplePinyin: String = ""
    @Published var exampleTranslation: String = ""

    var isCardSubmittable: Bool {
        !chinese.isEmpty && !pinyin.isEmpty && !english.isEmpty
    }
    
    func reset(keepingCategory: String) {
        chinese = ""
        pinyin = ""
        english = ""
        french = ""
        pronunciation = ""
        category = keepingCategory
        difficulty = 1
        exampleSentence = ""
        examplePinyin = ""
        exampleTranslation = ""
    }
}


struct AdminPanelView: View {
    @ObservedObject var deck: FlashcardDeck
  
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var formViewModel = AdminFormViewModel()
    
    // State for alerts and search
    @State private var showingNewCategoryAlert = false
    @State private var newCategoryName = ""
    @State private var searchText = ""
    @State private var showingDeleteConfirmation = false
    @State private var cardsToDelete: IndexSet?
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Add New Flashcard").font(.headline)) {
                    TextField("Chinese", text: $formViewModel.chinese)
                    TextField("Pinyin", text: $formViewModel.pinyin)
                    TextField("English", text: $formViewModel.english)
                    TextField("French", text: $formViewModel.french)
                    TextField("Pronunciation", text: $formViewModel.pronunciation)
                    
                    HStack {
                        Picker("Category", selection: $formViewModel.category) {
                            ForEach(deck.categories.filter { $0 != "All" && $0 != "Favorites" }, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        Button { showingNewCategoryAlert = true } label: { Image(systemName: "plus.circle.fill").foregroundColor(Theme.primaryColor) }
                    }
                    
                    Stepper("Difficulty: \(formViewModel.difficulty)", value: $formViewModel.difficulty, in: 1...5)
                    
                    TextField("Example Sentence (Chinese)", text: $formViewModel.exampleSentence, axis: .vertical).lineLimit(2...4)
                    TextField("Example Pinyin", text: $formViewModel.examplePinyin, axis: .vertical).lineLimit(2...4)
                    TextField("Example Translation", text: $formViewModel.exampleTranslation, axis: .vertical).lineLimit(2...4)
                    
                    Button("Add Card") { addNewCard() }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.primaryColor)
                        .disabled(!formViewModel.isCardSubmittable)
                        .frame(maxWidth: .infinity)
                }
                
                Section(header: Text("Manage Cards (\(filteredCards.count))").font(.headline)) {
                    if filteredCards.isEmpty {
                        Text(searchText.isEmpty ? "No cards available" : "No matches for \"\(searchText)\"").foregroundColor(Theme.secondaryTextColor)
                    } else {
                        // --- FIX: The UI for each row is now defined directly here ---
                        ForEach(filteredCards) { card in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(card.chinese).font(.title3.weight(.semibold)).foregroundColor(Theme.textColor)
                                    Text("(\(card.pinyin))").font(.subheadline).foregroundColor(Theme.pinyinColor)
                                    Spacer()
                                    if card.isFavorite { Image(systemName: "heart.fill").foregroundColor(Theme.favoriteColor).font(.caption) }
                                }
                                Text("\(card.english) / \(card.french)").font(.subheadline).foregroundColor(Theme.secondaryTextColor)
                                if !card.exampleSentence.isEmpty {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Ex: \(card.exampleSentence)").font(.caption).lineLimit(1)
                                        Text(card.examplePinyin).font(.caption).foregroundColor(Theme.pinyinColor).lineLimit(1)
                                    }.padding(.top, 2)
                                }
                                HStack {
                                    Text(card.category).font(.caption2).padding(4).background(Theme.primaryColor.opacity(0.1)).foregroundColor(Theme.primaryColor).cornerRadius(4)
                                    Spacer()
                                    DifficultyView(difficulty: card.difficulty)
                                }.padding(.top, 2)
                            }
                            .padding(.vertical, 6)
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Manage Flashcards")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { EditButton().tint(Theme.primaryColor) }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() }.tint(Theme.primaryColor) }
            }
            .searchable(text: $searchText, prompt: "Search cards...")
            .alert("New Category", isPresented: $showingNewCategoryAlert) {
                TextField("Category Name", text: $newCategoryName)
                Button("Add") { addNewCategory() }
                Button("Cancel", role: .cancel) { newCategoryName = "" }
            }
            .alert("Confirm Delete", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) { deleteCards() }
                Button("Cancel", role: .cancel) {}
            } message: { Text("Are you sure you want to delete \(cardsToDelete?.count ?? 0) selected cards?") }
        }
    }
    
    // MARK: - Computed Properties and Methods
    
    private var filteredCards: [Flashcard] {
        if searchText.isEmpty { return deck.cards }
        return deck.cards.filter {
            $0.chinese.localizedCaseInsensitiveContains(searchText) ||
            $0.pinyin.localizedCaseInsensitiveContains(searchText) ||
            $0.english.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func delete(at offsets: IndexSet) {
        self.cardsToDelete = offsets
        self.showingDeleteConfirmation = true
    }
    
    private func addNewCard() {
        deck.addCard(
            chinese: formViewModel.chinese.trimmed(), pinyin: formViewModel.pinyin.trimmed(), english: formViewModel.english.trimmed(), french: formViewModel.french.trimmed(), pronunciation: formViewModel.pronunciation.trimmed(),
            category: formViewModel.category, difficulty: formViewModel.difficulty,
            exampleSentence: formViewModel.exampleSentence.trimmed(), examplePinyin: formViewModel.examplePinyin.trimmed(), exampleTranslation: formViewModel.exampleTranslation.trimmed()
        )
        formViewModel.reset(keepingCategory: formViewModel.category)
        HapticManager.shared.notification(type: .success)
    }
    
    private func addNewCategory() {
        let trimmedName = newCategoryName.trimmed()
        guard !trimmedName.isEmpty, !deck.categories.contains(trimmedName) else { return }
        deck.addCardCategory(trimmedName)
        formViewModel.category = trimmedName
        HapticManager.shared.impact(style: .medium)
        newCategoryName = ""
    }
    
    private func deleteCards() {
        guard let indices = cardsToDelete else { return }
        let cardsToDeleteFromSource = indices.map { filteredCards[$0] }
        deck.cards.removeAll { card in cardsToDeleteFromSource.contains(where: { $0.id == card.id }) }
        deck.saveCards()
        HapticManager.shared.notification(type: .warning)
        self.cardsToDelete = nil
    }
}

// MARK: - DifficultyView Helper
private struct DifficultyView: View {
    let difficulty: Int
   
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { level in
                Image(systemName: "star.fill").font(.caption2)
                    .foregroundColor(level <= difficulty ? Theme.accentColor : Theme.tertiaryTextColor.opacity(0.3))
            }
        }
    }
}

// MARK: - Preview
struct AdminPanelView_Previews: PreviewProvider {
    static var previews: some View {
        AdminPanelView(deck: FlashcardDeck())
    }
}

// Extension to add a new category to the deck
extension FlashcardDeck {
    func addCardCategory(_ name: String) {
        guard !categories.contains(name) else { return }
        categories.append(name)
        categories.sort { $0.lowercased() < $1.lowercased() }
        if let allIndex = categories.firstIndex(of: "All") {
            categories.move(fromOffsets: IndexSet(integer: allIndex), toOffset: 0)
        }
    }
}
