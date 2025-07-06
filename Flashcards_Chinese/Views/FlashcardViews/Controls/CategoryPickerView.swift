//
//  CategoryPickerView.swift
//  Flashcards_Chinese
//
//  Created by Ramzi Abid on 2025-06-08.
//
import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategory: String
    let categories: [String]
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        dismiss()
                    }) {
                        HStack {
                            Text(category)
                                .foregroundColor(Theme.textColor)
                            Spacer()
                            if category == selectedCategory {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Theme.primaryColor)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .tint(Theme.primaryColor)
                }
            }
            .background(Theme.backgroundColor)
            .scrollContentBackground(.hidden)
        }
    }
}

struct CategoryPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryPickerView(
            selectedCategory: .constant("HSK 1"),
            categories: ["All", "Favorites", "HSK 1", "Food", "Social Media Slang"]
        )
        
    }
}
