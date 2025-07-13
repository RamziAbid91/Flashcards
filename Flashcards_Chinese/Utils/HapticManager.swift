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
    
    // MARK: - Throttling for Performance
    private var lastImpactTime: TimeInterval = 0
    private let minimumInterval: TimeInterval = 0.1 // Minimum 100ms between haptics

    /// Triggers an impact feedback, like a tap.
    /// - Parameter style: The intensity of the impact (e.g., .light, .medium, .heavy).
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        // Check if haptics are enabled
        if let hapticsEnabled = UserDefaults.standard.object(forKey: "enableHaptics") as? Bool {
            guard hapticsEnabled else { return }
        }
        
        // Throttle haptic feedback to prevent excessive usage
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastImpactTime >= minimumInterval else { return }
        lastImpactTime = currentTime

        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare() // Prepare the generator for lower latency.
        generator.impactOccurred()
    }

    /// Triggers a notification feedback, like a success or error.
    /// - Parameter type: The type of notification (e.g., .success, .warning, .error).
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        // Check if haptics are enabled
        if let hapticsEnabled = UserDefaults.standard.object(forKey: "enableHaptics") as? Bool {
            guard hapticsEnabled else { return }
        }
        
        // Throttle notification feedback
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastImpactTime >= minimumInterval else { return }
        lastImpactTime = currentTime
        
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
