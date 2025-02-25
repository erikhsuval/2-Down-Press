import SwiftUI
import BetComponents

struct ScorecardNavigationTabs: View {
    @Binding var showLeaderboard: Bool
    @Binding var showBetCreation: Bool
    let selectedGroupPlayers: [BetComponents.Player]
    let currentPlayerIndex: Int
    
    var body: some View {
        HStack(spacing: 0) {
            NavigationButton(
                title: "Leaderboard",
                icon: "list.bullet",
                action: { showLeaderboard = true },
                backgroundColor: Color.deepNavyBlue
            )
            
            NavigationButton(
                title: "Bets",
                icon: "dollarsign.circle",
                action: { showBetCreation = true },
                backgroundColor: Color.primaryGreen
            )
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}

struct NavigationButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    let backgroundColor: Color
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.custom("Avenir-Heavy", size: 18))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                backgroundColor
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [.white.opacity(0.2), .clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
} 
