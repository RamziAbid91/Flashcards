import SwiftUI

struct QuizCompleteView: View {
    @ObservedObject var deck: FlashcardDeck
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    private var score: Double {
        guard deck.quizScore.total > 0 else { return 0 }
        return Double(deck.quizScore.correct) / Double(deck.quizScore.total)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // Score Circle
                ZStack {
                    Circle()
                        .stroke(Theme.accentColor.opacity(0.2), lineWidth: 20)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: score)
                        .stroke(Theme.accentColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: score)
                    
                    VStack(spacing: 5) {
                        Text("\(Int(score * 100))%")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                        Text("\(deck.quizScore.correct)/\(deck.quizScore.total)")
                            .font(.headline)
                            .foregroundColor(Theme.secondaryTextColor)
                    }
                }
                
                // Message
                Text(scoreMessage)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.textColor)
                    .padding(.horizontal)
                
                // Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        deck.resetQuiz()
                        dismiss()
                        onDismiss()
                    }) {
                        Text("Try Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accentColor)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Back to Deck")
                            .font(.headline)
                            .foregroundColor(Theme.accentColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accentColor.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Quiz Complete")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var scoreMessage: String {
        switch score {
        case 0.9...1.0:
            return "Excellent! You're a Chinese master!"
        case 0.7..<0.9:
            return "Great job! Keep practicing!"
        case 0.5..<0.7:
            return "Good effort! You're making progress!"
        default:
            return "Keep practicing! You'll get better!"
        }
    }
}

#Preview {
    QuizCompleteView(
        deck: FlashcardDeck(),
        onDismiss: {}
    )
} 