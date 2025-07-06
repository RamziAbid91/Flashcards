//
//  QuizFeedbackView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import SwiftUI

struct QuizFeedbackView: View {
    let isCorrect: Bool
    let correctAnswer: String
    let example: String
    let examplePinyin: String
    let exampleTranslation: String
    let action: () -> Void
    

    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Header Feedback
            HStack(spacing: 12) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(isCorrect ? Theme.accentColor : Theme.destructiveColor)
                
                Text(isCorrect ? "Correct!" : "Not Quite")
                    .font(.title.weight(.bold))
                    .foregroundColor(isCorrect ? Theme.accentColor : Theme.destructiveColor)
                Spacer()
            }
            
            // MARK: - Correct Answer Reveal
            if !isCorrect {
                VStack(alignment: .leading, spacing: 4) {
                    Text("The correct answer is:")
                        .font(.subheadline)
                        .foregroundColor(Theme.secondaryTextColor)
                    
                    Text(correctAnswer)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(Theme.textColor)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.secondaryBackgroundColor)
                .cornerRadius(12)
            }
            
            // MARK: - Example Section
            if !example.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("EXAMPLE")
                        .font(.caption.weight(.bold))
                        .foregroundColor(Theme.tertiaryTextColor)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(example)
                            .font(.body).foregroundColor(Theme.textColor)
                        Text(examplePinyin)
                            .font(.callout).foregroundColor(Theme.pinyinColor)
                        Text(exampleTranslation)
                            .font(.callout).italic().foregroundColor(Theme.tertiaryTextColor)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.secondaryBackgroundColor)
                .cornerRadius(12)
            }
            
            // MARK: - Next Button
            Button(action: {
                HapticManager.shared.impact(style: .light)
                action()
            }) {
                Text("Next Question")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(25)
        .background(Theme.cardBackgroundColor)
        .cornerRadius(18)
        .shadow(color: Theme.cardShadowColor, radius: 5, x: 0, y: 2)
    }
}

struct QuizFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Theme.backgroundColor.ignoresSafeArea()
            VStack {
                QuizFeedbackView(
                    isCorrect: true,
                    correctAnswer: "lóng",
                    example: "龙是中国文化中的神圣动物。",
                    examplePinyin: "Lóng shì zhōngguó wénhuà zhōng de shénshèng dòngwù.",
                    exampleTranslation: "The dragon is a sacred animal in Chinese culture.",
                    action: {}
                )
                
                QuizFeedbackView(
                    isCorrect: false,
                    correctAnswer: "lóng",
                    example: "龙是中国文化中的神圣动物。",
                    examplePinyin: "Lóng shì zhōngguó wénhuà zhōng de shénshèng dòngwù.",
                    exampleTranslation: "The dragon is a sacred animal in Chinese culture.",
                    action: {}
                )
            }
            .padding()
        }
        
    }
}
