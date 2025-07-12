//
//  QuizCardView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI
import AVFoundation

struct QuizCardView: View {
    let card: Flashcard
    let options: [String]
    @Binding var selectedAnswer: String?
    let showFeedback: Bool
    let isCorrect: Bool
    let isAskingPinyin: Bool
    let action: () -> Void
    
    @State private var showingVoiceAlert = false
    @State private var voiceAlertMessage = ""
    private let synthesizer = AVSpeechSynthesizer()
    
    private var questionFontSize: CGFloat {
        let length = isAskingPinyin ? card.english.count : card.chinese.count
        switch length {
        case 0...15: return 40
        case 16...25: return 35
        case 26...35: return 30
        case 36...45: return 25
        case 46...55: return 20
        default: return 18
        }
    }
    
    private var chineseFontSize: CGFloat {
        let length = card.chinese.count
        switch length {
        case 0...2: return 50
        case 3...4: return 42
        case 5...6: return 35
        case 7...8: return 30
        case 9...10: return 25
        default: return 20
        }
    }
    
    private var pinyinFontSize: CGFloat {
        let length = card.pinyin.count
        switch length {
        case 0...10: return 40
        case 11...15: return 35
        case 16...20: return 30
        case 21...25: return 25
        default: return 20
        }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // MARK: - Question Area
            VStack(spacing: 8) {
                if isAskingPinyin {
                    Text(card.english)
                        .font(.system(size: questionFontSize, weight: .bold, design: .rounded))
                        .transition(.scale.combined(with: .opacity))
                        .minimumScaleFactor(0.8)
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                    Text(card.chinese)
                        .font(.system(size: chineseFontSize, weight: .bold, design: .rounded))
                        .transition(.scale.combined(with: .opacity))
                        .minimumScaleFactor(0.7)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    Text("What is the pinyin?")
                        .font(.headline)
                        .foregroundColor(Theme.secondaryTextColor)
                        .padding(.top, 10)
                        .transition(.opacity)
                } else {
                    Text(card.chinese)
                        .font(.system(size: chineseFontSize, weight: .bold, design: .rounded))
                        .transition(.scale.combined(with: .opacity))
                        .minimumScaleFactor(0.7)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    Text(card.pinyin)
                        .font(.system(size: pinyinFontSize, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.secondaryTextColor)
                        .transition(.scale.combined(with: .opacity))
                        .minimumScaleFactor(0.8)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    Text("What does this mean?")
                        .font(.headline)
                        .foregroundColor(Theme.secondaryTextColor)
                        .padding(.top, 10)
                        .transition(.opacity)
                }
                
                // Sound button
                Button(action: speakQuestion) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundColor(Theme.primaryColor)
                        .padding(8)
                        .background(Theme.primaryColor.opacity(0.1))
                        .clipShape(Circle())
                }
                .padding(.top, 5)
            }
            .foregroundColor(Theme.textColor)
            .multilineTextAlignment(.center)
            .padding(.bottom, 10)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: card.id)
            
            // MARK: - Answer Options
            VStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    QuizOptionButton(
                        option: option,
                        isSelected: selectedAnswer == option,
                        isCorrect: (isAskingPinyin ? option == card.pinyin : option == card.english) && showFeedback,
                        showFeedback: showFeedback,
                        action: {
                            if !showFeedback {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedAnswer = option
                                    action()
                                }
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.9))
                            .animation(.spring(response: 0.4, dampingFraction: 0.7)),
                        removal: .opacity.animation(.easeOut(duration: 0.2))
                    ))
                }
            }
        }
        .padding(20)
        .background(Theme.cardBackgroundColor)
        .cornerRadius(18)
        .shadow(color: Theme.cardShadowColor, radius: 5, x: 0, y: 2)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: options)
        .alert("Voice Error", isPresented: $showingVoiceAlert) {
            Button("OK") {}
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text(voiceAlertMessage)
        }
    }
    
    private func speakQuestion() {
        let utterance = AVSpeechUtterance(string: isAskingPinyin ? card.chinese : card.chinese)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            synthesizer.speak(utterance)
        } catch {
            voiceAlertMessage = "Could not play audio."
            showingVoiceAlert = true
        }
    }
}

// MARK: - Professional Answer Button
private struct QuizOptionButton: View {
    let option: String
    let isSelected: Bool
    let isCorrect: Bool
    let showFeedback: Bool
    let action: () -> Void
    
    private var state: ButtonState {
        if !showFeedback {
            return isSelected ? .selected : .normal
        } else {
            return isCorrect ? .correct : (isSelected ? .incorrect : .disabled)
        }
    }
    
    private enum ButtonState {
        case normal, selected, correct, incorrect, disabled
    }
    
    private var backgroundColor: Color {
        switch state {
        case .correct: return Theme.accentColor.opacity(0.15)
        case .incorrect: return Theme.destructiveColor.opacity(0.15)
        case .selected: return Theme.primaryColor.opacity(0.1)
        case .normal: return Theme.secondaryBackgroundColor
        case .disabled: return Theme.secondaryBackgroundColor.opacity(0.7)
        }
    }
    
    private var borderColor: Color {
        switch state {
        case .correct: return Theme.accentColor
        case .incorrect: return Theme.destructiveColor
        case .selected: return Theme.primaryColor
        case .normal, .disabled: return Theme.cardBorderColor.opacity(0.5)
        }
    }
    
    private var textColor: Color {
        switch state {
        case .correct: return Theme.accentColor
        case .incorrect: return Theme.destructiveColor
        case .selected: return Theme.primaryColor
        case .disabled: return Theme.tertiaryTextColor.opacity(0.5)
        case .normal: return Theme.textColor
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(option)
                    .font(.headline)
                    .fontWeight(.medium)
                    .minimumScaleFactor(0.8)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if showFeedback {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.accentColor)
                    } else if isSelected && !isCorrect {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.destructiveColor)
                    }
                }
            }
            .padding()
            .foregroundColor(textColor)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: state == .normal || state == .disabled ? 1 : 2)
            )
        }
        .disabled(showFeedback)
        .animation(.easeInOut(duration: 0.2), value: state)
    }
}

#Preview {
    QuizCardView(
        card: Flashcard(
            chinese: "你好",
            pinyin: "nǐ hǎo",
            english: "Hello",
            french: "Bonjour",
            pronunciation: "nee hao",
            category: "Greetings",
            difficulty: 1,
            exampleSentence: "你好，很高兴认识你。",
            examplePinyin: "nǐ hǎo, hěn gāo xìng rèn shi nǐ",
            exampleTranslation: "Hello, nice to meet you."
            
        ),
        options: ["To go", "To eat", "To sleep", "To read"],
        selectedAnswer: .constant("To eat"),
        showFeedback: true,
        isCorrect: false,
        isAskingPinyin: true,
        action: {}
    )
}

