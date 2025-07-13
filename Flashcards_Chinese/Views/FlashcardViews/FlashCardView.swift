//
//  FlashcardView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI
import AVFoundation

struct FlashcardView: View {
    @ObservedObject var card: Flashcard // Now observes the card directly
    let isFlipped: Bool
    let showFrench: Bool
    @ObservedObject var deck: FlashcardDeck // Still needed for the favorite action
    var isBackground: Bool = false
    
    // MARK: - Lazy Properties for Performance
    private var synthesizer: AVSpeechSynthesizer {
        // Lazy initialization of synthesizer
        let synth = AVSpeechSynthesizer()
        return synth
    }
   
    var body: some View {
        ZStack {
            FrontView(card: card, deck: deck, showFrench: showFrench)
                .modifier(CardSideModifier(isFront: true, isFlipped: isFlipped, isBackground: isBackground))
            
            BackView(card: card, deck: deck)
                .modifier(CardSideModifier(isFront: false, isFlipped: isFlipped, isBackground: isBackground))
        }
        .frame(minHeight: 400, maxHeight: 500)
        .onAppear {
            deck.markCardSeen(card)
        }
    }
}

// MARK: - Front View
private struct FrontView: View {
    @ObservedObject var card: Flashcard
    @ObservedObject var deck: FlashcardDeck
    let showFrench: Bool
   
    
    var body: some View {
        VStack(spacing: 0) {
            favoriteButton
                .padding(.bottom, 10)
            
            ScrollView {
                VStack(spacing: 8) {
                    mainContent
                    translationSection
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.vertical, 16)
    }
    
    private var favoriteButton: some View {
        HStack {
            Spacer()
            Button(action: toggleFavorite) {
                Image(systemName: card.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 22))
                    .foregroundColor(card.isFavorite ? Theme.favoriteColor : Theme.tertiaryTextColor.opacity(0.5))
                    .scaleEffect(card.isFavorite ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.4), value: card.isFavorite)
            }
        }
        .padding(.horizontal)
    }
    
    private var mainContent: some View {
        VStack(spacing: 8) {
            Text(card.chinese)
                .font(.system(size: 65, weight: .bold, design: .rounded))
                .foregroundColor(Theme.textColor)
                .lineLimit(nil)
                .minimumScaleFactor(0.6)
                .fixedSize(horizontal: false, vertical: true)
            Text(card.pinyin)
                .font(.system(size: 26, design: .rounded))
                .foregroundColor(Theme.pinyinColor)
                .lineLimit(nil)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
            Text("(\(card.pronunciation))")
                .font(.system(size: 20, design: .rounded))
                .italic()
                .foregroundColor(Theme.tertiaryTextColor)
                .lineLimit(nil)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
        }.multilineTextAlignment(.center)
    }
    
    private var translationSection: some View {
        VStack(spacing: 10) {
            TranslationBox(language: "English", meaning: card.english)
            if showFrench && !card.french.isEmpty { 
                TranslationBox(language: "French", meaning: card.french) 
            }
            Text("Tap to see example")
                .font(.caption2)
                .foregroundColor(Theme.placeholderTextColor)
                .padding(.top, 5)
        }
    }
    
    private func toggleFavorite() { deck.toggleFavorite(card: card); HapticManager.shared.impact(style: .light) }
}

// MARK: - Back View
private struct BackView: View {
    @ObservedObject var card: Flashcard
    @ObservedObject var deck: FlashcardDeck
    
    @State private var showingVoiceAlert = false
    @State private var voiceAlertMessage = ""
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack(spacing: 0) {
            favoriteButton
                .padding(.bottom, 10)
            
            ScrollView {
                VStack(spacing: 12) {
                    exampleContent
                    playButton
                    Text("Tap to flip back").font(.caption2).foregroundColor(Theme.placeholderTextColor).padding(.top, 10)
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.vertical)
        .alert("Voice Error", isPresented: $showingVoiceAlert) { Button("OK") {}; Button("Settings") { if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) } } } message: { Text(voiceAlertMessage) }
    }
    
    private var favoriteButton: some View {
        HStack {
            Spacer()
            Button(action: toggleFavorite) {
                Image(systemName: card.isFavorite ? "heart.fill" : "heart").font(.system(size: 22))
                    .foregroundColor(card.isFavorite ? Theme.favoriteColor : Theme.tertiaryTextColor.opacity(0.5))
                    .scaleEffect(card.isFavorite ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.4), value: card.isFavorite)
            }
        }
        .padding(.horizontal)
    }
    
    private var exampleContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EXAMPLE USAGE").font(.caption.weight(.bold)).foregroundColor(Theme.tertiaryTextColor).frame(maxWidth: .infinity, alignment: .center)
            VStack(alignment: .center, spacing: 6) {
                Text(card.exampleSentence)
                    .font(.title3.weight(.medium))
                    .lineLimit(nil)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
                Text(card.examplePinyin)
                    .font(.body)
                    .foregroundColor(Theme.pinyinColor)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
                Divider().padding(.vertical, 4)
                Text(card.exampleTranslation)
                    .font(.body)
                    .italic()
                    .lineLimit(nil)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.center).foregroundColor(Theme.textColor)
        }.padding().background(Theme.secondaryBackgroundColor).cornerRadius(12)
    }
    
    private var playButton: some View {
        Button(action: speakExample) {
            Label("Play Example", systemImage: "speaker.wave.2.fill")
                .font(.headline.weight(.medium)).padding(.vertical, 12).padding(.horizontal, 20)
                .background(Theme.primaryColor.opacity(0.1)).foregroundColor(Theme.primaryColor).cornerRadius(12)
        }

    }
    
    private func toggleFavorite() { deck.toggleFavorite(card: card); HapticManager.shared.impact(style: .light) }
    private func speakExample() {
        let utterance = AVSpeechUtterance(string: card.exampleSentence)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN"); utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85
        do { try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default); try AVAudioSession.sharedInstance().setActive(true); synthesizer.speak(utterance) }
        catch { voiceAlertMessage = "Could not play audio example."; showingVoiceAlert = true }
    }
}

// MARK: - Reusable Helper Views
private struct TranslationBox: View {
    let language: String; let meaning: String
   
    var body: some View {
        VStack(spacing: 2) {
            Text(language).font(.caption.weight(.semibold)).foregroundColor(Theme.tertiaryTextColor)
            Text(meaning)
                .font(.title2.weight(.regular))
                .foregroundColor(Theme.secondaryTextColor)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8).padding(.horizontal).frame(maxWidth: .infinity)
        .background(Theme.secondaryBackgroundColor).cornerRadius(10)
        .shadow(color: Theme.cardShadowColor.opacity(0.5), radius: 1, y: 1)
    }
}

private struct CardSideModifier: ViewModifier {
    let isFront: Bool; let isFlipped: Bool; let isBackground: Bool
  
    func body(content: Content) -> some View {
        content
            .background(Theme.cardBackgroundColor)
            .cornerRadius(16)
            .shadow(color: Theme.cardShadowColor, radius: isBackground ? 2 : 8, x: 0, y: isBackground ? 1 : 4)
            .rotation3DEffect(.degrees(isFlipped ? (isFront ? -180 : 0) : (isFront ? 0 : 180)), axis: (x: 0, y: 1, z: 0))
            .opacity(isFlipped ? (isFront ? 0 : 1) : (isFront ? 1 : 0))
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isFlipped)
    }
}

// MARK: - Preview
struct FlashcardView_Previews: PreviewProvider {
    static var previews: some View {
        let deck = FlashcardDeck()
        let card = deck.cards.first!
        
        ZStack {
            Theme.backgroundColor.ignoresSafeArea()
            VStack {
                Text("Front View").font(.headline)
                FlashcardView(card: card, isFlipped: false, showFrench: true, deck: deck)
                Text("Back View").font(.headline).padding(.top)
                FlashcardView(card: card, isFlipped: true, showFrench: true, deck: deck)
            }.padding()
        }
    }
}

