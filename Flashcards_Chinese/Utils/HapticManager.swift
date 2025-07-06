//
//  HapticManager.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//

import UIKit

final class HapticManager {
    // A singleton instance to ensure we use the same manager throughout the app.
    static let shared = HapticManager()
    
    // A private initializer prevents others from creating new instances.
    private init() {}

    /// Triggers an impact feedback, like a tap.
    /// - Parameter style: The intensity of the impact (e.g., .light, .medium, .heavy).
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        // First, check if the user has enabled haptics in the settings.
        // If the key doesn't exist yet, `object(forKey:)` is nil, and we proceed,
        // which means haptics are ON by default.
        if let hapticsEnabled = UserDefaults.standard.object(forKey: "enableHaptics") as? Bool {
            guard hapticsEnabled else { return }
        }

        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare() // Prepare the generator for lower latency.
        generator.impactOccurred()
    }

    /// Triggers a notification feedback, like a success or error.
    /// - Parameter type: The type of notification (e.g., .success, .warning, .error).
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        // First, check if the user has enabled haptics in the settings.
        if let hapticsEnabled = UserDefaults.standard.object(forKey: "enableHaptics") as? Bool {
            guard hapticsEnabled else { return }
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
