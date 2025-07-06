import SwiftUI

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 8)
                    .opacity(0.1)
                    .foregroundColor(Theme.accentColor)
                
                Rectangle()
                    .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width), height: 8)
                    .foregroundColor(Theme.accentColor)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progress)
            }
            .cornerRadius(4)
        }
        .frame(height: 8)
    }
}

#Preview {
    ProgressBar(progress: 0.6)
        .padding()
} 