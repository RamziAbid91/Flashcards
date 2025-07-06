//
//  FlashcardModeView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI
import AVFoundation

struct FlashcardModeView: View {
    @ObservedObject var deck: FlashcardDeck
   
    
    // MARK: - State Variables
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var dragOffset: CGSize = .zero
    @State private var selectedCategory: String
    
    @AppStorage("showFrenchInFlashcards") private var showFrench = false
    @State private var showingCategoryPicker = false
    @State private var showingVoiceAlert = false
    @State private var voiceAlertMessage = ""
    
    private let synthesizer = AVSpeechSynthesizer()
    
    // MARK: - Computed Properties
    var filteredCards: [Flashcard] {
        let cards: [Flashcard]
        if selectedCategory == "Favorites" {
            cards = deck.favoriteCards
        } else if selectedCategory == "All" {
            cards = deck.cards
        } else {
            cards = deck.cards.filter { $0.category == selectedCategory }
        }
        
        if currentIndex >= cards.count && !cards.isEmpty {
            DispatchQueue.main.async {
                currentIndex = max(0, cards.count - 1)
                isFlipped = false
            }
        }
        return cards
    }
    
    // MARK: - Initializer
    init(deck: FlashcardDeck, startingCategory: String? = nil) {
        self.deck = deck
        if let category = startingCategory, deck.categories.contains(category) {
            _selectedCategory = State(initialValue: category)
        } else {
            _selectedCategory = State(initialValue: "All")
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Theme.backgroundColor.edgesIgnoringSafeArea(.all)
            VStack(spacing: 15) {
                categoryAndProgressHeader
                contentView
                controlsFooter
            }
        }
        .navigationTitle("Study Flashcards")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleAdminPanel) {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .foregroundColor(Theme.primaryColor)
                }
            }
        }
        .sheet(isPresented: $deck.showAdminPanel) { AdminPanelView(deck: deck) }
        .alert("Voice Error", isPresented: $showingVoiceAlert) { Button("OK") {}; Button("Settings") { openAppSettings() } } message: { Text(voiceAlertMessage) }
        .onChange(of: filteredCards.count) { _ in handleCardCountChange() }
        .onChange(of: selectedCategory) { _ in resetToNewCategory() }
    }
    
    // MARK: - Subviews
    private var categoryAndProgressHeader: some View {
        VStack(spacing: 15) {
            HStack {
                Button(action: toggleCategoryPicker) {
                    HStack {
                        Text(selectedCategory).font(.subheadline.weight(.medium)).lineLimit(1).foregroundColor(Theme.primaryColor)
                        Image(systemName: "chevron.down").font(.caption).foregroundColor(Theme.primaryColor)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8).background(Theme.cardBackgroundColor)
                    .cornerRadius(8).shadow(color: Theme.cardShadowColor.opacity(0.5), radius: 2, x: 0, y: 1)
                }
                Spacer()
                if !filteredCards.isEmpty {
                    Text("Card \(currentIndex + 1) of \(filteredCards.count)").font(.subheadline.weight(.medium)).foregroundColor(Theme.tertiaryTextColor)
                }
            }
            .padding(.horizontal).padding(.top, 10)
            
            if !filteredCards.isEmpty {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle().frame(width: geometry.size.width, height: 4).foregroundColor(Theme.secondaryBackgroundColor)
                        Rectangle().frame(width: geometry.size.width * CGFloat(Double(currentIndex + 1) / Double(filteredCards.count)), height: 4).foregroundColor(Theme.primaryColor)
                            .animation(.spring(), value: currentIndex)
                    }
                }.frame(height: 4).clipShape(Capsule()).padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingCategoryPicker) { CategoryPickerView(selectedCategory: $selectedCategory, categories: deck.categories) }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if filteredCards.isEmpty {
            emptyStateView
        } else {
            ZStack {
                if currentIndex < filteredCards.count - 1 {
                    FlashcardView(card: filteredCards[currentIndex + 1], isFlipped: false, showFrench: showFrench, deck: deck, isBackground: true)
                        .scaleEffect(0.95).offset(y: 10).opacity(0.6).blur(radius: 2)
                }
                
                FlashcardView(card: filteredCards[currentIndex], isFlipped: isFlipped, showFrench: showFrench, deck: deck)
                    .id(filteredCards[currentIndex].id)
                    .offset(x: dragOffset.width, y: 0)
                    .rotationEffect(.degrees(Double(dragOffset.width / 20)))
                    .gesture(DragGesture().onChanged(handleDragChange).onEnded(handleDragEnd))
                    .onTapGesture {
                        flipCard()
                    }
            }
            .frame(height: 420).padding(.horizontal, 15)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray.fill").font(.system(size: 50)).foregroundColor(Theme.placeholderTextColor)
            Text("No cards in '\(selectedCategory)'").font(.title3).foregroundColor(Theme.secondaryTextColor)
            Text("Tap the '+' to add cards or select another category.").font(.callout).multilineTextAlignment(.center).foregroundColor(Theme.tertiaryTextColor)
        }.padding(.horizontal, 30).frame(maxHeight: .infinity)
    }
    
    private var controlsFooter: some View {
        VStack(spacing: 15) {
            HStack(spacing: 20) {
                ControlButton(icon: "arrow.backward", action: previousCard).disabled(currentIndex == 0 || filteredCards.isEmpty)
                ControlButton(icon: "arrow.up.arrow.down", action: flipCard).disabled(filteredCards.isEmpty)
                ControlButton(icon: "speaker.wave.2.fill", action: speakCurrentWord).disabled(filteredCards.isEmpty)
                if currentIndex < filteredCards.count - 1 {
                    ControlButton(icon: "arrow.forward", action: nextCard)
                } else {
                    Circle().fill(Color.clear).frame(width: 52, height: 52)
                }
            }
            .padding(.horizontal)
            Toggle("Show French Translation", isOn: $showFrench).padding(.horizontal, 30).tint(Theme.primaryColor)
            Spacer().frame(height: 10)
        }
    }
    
    // MARK: - Actions & Logic
    private func toggleAdminPanel() { HapticManager.shared.impact(style: .medium); deck.showAdminPanel.toggle() }
    private func toggleCategoryPicker() { HapticManager.shared.impact(style: .light); showingCategoryPicker.toggle() }
    private func flipCard() { guard !filteredCards.isEmpty else { return }; HapticManager.shared.impact(style: .light); withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { isFlipped.toggle() } }
    private func nextCard() { guard !filteredCards.isEmpty, currentIndex < filteredCards.count - 1 else { return }; withAnimation { currentIndex += 1 }; resetCardState() }
    private func previousCard() { guard !filteredCards.isEmpty, currentIndex > 0 else { return }; withAnimation { currentIndex -= 1 }; resetCardState() }
    private func speakCurrentWord() {
        guard !filteredCards.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: filteredCards[currentIndex].chinese)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN"); utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85
        do { try AVAudioSession.sharedInstance().setCategory(.playback); try AVAudioSession.sharedInstance().setActive(true); synthesizer.speak(utterance) }
        catch { voiceAlertMessage = "Audio error. Please check device settings."; showingVoiceAlert = true }
    }
    private func handleDragChange(_ value: DragGesture.Value) { dragOffset = value.translation }
    private func handleDragEnd(_ value: DragGesture.Value) {
        let dragThreshold: CGFloat = 50; let tapThreshold: CGFloat = 10
        withAnimation(.spring()) {
            if value.translation.width < -dragThreshold { HapticManager.shared.impact(style: .medium); nextCard() }
            else if value.translation.width > dragThreshold { HapticManager.shared.impact(style: .medium); previousCard() }
            else if abs(value.translation.width) < tapThreshold && abs(value.translation.height) < tapThreshold { flipCard() }
            dragOffset = .zero
        }
    }
    private func handleCardCountChange() { if filteredCards.isEmpty { currentIndex = 0 } else if currentIndex >= filteredCards.count { currentIndex = max(0, filteredCards.count - 1) }; isFlipped = false }
    private func resetToNewCategory() { currentIndex = 0; resetCardState() }
    private func resetCardState() { isFlipped = false; dragOffset = .zero }
    private func openAppSettings() { if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) } }
}
