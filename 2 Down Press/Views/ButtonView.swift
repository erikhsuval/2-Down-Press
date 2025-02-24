import SwiftUI

struct ButtonView: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title2)
            Text(title)
                .font(.title2.bold())
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primaryGreen.opacity(0.8))
        )
        .padding(.horizontal, 30)
    }
} 