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
                    .foregroundColor(Theme.accentColor)
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
                    .foregroundColor(isSelected ? Theme.accentColor : Theme.secondaryTextColor)
                    .frame(width: 32)
                
                // Category name
                Text(category)
                    .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Theme.textColor : Theme.secondaryTextColor)
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.accentColor)
                        .font(.system(size: 20))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Theme.accentColor.opacity(0.1) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 16)
    }
    
    private var iconName: String {
        switch category.lowercased() {
        case "all":
            return "square.grid.2x2"
        case "greetings":
            return "hand.wave"
        case "numbers":
            return "number"
        case "colors":
            return "paintpalette"
        case "food":
            return "fork.knife"
        case "animals":
            return "pawprint"
        case "family":
            return "person.2"
        case "time":
            return "clock"
        case "weather":
            return "cloud.sun"
        case "travel":
            return "airplane"
        default:
            return "folder"
        }
    }
}

#Preview {
    CategoryPickerView(
        selectedCategory: .constant("All"),
        categories: ["All", "Greetings", "Numbers", "Colors", "Food", "Animals", "Family", "Time", "Weather", "Travel"]
    )
} 