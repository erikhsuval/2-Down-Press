import SwiftUI
import BetComponents

struct SideBetsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    @State private var expandedPlayers: Set<UUID> = []
    
    private var playerSideBetTotals: [(player: BetComponents.Player, total: Double)] {
        guard let teeBox = betManager.teeBox else { return [] }
        return betManager.allPlayers.map { player in
            let total = betManager.calculateSideBetWinnings(
                player: player,
                playerScores: betManager.playerScores,
                teeBox: teeBox
            )
            return (player, total)
        }.filter { $0.total != 0 }  // Only show players with non-zero side bet totals
        .sorted { $0.total > $1.total }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Balance Cards
                    if !playerSideBetTotals.isEmpty {
                        SideBetBalanceView(totals: playerSideBetTotals)
                            .padding(.top)
                    }
                    
                    if playerSideBetTotals.isEmpty {
                        Text("No active side bets")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                    }
                    
                    // Circus Bets Section
                    if !betManager.circusBets.isEmpty {
                        BetTypeSection(title: "Circus Bets", icon: "🎪") {
                            VStack(spacing: 12) {
                                ForEach(betManager.circusBets) { bet in
                                    CircusBetRow(bet: bet)
                                }
                            }
                        }
                    }
                    
                    // Putting with Puff Section
                    if !betManager.puttingWithPuffBets.isEmpty {
                        BetTypeSection(title: "Putting with Puff", icon: "💉") {
                            VStack(spacing: 12) {
                                ForEach(betManager.puttingWithPuffBets) { bet in
                                    PuttingWithPuffRow(bet: bet)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Side Bets")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct SideBetBalanceView: View {
    let totals: [(player: BetComponents.Player, total: Double)]
    
    private var totalWinnings: Double {
        totals.filter { $0.total > 0 }.reduce(0) { $0 + $1.total }
    }
    
    private var totalLosses: Double {
        abs(totals.filter { $0.total < 0 }.reduce(0) { $0 + $1.total })
    }
    
    var body: some View {
        VStack(spacing: 16) {
            BalanceIndicatorView(
                winnings: totalWinnings,
                losses: totalLosses
            )
            
            // Player Totals
            ForEach(totals, id: \.player.id) { item in
                HStack {
                    Text(item.player.firstName)
                        .font(.headline)
                    Spacer()
                    Text(String(format: "$%.2f", item.total))
                        .font(.headline)
                        .foregroundColor(item.total >= 0 ? .primaryGreen : .red)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 4)
                )
            }
        }
    }
}

private struct CircusBetRow: View {
    let bet: CircusBet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(bet.betType.rawValue)
                .font(.headline)
            Text("Amount: $\(Int(bet.amount))")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("Players: \(bet.players.map { $0.firstName }.joined(separator: ", "))")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 4)
        )
    }
}

private struct PuttingWithPuffRow: View {
    let bet: PuttingWithPuffBet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Current Amount: $\(Int(bet.betAmount))")
                    .font(.headline)
                Spacer()
                Text("Players: \(bet.players.count)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // Show running totals
            ForEach(Array(bet.players), id: \.id) { player in
                HStack {
                    Text(player.firstName)
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "$%.0f", bet.playerTotals[player.id] ?? 0))
                        .font(.subheadline.bold())
                        .foregroundColor((bet.playerTotals[player.id] ?? 0) >= 0 ? .primaryGreen : .red)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 4)
        )
    }
} 