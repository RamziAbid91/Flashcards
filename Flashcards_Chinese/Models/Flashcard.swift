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
    @Published var isFavorite: Bool
    @Published var seen: Bool // Track if the card has been seen
    
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
        case id, chinese, pinyin, english, french, pronunciation, category, difficulty, isFavorite, seen, exampleSentence, examplePinyin, exampleTranslation
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
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        seen = try container.decodeIfPresent(Bool.self, forKey: .seen) ?? false
        exampleSentence = try container.decode(String.self, forKey: .exampleSentence)
        examplePinyin = try container.decode(String.self, forKey: .examplePinyin)
        exampleTranslation = try container.decode(String.self, forKey: .exampleTranslation)
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
    }

    // Equatable conformance
    static func == (lhs: Flashcard, rhs: Flashcard) -> Bool {
        lhs.id == rhs.id
    }
}
