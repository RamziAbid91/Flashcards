//
//  ControlButton.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//
import SwiftUI

struct ControlButton: View {
    let icon: String
    var action: () -> Void
   

    var body: some View {
        Button(action: {
            HapticManager.shared.impact(style: .light)
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .frame(width: 52, height: 52) // Slightly larger for better tap target
                .background(Theme.cardBackgroundColor)
                .foregroundColor(Theme.primaryColor)
                .clipShape(Circle())
                .shadow(color: Theme.cardShadowColor, radius: 4, x: 0, y: 2)
        }
    }
}

struct ControlButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            ControlButton(icon: "arrow.backward", action: {})
            ControlButton(icon: "speaker.wave.2.fill", action: {})
            ControlButton(icon: "arrow.forward", action: {})
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        
    }
}
