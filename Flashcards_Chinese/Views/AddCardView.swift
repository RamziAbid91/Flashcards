var body: some View {
    NavigationView {
        ZStack {
            Theme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // ... existing code ...
                }
                .padding()
            }
        }
        .navigationTitle("Add New Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(Theme.accentColor)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: {
                        selectedTab = 3 // Switch to Admin Panel
                    }) {
                        Image(systemName: "gear.circle.fill")
                            .foregroundColor(Theme.accentColor)
                    }
                    
                    Button("Save") {
                        saveCard()
                    }
                    .foregroundColor(Theme.accentColor)
                    .disabled(!isValid)
                }
            }
        }
    }
} 