//
//  Flashcard.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-05-22.
//

import Foundation

// The model is now a class conforming to ObservableObject
class Flashcard: ObservableObject, Identifiable, Codable, Equatable {
    let id: UUID
    
    // Properties that can change and should update the UI are marked @Published
    @Published var isFavorite: Bool = false
    @Published var seen: Bool = false
    
    // MARK: - Spaced Repetition Properties
    @Published var reviewCount: Int = 0
    @Published var lastReviewed: Date?
    @Published var nextReviewDate: Date?
    @Published var difficultyLevel: Int = 1 // 1-5 scale
    @Published var streakCount: Int = 0 // Consecutive correct answers
    
    // Other properties that don't change during a session
    let chinese: String
    let pinyin: String
    let english: String
    let french: String
    let pronunciation: String
    let category: String
    let difficulty: Int
    let exampleSentence: String
    let examplePinyin: String
    let exampleTranslation: String

    // Custom initializer to set all properties
    init(id: UUID = UUID(), chinese: String, pinyin: String, english: String, french: String, pronunciation: String, category: String, difficulty: Int, isFavorite: Bool = false, seen: Bool = false, exampleSentence: String, examplePinyin: String, exampleTranslation: String) {
        self.id = id
        self.chinese = chinese
        self.pinyin = pinyin
        self.english = english
        self.french = french
        self.pronunciation = pronunciation
        self.category = category
        self.difficulty = difficulty
        self.isFavorite = isFavorite
        self.seen = seen
        self.exampleSentence = exampleSentence
        self.examplePinyin = examplePinyin
        self.exampleTranslation = exampleTranslation
    }

    // Since this is a class, we need to handle encoding and decoding manually
    // to conform to the Codable protocol.
    
    enum CodingKeys: String, CodingKey {
        case id, chinese, pinyin, english, french, pronunciation, category, difficulty, isFavorite, seen, exampleSentence, examplePinyin, exampleTranslation, reviewCount, lastReviewed, nextReviewDate, difficultyLevel, streakCount
    }
    
    // Custom decoder required for Codable conformance
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        chinese = try container.decode(String.self, forKey: .chinese)
        pinyin = try container.decode(String.self, forKey: .pinyin)
        english = try container.decode(String.self, forKey: .english)
        french = try container.decode(String.self, forKey: .french)
        pronunciation = try container.decode(String.self, forKey: .pronunciation)
        category = try container.decode(String.self, forKey: .category)
        difficulty = try container.decode(Int.self, forKey: .difficulty)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        seen = try container.decodeIfPresent(Bool.self, forKey: .seen) ?? false
        exampleSentence = try container.decodeIfPresent(String.self, forKey: .exampleSentence) ?? ""
        examplePinyin = try container.decodeIfPresent(String.self, forKey: .examplePinyin) ?? ""
        exampleTranslation = try container.decodeIfPresent(String.self, forKey: .exampleTranslation) ?? ""
        
        // Spaced repetition properties
        reviewCount = try container.decodeIfPresent(Int.self, forKey: .reviewCount) ?? 0
        lastReviewed = try container.decodeIfPresent(Date.self, forKey: .lastReviewed)
        nextReviewDate = try container.decodeIfPresent(Date.self, forKey: .nextReviewDate)
        difficultyLevel = try container.decodeIfPresent(Int.self, forKey: .difficultyLevel) ?? 1
        streakCount = try container.decodeIfPresent(Int.self, forKey: .streakCount) ?? 0
    }
    
    // Custom encoder required for Codable conformance
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(chinese, forKey: .chinese)
        try container.encode(pinyin, forKey: .pinyin)
        try container.encode(english, forKey: .english)
        try container.encode(french, forKey: .french)
        try container.encode(pronunciation, forKey: .pronunciation)
        try container.encode(category, forKey: .category)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(seen, forKey: .seen)
        try container.encode(exampleSentence, forKey: .exampleSentence)
        try container.encode(examplePinyin, forKey: .examplePinyin)
        try container.encode(exampleTranslation, forKey: .exampleTranslation)
        try container.encode(reviewCount, forKey: .reviewCount)
        try container.encode(lastReviewed, forKey: .lastReviewed)
        try container.encode(nextReviewDate, forKey: .nextReviewDate)
        try container.encode(difficultyLevel, forKey: .difficultyLevel)
        try container.encode(streakCount, forKey: .streakCount)
    }

    // Equatable conformance
    static func == (lhs: Flashcard, rhs: Flashcard) -> Bool {
        lhs.id == rhs.id
    }
}
