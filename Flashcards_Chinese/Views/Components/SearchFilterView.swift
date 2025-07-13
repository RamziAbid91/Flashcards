import SwiftUI

struct SearchFilterView: View {
    @Binding var searchText: String
    @Binding var selectedDifficulty: Int?
    @Binding var showOnlyFavorites: Bool
    @Binding var showOnlyUnseen: Bool
    
    let difficulties = ["All", "Beginner", "Intermediate", "Advanced"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search cards...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                    }
                    .foregroundColor(.blue)
                }
            }
            
            // Filter Options
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Difficulty Filter
                    Menu {
                        ForEach(0..<difficulties.count, id: \.self) { index in
                            Button(difficulties[index]) {
                                selectedDifficulty = index == 0 ? nil : index
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                            Text(selectedDifficulty == nil ? "All Levels" : difficulties[selectedDifficulty!])
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Favorites Toggle
                    Button {
                        showOnlyFavorites.toggle()
                    } label: {
                        HStack {
                            Image(systemName: showOnlyFavorites ? "heart.fill" : "heart")
                            Text("Favorites")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(showOnlyFavorites ? Color.red.opacity(0.2) : Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Unseen Toggle
                    Button {
                        showOnlyUnseen.toggle()
                    } label: {
                        HStack {
                            Image(systemName: showOnlyUnseen ? "eye.slash.fill" : "eye.slash")
                            Text("Unseen")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(showOnlyUnseen ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
} 