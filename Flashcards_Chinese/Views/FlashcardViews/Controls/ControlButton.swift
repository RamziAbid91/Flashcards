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
    var showFrench: Bool = true
   

    var body: some View {
        Button(action: {
            HapticManager.shared.impact(style: .light)
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .frame(width: 52, height: 52)
                .background(Theme.cardBackgroundColor)
                .foregroundColor(Theme.primaryColor)
                .clipShape(Circle())
                .shadow(color: Theme.cardShadowColor, radius: 4, x: 0, y: 2)
        }
    }
}

struct ControlButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                ControlButton(icon: "arrow.backward", action: {}, showFrench: true)
                ControlButton(icon: "speaker.wave.2.fill", action: {}, showFrench: true)
                ControlButton(icon: "arrow.forward", action: {}, showFrench: true)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            
            HStack(spacing: 16) {
                ControlButton(icon: "arrow.backward", action: {}, showFrench: false)
                ControlButton(icon: "speaker.wave.2.fill", action: {}, showFrench: false)
                ControlButton(icon: "arrow.forward", action: {}, showFrench: false)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
        }
    }
}
