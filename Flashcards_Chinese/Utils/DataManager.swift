import Foundation
import SwiftUI

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private init() {}
    
    // MARK: - Export Functions
    func exportCardsToJSON(_ cards: [Flashcard]) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(cards)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error encoding cards: \(error)")
            return nil
        }
    }
    
    func exportCardsToCSV(_ cards: [Flashcard]) -> String {
        var csv = "Chinese,Pinyin,English,French,Category,Difficulty,IsFavorite,Seen\n"
        
        for card in cards {
            let row = "\(card.chinese),\(card.pinyin),\(card.english),\(card.french),\(card.category),\(card.difficulty),\(card.isFavorite),\(card.seen)\n"
            csv += row
        }
        
        return csv
    }
    
    // MARK: - Import Functions
    func importCardsFromJSON(_ jsonString: String) -> [Flashcard]? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let cards = try decoder.decode([Flashcard].self, from: data)
            return cards
        } catch {
            print("Error decoding cards: \(error)")
            return nil
        }
    }
    
    // MARK: - Backup Functions
    func createBackup() -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let backupURL = documentsPath.appendingPathComponent("flashcards_backup_\(Date().timeIntervalSince1970).json")
        
        guard let cardsData = try? Data(contentsOf: documentsPath.appendingPathComponent("flashcards.json")) else {
            return nil
        }
        
        do {
            try cardsData.write(to: backupURL)
            return backupURL
        } catch {
            print("Error creating backup: \(error)")
            return nil
        }
    }
    
    func restoreFromBackup(_ backupURL: URL) -> Bool {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let targetURL = documentsPath.appendingPathComponent("flashcards.json")
        
        do {
            try FileManager.default.copyItem(at: backupURL, to: targetURL)
            return true
        } catch {
            print("Error restoring backup: \(error)")
            return false
        }
    }
    
    // MARK: - Statistics
    func generateStudyReport(_ cards: [Flashcard]) -> StudyReport {
        let totalCards = cards.count
        let favoriteCards = cards.filter { $0.isFavorite }.count
        let seenCards = cards.filter { $0.seen }.count
        let unseenCards = totalCards - seenCards
        
        let categories = Set(cards.map { $0.category })
        let averageDifficulty = Double(cards.map { $0.difficulty }.reduce(0, +)) / Double(totalCards)
        
        return StudyReport(
            totalCards: totalCards,
            favoriteCards: favoriteCards,
            seenCards: seenCards,
            unseenCards: unseenCards,
            categories: Array(categories),
            averageDifficulty: averageDifficulty,
            lastUpdated: Date()
        )
    }
    
    // MARK: - Reset Functions
    func resetAllProgress(_ cards: [Flashcard]) {
        // This method will be called by the FlashcardDeck to reset all progress
        // The actual reset logic is in FlashcardDeck.resetAllProgress()
        print("Reset all progress requested for \(cards.count) cards")
    }
}

struct StudyReport {
    let totalCards: Int
    let favoriteCards: Int
    let seenCards: Int
    let unseenCards: Int
    let categories: [String]
    let averageDifficulty: Double
    let lastUpdated: Date
    
    var completionPercentage: Double {
        guard totalCards > 0 else { return 0 }
        return Double(seenCards) / Double(totalCards) * 100
    }
} 