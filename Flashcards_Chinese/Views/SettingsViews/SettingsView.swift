import SwiftUI

struct SettingsView: View {
    @ObservedObject var deck: FlashcardDeck
    @EnvironmentObject var themeManager: ThemeManager
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
  
    var body: some View {
        List {
            // Study Preferences
            Section("Study Preferences") {
                Toggle("Vibrations Effects", isOn: $enableHaptics)
                
            }
            
            // App Preferences
            Section("App Preferences") {
                HStack {
                    Label("Dark Mode", systemImage: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                        .foregroundColor(themeManager.currentTheme.textColor)
                    Spacer()
                    Toggle("", isOn: $themeManager.isDarkMode)
                        .labelsHidden()
                }
            }
            
            // Data Management
            Section("Data Management") {
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
                
                // Reset All Favorites Button
                Button("Reset All Favorites") {
                    showingAlert = true
                    alertMessage = "Are you sure you want to remove all favorites? This cannot be undone."
                }
                .foregroundColor(.orange)
                .alert("Reset All Favorites", isPresented: Binding(get: { alertMessage == "Are you sure you want to remove all favorites? This cannot be undone." && showingAlert }, set: { showingAlert = $0 })) {
                    Button("Cancel", role: .cancel) { }
                    Button("Reset", role: .destructive) {
                        deck.resetAllFavorites()
                        alertMessage = "All favorites have been removed."
                        showingAlert = true
                    }
                } message: {
                    Text(alertMessage)
                }
                
                // Restore Default Cards Button
                Button("Restore All Default Cards") {
                    showingAlert = true
                    alertMessage = "Are you sure you want to restore all default cards? This will replace your current cards and cannot be undone."
                }
                .foregroundColor(.blue)
                .alert("Restore All Default Cards", isPresented: Binding(get: { alertMessage == "Are you sure you want to restore all default cards? This will replace your current cards and cannot be undone." && showingAlert }, set: { showingAlert = $0 })) {
                    Button("Cancel", role: .cancel) { }
                    Button("Restore", role: .destructive) {
                        deck.resetToDefaultCards()
                        alertMessage = "All cards have been restored to default."
                        showingAlert = true
                    }
                } message: {
                    Text(alertMessage)
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
                Link("Privacy Policy", destination: URL(string: "https://docs.google.com/document/d/1JNl8pvur1u0tAu_mWhnRgb71Lp6jJbHlyzAX8pzQ9lQ/edit?tab=t.0#heading=h.l7ae5nyhmzce")!)
            }

            // Contact
            Section("Contact") {
                ContactForm()
            }

            // Copyright
            Section(footer: Text("© 2025 June & Ramzi").font(.footnote).foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .center)) {
                EmptyView()
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .themedListBackground()
        .animation(ThemeTransition.smooth, value: themeManager.isDarkMode)
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

// ContactForm view
struct ContactForm: View {
    @State private var subject = ""
    @State private var message = ""
    @State private var showMailAlert = false
    @State private var mailError = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Subject", text: $subject)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextEditor(text: $message)
                .frame(height: 80)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
            Button(action: sendMail) {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("Send Message")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(subject.isEmpty || message.isEmpty)
        }
        .alert("Mail Error", isPresented: $showMailAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(mailError)
        }
    }

    private func sendMail() {
        let email = "ramziabid@gmail.com"
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let messageEncoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "mailto:\(email)?subject=\(subjectEncoded)&body=\(messageEncoded)"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            mailError = "Unable to open mail app. Please check your device settings."
            showMailAlert = true
        }
    }
} 
