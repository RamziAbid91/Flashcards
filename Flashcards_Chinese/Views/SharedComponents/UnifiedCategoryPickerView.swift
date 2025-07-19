import SwiftUI

struct UnifiedCategoryPickerView: View {
    @Binding var selectedCategory: String
    let categories: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedIndex: Int = 0
    
    var filteredCategories: [String] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(filteredCategories.enumerated()), id: \.element) { index, category in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                            selectedIndex = index
                        }
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        // Dismiss after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: iconName(for: category))
                                .font(.system(size: 20))
                                .foregroundColor(category == selectedCategory ? Theme.primaryColor : Theme.secondaryTextColor)
                                .frame(width: 32)
                            Text(category)
                                .font(.system(size: 17, weight: category == selectedCategory ? .semibold : .regular))
                                .foregroundColor(category == selectedCategory ? Theme.textColor : Theme.secondaryTextColor)
                            Spacer()
                            if category == selectedCategory {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Theme.primaryColor)
                                    .font(.system(size: 20))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Search categories")
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.primaryColor)
                }
            }
        }
    }
    
    private func iconName(for category: String) -> String {
        switch category.lowercased() {
        case "all":
            return "square.grid.3x3.fill"
        case "favorites":
            return "heart.fill"
        case "greetings":
            return "hand.wave.fill"
        case "numbers":
            return "number.circle.fill"
        case "colors":
            return "paintpalette.fill"
        case "food":
            return "fork.knife.circle.fill"
        case "animals":
            return "pawprint.fill"
        case "family":
            return "person.3.fill"
        case "time":
            return "clock.fill"
        case "weather":
            return "cloud.sun.fill"
        case "travel":
            return "airplane.circle.fill"
        case "basic words":
            return "text.bubble.fill"
        case "q/s/c/sh/zh words":
            return "character.bubble.fill"
        case "hsk 1":
            return "book.fill"
        case "social media slang":
            return "message.circle.fill"
        default:
            return "folder.fill"
        }
    }
}

struct UnifiedCategoryPickerView_Previews: PreviewProvider {
    static var previews: some View {
        UnifiedCategoryPickerView(
            selectedCategory: .constant("All"),
            categories: ["All", "Favorites", "Greetings", "Numbers", "Colors", "Food", "Animals", "Family", "Time", "Weather", "Travel", "Basic Words", "Q/S/C/SH/ZH Words", "HSK 1", "Social Media Slang"]
        )
    }
} 