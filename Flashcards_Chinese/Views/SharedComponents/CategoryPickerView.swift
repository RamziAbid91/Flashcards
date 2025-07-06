import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategory: String
    let categories: [String]
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
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
                ForEach(filteredCategories, id: \.self) { category in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                            dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: category == "All" ? "square.grid.2x2.fill" : 
                                  category == "Favorites" ? "heart.fill" : "folder.fill")
                                .foregroundColor(Theme.primaryColor)
                                .font(.system(size: 16))
                            
                            Text(category)
                                .foregroundColor(Theme.textColor)
                            
                            Spacer()
                            
                            if category == selectedCategory {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Theme.primaryColor)
                                    .font(.system(size: 14, weight: .bold))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .contentShape(Rectangle())
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .listStyle(.insetGrouped)
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
}

struct CategoryPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryPickerView(
            selectedCategory: .constant("All"),
            categories: ["All", "Favorites", "Basic Words", "Q/S/C/SH/ZH Words"]
        )
    }
} 