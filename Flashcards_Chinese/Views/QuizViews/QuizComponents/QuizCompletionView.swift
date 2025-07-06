//
//  QuizCompletionView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI

struct QuizCompletionView: View {
    @ObservedObject var deck: FlashcardDeck
   
    let action: () -> Void
    
    var scorePercentage: Double {
        guard deck.quizScore.total > 0 else { return 0 }
        return Double(deck.quizScore.correct) / Double(deck.quizScore.total)
    }
    
    var scoreColor: Color {
        switch scorePercentage {
        case 0.8...1.0: return Theme.accentColor
        case 0.5..<0.8: return .orange
        default: return Theme.destructiveColor
        }
    }
    
    var scoreMessage: String {
        switch scorePercentage {
        case 0.9...1.0: return "Excellent! 🌟"
        case 0.7..<0.9: return "Great Job! 👍"
        case 0.5..<0.7: return "Good Effort! 😊"
        default: return "Keep Practicing! 💪"
        }
    }
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Image(systemName: scorePercentage >= 0.7 ? "star.circle.fill" : (scorePercentage >= 0.5 ? "hand.thumbsup.circle.fill" : "arrow.triangle.2.circlepath.circle.fill"))
                .font(.system(size: 70))
                .foregroundColor(scoreColor)
            
            Text("Quiz Complete!")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(Theme.textColor)
            
            VStack(spacing: 10) {
                Text("Your Score:")
                    .font(.title2)
                    .foregroundColor(Theme.secondaryTextColor)
                
                ZStack {
                    Circle()
                        .stroke(lineWidth: 15)
                        .opacity(0.15)
                        .foregroundColor(scoreColor)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(scorePercentage))
                        .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                        .foregroundColor(scoreColor)
                        .rotationEffect(Angle(degrees: -90))
                        .animation(.spring(), value: scorePercentage)
                    
                    VStack {
                        Text("\(deck.quizScore.correct)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(scoreColor)
                        
                        Text("of \(deck.quizScore.total)")
                            .font(.title3)
                            .foregroundColor(Theme.secondaryTextColor)
                    }
                }
                .frame(width: 150, height: 150)
                .padding(.vertical)
                
                Text(scoreMessage)
                    .font(.title2.weight(.medium))
                    .foregroundColor(scoreColor)
            }
            
            Button(action: action) {
                Text("Start New Quiz")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.backgroundColor)
    }
}

struct QuizCompletionView_Previews: PreviewProvider {
    static var previews: some View {
        let deck = FlashcardDeck()
        deck.quizScore = QuizScore(correct: 8, total: 10)
        return QuizCompletionView(deck: deck, action: {})
        
    }
}
