//
//  QuizModeView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI
import AVFoundation

struct QuizModeView: View {
    @ObservedObject var deck: FlashcardDeck
    
    @State private var currentIndex = 0
    @State private var quizOptions: [String] = []
    @State private var selectedAnswer: String?
    @State private var showFeedback = false
    @State private var isCorrect = false
    @State private var quizCompleted = false
    @State private var selectedCategory: String = "All"
    @State private var quizCards: [Flashcard] = []
    @State private var showingVoiceAlert = false
    @State private var voiceAlertMessage = ""
    @State private var showingCategoryPicker = false
    @State private var isQuizComplete = false
    
    @AppStorage("showFrenchInQuiz") private var showFrench = false
    
    private let synthesizer = AVSpeechSynthesizer()
    
    var totalQuestions: Int { quizCards.count }
    private var filteredCardsForQuiz: [Flashcard] {
        if selectedCategory != "All" {
            return deck.cards.filter { $0.category == selectedCategory }
        }
        return deck.cards
    }
    
    init(deck: FlashcardDeck) {
        self.deck = deck
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // MARK: - Progress Bar
                HStack {
                    Text("\(currentIndex + 1)/\(quizCards.count)")
                        .font(.headline)
                        .foregroundColor(Theme.textColor)
                    Spacer()
                }
                .padding(.horizontal)
                
                // MARK: - Quiz Card
                if !quizCards.isEmpty {
                    QuizCardView(
                        card: quizCards[currentIndex],
                        options: quizOptions,
                        selectedAnswer: $selectedAnswer,
                        showFeedback: showFeedback,
                        isCorrect: isCorrect,
                        isAskingPinyin: currentIndex % 2 == 0,
                        action: checkAnswer
                    )
                    .padding(.horizontal)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.9))
                            .animation(.spring(response: 0.4, dampingFraction: 0.7)),
                        removal: .opacity.animation(.easeOut(duration: 0.2))
                    ))
                }
                
                Spacer()
            }
            .padding(.top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Quiz Mode")
                    .font(.headline)
                    .foregroundColor(Theme.textColor)
            }
        }
        .onAppear {
            startNewQuiz()
        }
        .sheet(isPresented: $showingCategoryPicker) {
            CategoryPickerView(selectedCategory: $selectedCategory, categories: deck.categories)
        }
        .sheet(isPresented: $isQuizComplete) {
            QuizCompletionView(deck: deck, action: {
                isQuizComplete = false
                startNewQuiz()
            })
        }
        .alert("Voice Error", isPresented: $showingVoiceAlert) {
            Button("OK") {}
            Button("Settings") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
        } message: { Text(voiceAlertMessage) }
    }
    
    // MARK: - Subviews
    
    private var categoryHeader: some View {
        HStack {
            Text("Category:")
                .font(.subheadline)
                .foregroundColor(Theme.secondaryTextColor)
            
            Button {
                HapticManager.shared.impact(style: .light)
                showingCategoryPicker.toggle()
            } label: {
                HStack {
                    Text(selectedCategory)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(Theme.primaryColor)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(Theme.primaryColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Theme.secondaryBackgroundColor)
                .cornerRadius(8)
            }
            
            Spacer()
            
            if !quizCompleted && totalQuestions > 0 {
                Text("Question \(currentIndex + 1) of \(totalQuestions)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(Theme.secondaryTextColor)
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .onChange(of: selectedCategory) { _ in
            resetQuizAndStart()
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Image(systemName: "questionmark.folder.fill")
                .font(.system(size: 50))
                .foregroundColor(Theme.placeholderTextColor)
            Text("No Cards for Quiz")
                .font(.title3)
                .foregroundColor(Theme.secondaryTextColor)
                .padding(.top, 8)
            Text("Add cards to '\(selectedCategory)' or pick another.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(Theme.placeholderTextColor)
            Spacer()
        }
        .padding()
    }
    
    private var quizContent: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack {
                Text("\(currentIndex + 1) of \(filteredCardsForQuiz.count)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(Theme.secondaryTextColor)
                
                Spacer()
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Theme.secondaryBackgroundColor)
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(Theme.primaryColor)
                            .frame(width: geometry.size.width * CGFloat(currentIndex + 1) / CGFloat(filteredCardsForQuiz.count), height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // Quiz content
            ScrollView {
                VStack(spacing: 20) {
                    pronunciationButton
                        .transition(.scale.combined(with: .opacity))
                    
                    QuizCardView(
                        card: quizCards[currentIndex],
                        options: quizOptions,
                        selectedAnswer: $selectedAnswer,
                        showFeedback: showFeedback,
                        isCorrect: isCorrect,
                        isAskingPinyin: currentIndex % 2 == 0,
                        action: checkAnswer
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.9))
                            .animation(.spring(response: 0.4, dampingFraction: 0.7)),
                        removal: .opacity.animation(.easeOut(duration: 0.2))
                    ))
                    
                    if showFeedback {
                        QuizFeedbackView(
                            isCorrect: isCorrect,
                            correctAnswer: quizCards[currentIndex].pinyin,
                            example: quizCards[currentIndex].exampleSentence,
                            examplePinyin: quizCards[currentIndex].examplePinyin,
                            exampleTranslation: quizCards[currentIndex].exampleTranslation,
                            action: nextQuestion
                        )
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.9))
                                .animation(.spring(response: 0.4, dampingFraction: 0.7)),
                            removal: .opacity.animation(.easeOut(duration: 0.2))
                        ))
                    }
                }
                .padding()
            }
            
            // Controls
            controlsFooter
        }
    }
    
    private var pronunciationButton: some View {
        Button(action: speakCurrentWord) {
            HStack {
                Image(systemName: "speaker.wave.2.fill")
                Text("Play Pronunciation")
            }
            .font(.headline.weight(.medium))
            .padding(.vertical, 10)
            .padding(.horizontal, 18)
            .background(Theme.primaryColor.opacity(0.1))
            .foregroundColor(Theme.primaryColor)
            .cornerRadius(10)
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showFeedback)
        }
        .padding(.top, 10)
    }
    
    private var controlsFooter: some View {
        HStack(spacing: 20) {
            // Previous button
            Button(action: previousQuestion) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Theme.primaryColor)
                    .frame(width: 44, height: 44)
                    .background(Theme.cardBackgroundColor)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            .disabled(currentIndex == 0)
            .opacity(currentIndex == 0 ? 0.5 : 1)
            
            // Voice button
            Button(action: speakCurrentWord) {
                Image(systemName: "speaker.wave.2")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Theme.primaryColor)
                    .frame(width: 44, height: 44)
                    .background(Theme.cardBackgroundColor)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            
            // Next button
            Button(action: nextQuestion) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Theme.primaryColor)
                    .frame(width: 44, height: 44)
                    .background(Theme.cardBackgroundColor)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            .disabled(currentIndex == filteredCardsForQuiz.count - 1)
            .opacity(currentIndex == filteredCardsForQuiz.count - 1 ? 0.5 : 1)
        }
        .padding(.vertical, 20)
        .padding(.horizontal)
        .background(Theme.backgroundColor)
    }
    
    // MARK: - Quiz Logic
    
    private func startNewQuiz() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            let seen = deck.seenCards
            let basic = deck.basicWordsCards.filter { basicCard in
                !seen.contains { seenCard in seenCard.id == basicCard.id }
            }
            var quizSet: [Flashcard] = []
            if seen.count >= 10 {
                quizSet = Array(seen.shuffled().prefix(10))
            } else {
                quizSet = seen.shuffled()
                let needed = 10 - quizSet.count
                if needed > 0 {
                    quizSet += Array(basic.shuffled().prefix(needed))
                }
            }
            quizCards = quizSet
            currentIndex = 0
            deck.resetQuiz()
            quizCompleted = false
            selectedAnswer = nil
            showFeedback = false
            if !quizCards.isEmpty {
                generateOptions()
            }
        }
    }
    
    private func generateOptions() {
        var options: [String]
        if currentIndex % 2 == 0 {
            // Asking for pinyin
            options = Array(Set(deck.cards.compactMap { $0.pinyin }))
                .filter { $0 != quizCards[currentIndex].pinyin }
                .shuffled()
                .prefix(3)
                .map { $0 }
            options.append(quizCards[currentIndex].pinyin)
        } else {
            // Asking for meaning
            options = Array(Set(deck.cards.compactMap { $0.english }))
                .filter { $0 != quizCards[currentIndex].english }
                .shuffled()
                .prefix(3)
                .map { $0 }
            options.append(quizCards[currentIndex].english)
        }
        quizOptions = options.shuffled()
    }
    
    private func checkAnswer() {
        let isAskingPinyin = currentIndex % 2 == 0
        let correctAnswer = isAskingPinyin ? quizCards[currentIndex].pinyin : quizCards[currentIndex].english
        isCorrect = selectedAnswer == correctAnswer
        
        if isCorrect {
            deck.quizScore.correct += 1
        }
        deck.quizScore.total += 1
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showFeedback = true
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(isCorrect ? .success : .error)
        
        // Move to next question after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                if currentIndex < quizCards.count - 1 {
                    currentIndex += 1
                    selectedAnswer = nil
                    showFeedback = false
                    generateOptions()
                } else {
                    isQuizComplete = true
                }
            }
        }
    }
    
    private func nextQuestion() {
        if currentIndex < quizCards.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                currentIndex += 1
                selectedAnswer = nil
                showFeedback = false
                generateOptions()
            }
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                quizCompleted = true
            }
        }
    }
    
    private func previousQuestion() {
        if currentIndex > 0 {
            withAnimation {
                currentIndex -= 1
                selectedAnswer = nil
                generateOptions()
            }
        }
    }
    
    private func resetQuizAndStart() {
        // Automatically enable French translation for Quebecois category
        if selectedCategory.lowercased() == "quebecois" {
            showFrench = true
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            startNewQuiz()
        }
    }
    
    private func speakCurrentWord() {
        guard !quizCards.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: quizCards[currentIndex].chinese)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            synthesizer.speak(utterance)
        } catch {
            voiceAlertMessage = "Audio error. Please check device settings."
            showingVoiceAlert = true
        }
    }
}

// MARK: - Preview
struct QuizModeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            QuizModeView(deck: FlashcardDeck())
        }
    }
}
