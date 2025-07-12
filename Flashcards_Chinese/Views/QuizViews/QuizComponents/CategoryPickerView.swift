import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategory: String
    let categories: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(categories.enumerated()), id: \.element) { index, category in
                        CategoryRow(
                            category: category,
                            isSelected: category == selectedCategory,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedCategory = category
                                    selectedIndex = index
                                }
                                // Add haptic feedback
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                
                                // Dismiss after a short delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    dismiss()
                                }
                            }
                        )
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                }
                .padding(.vertical, 8)
            }
            .background(Theme.backgroundColor)
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
}

struct CategoryRow: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Category icon
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Theme.primaryColor : Theme.secondaryTextColor)
                    .frame(width: 32)
                
                // Category name
                Text(category)
                    .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Theme.textColor : Theme.secondaryTextColor)
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.primaryColor)
                        .font(.system(size: 20))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Theme.primaryColor.opacity(0.1) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 16)
    }
    
    private var iconName: String {
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

#Preview {
    CategoryPickerView(
        selectedCategory: .constant("All"),
        categories: ["All", "Favorites", "Greetings", "Numbers", "Colors", "Food", "Animals", "Family", "Time", "Weather", "Travel", "Basic Words", "Q/S/C/SH/ZH Words", "HSK 1", "Social Media Slang"]
    )
} 