import SwiftUI
import BetComponents

struct ScorecardNavigationTabs: View {
    @Binding var showLeaderboard: Bool
    @Binding var showBetCreation: Bool
    let selectedGroupPlayers: [BetComponents.Player]
    let currentPlayerIndex: Int
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation {
                    showLeaderboard.toggle()
                }
            } label: {
                Text("Round")
                    .foregroundColor(.white)
                    .frame(width: 80)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                    )
            }
            
            Spacer()
            
            if !selectedGroupPlayers.isEmpty {
                Text(selectedGroupPlayers[currentPlayerIndex % selectedGroupPlayers.count].firstName)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button {
                withAnimation {
                    showBetCreation.toggle()
                }
            } label: {
                Text("Bets")
                    .foregroundColor(.white)
                    .frame(width: 80)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                    )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.primaryGreen)
    }
} 