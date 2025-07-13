import SwiftUI

struct SettingsView: View {
    @ObservedObject var deck: FlashcardDeck
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var showingBackupSheet = false
    @State private var exportData: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Reset Progress States
    @State private var isResettingProgress = false
    @State private var resetProgress: Double = 0.0
    @State private var showingResetConfirmation = false
    
    // User Preferences
    @AppStorage("enableHaptics") private var enableHaptics = true
    @AppStorage("autoPlayAudio") private var autoPlayAudio = false
    @AppStorage("showPinyin") private var showPinyin = true
    @AppStorage("showFrench") private var showFrench = true
    @AppStorage("quizCardCount") private var quizCardCount = 10
    @AppStorage("studyReminders") private var studyReminders = false
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    var body: some View {
        NavigationView {
            List {
                // Study Preferences
                Section("Study Preferences") {
                    Toggle("Enable Haptic Feedback", isOn: $enableHaptics)
                    Toggle("Auto-play Audio", isOn: $autoPlayAudio)
                    Toggle("Show Pinyin", isOn: $showPinyin)
                    Toggle("Show French Translation", isOn: $showFrench)
                    
                    HStack {
                        Text("Quiz Cards Count")
                        Spacer()
                        Picker("Quiz Cards", selection: $quizCardCount) {
                            ForEach([5, 10, 15, 20], id: \.self) { count in
                                Text("\(count)").tag(count)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // App Preferences
                Section("App Preferences") {
                    Toggle("Study Reminders", isOn: $studyReminders)
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                // Data Management
                Section("Data Management") {
                    Button("Export Data") {
                        exportData = DataManager.shared.exportCardsToJSON(deck.cards) ?? ""
                        showingExportSheet = true
                    }
                    
                    Button("Import Data") {
                        showingImportSheet = true
                    }
                    
                    Button("Create Backup") {
                        if let backupURL = DataManager.shared.createBackup() {
                            alertMessage = "Backup created successfully at: \(backupURL.lastPathComponent)"
                        } else {
                            alertMessage = "Failed to create backup"
                        }
                        showingAlert = true
                    }
                    
                    Button("Restore from Backup") {
                        showingBackupSheet = true
                    }
                    
                    // Reset All Progress Button
                    if isResettingProgress {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Resetting Progress...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(Int(resetProgress * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            ProgressView(value: resetProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .red))
                                .scaleEffect(y: 1.5)
                        }
                        .padding(.vertical, 8)
                    } else {
                        Button("Reset All Progress") {
                            showingResetConfirmation = true
                        }
                        .foregroundColor(.red)
                    }
                }
                
                // Statistics
                Section("Statistics") {
                    let report = DataManager.shared.generateStudyReport(deck.cards)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Cards: \(report.totalCards)")
                        Text("Favorites: \(report.favoriteCards)")
                        Text("Seen Cards: \(report.seenCards)")
                        Text("Completion: \(String(format: "%.1f", report.completionPercentage))%")
                        Text("Categories: \(report.categories.count)")
                        Text("Average Difficulty: \(String(format: "%.1f", report.averageDifficulty))")
                    }
                    .font(.caption)
                }
                
                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://yourapp.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://yourapp.com/terms")!)
                }
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showingExportSheet) {
            ShareSheet(activityItems: [exportData])
        }
        .sheet(isPresented: $showingImportSheet) {
            ImportView(deck: deck)
        }
        .sheet(isPresented: $showingBackupSheet) {
            BackupView(deck: deck)
        }
        .alert("Backup", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .alert("Reset All Progress", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                startResetProgress()
            }
        } message: {
            Text("This will reset all favorites, seen status, and learning progress. This action cannot be undone.")
        }
    }
    
    private func startResetProgress() {
        isResettingProgress = true
        resetProgress = 0.0
        
        // Calculate duration based on number of cards (4-5 seconds)
        let totalCards = deck.cards.count
        let duration: TimeInterval = 4.5 // 4.5 seconds
        let updateInterval = duration / Double(totalCards)
        
        // Animate progress bar
        for i in 0...totalCards {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * updateInterval) {
                resetProgress = Double(i) / Double(totalCards)
            }
        }
        
        // Perform the actual reset after progress animation
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            deck.resetAllProgress()
            isResettingProgress = false
            resetProgress = 0.0
            alertMessage = "All progress reset successfully. Favorites and learning progress have been cleared."
            showingAlert = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ImportView: View {
    @ObservedObject var deck: FlashcardDeck
    @Environment(\.dismiss) private var dismiss
    @State private var importText = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Paste JSON data to import cards:")
                    .font(.headline)
                    .padding()
                
                TextEditor(text: $importText)
                    .frame(height: 200)
                    .border(Color.gray, width: 1)
                    .padding()
                
                Button("Import") {
                    if let importedCards = DataManager.shared.importCardsFromJSON(importText) {
                        deck.importCards(importedCards)
                        alertMessage = "Successfully imported \(importedCards.count) cards"
                    } else {
                        alertMessage = "Failed to import cards. Please check the JSON format."
                    }
                    showingAlert = true
                }
                .disabled(importText.isEmpty)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Import Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Import", isPresented: $showingAlert) {
            Button("OK") {
                if alertMessage.contains("Successfully") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
}

struct BackupView: View {
    @ObservedObject var deck: FlashcardDeck
    @Environment(\.dismiss) private var dismiss
    @State private var backupFiles: [URL] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(backupFiles, id: \.self) { file in
                    Button(file.lastPathComponent) {
                        if DataManager.shared.restoreFromBackup(file) {
                            alertMessage = "Successfully restored from backup"
                            deck.loadCards() // Reload cards
                        } else {
                            alertMessage = "Failed to restore backup"
                        }
                        showingAlert = true
                    }
                }
            }
            .navigationTitle("Restore Backup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadBackupFiles()
            }
        }
        .alert("Restore", isPresented: $showingAlert) {
            Button("OK") {
                if alertMessage.contains("Successfully") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loadBackupFiles() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            backupFiles = files.filter { $0.lastPathComponent.contains("flashcards_backup_") }
        } catch {
            print("Error loading backup files: \(error)")
        }
    }
} 