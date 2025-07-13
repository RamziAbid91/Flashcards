import SwiftUI

struct StudyStatsView: View {
    @ObservedObject var deck: FlashcardDeck
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Study Statistics")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Total Cards",
                    value: "\(deck.cards.count)",
                    icon: "rectangle.stack",
                    color: .blue
                )
                
                StatCard(
                    title: "Favorites",
                    value: "\(deck.favoriteCards.count)",
                    icon: "heart.fill",
                    color: .red
                )
                
                StatCard(
                    title: "Seen Cards",
                    value: "\(deck.seenCards.count)",
                    icon: "eye.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Quiz Score",
                    value: "\(Int(deck.quizScore.percentage))%",
                    icon: "chart.bar.fill",
                    color: .orange
                )
            }
            
            ProgressView("Learning Progress", value: Double(deck.seenCards.count), total: Double(deck.cards.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
} 