import SwiftUI
import BetComponents

struct TheSheetView: View {
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    @State private var selectedTab = 0
    
    private var totalWinningsAndLosses: (winnings: Double, losses: Double) {
        guard let teeBox = betManager.teeBox else { return (0, 0) }
        return betManager.allPlayers.reduce((0.0, 0.0)) { result, player in
            let amount = betManager.calculateTotalWinnings(
                player: player,
                playerScores: betManager.playerScores,
                teeBox: teeBox
            )
            if amount > 0 {
                return (result.0 + amount, result.1)
            } else {
                return (result.0, result.1 + abs(amount))
            }
        }
    }
    
    private var totalBalance: Double {
        totalWinningsAndLosses.winnings - totalWinningsAndLosses.losses
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with balance
            HStack {
                Text("The Sheet")
                    .font(.custom("Avenir-Heavy", size: 34))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                
                Spacer()
                
                // Balance indicator
                VStack(alignment: .center, spacing: 8) {
                    Text("BALANCE")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 20) {
                        // Winnings
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("WIN")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                            Text(String(format: "$%.0f", totalWinningsAndLosses.winnings))
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(.primaryGreen)
                        }
                        .frame(width: 100)
                        
                        // Divider
                        Rectangle()
                            .frame(width: 2, height: 40)
                            .foregroundColor(.white.opacity(0.3))
                        
                        // Losses
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("LOSS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                            Text(String(format: "$%.0f", totalWinningsAndLosses.losses))
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(.red)
                        }
                        .frame(width: 100)
                    }
                    
                    // Show imbalance if any
                    if abs(totalBalance) > 0.01 {
                        Text("Imbalance: \(String(format: "$%.2f", abs(totalBalance)))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    abs(totalBalance) < 0.01 ? 
                                    Color.green.opacity(0.5) : 
                                    Color.red.opacity(0.5),
                                    lineWidth: 1.5
                                )
                        )
                )
                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                .frame(minWidth: 280)
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.95)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // View selector
            Picker("View", selection: $selectedTab) {
                Text("Summary").tag(0)
                Text("Details").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color.gray.opacity(0.1))
            
            if selectedTab == 0 {
                SheetSummaryView()
            } else {
                SheetDetailsView()
            }
        }
    }
}

// New component for balance cards
struct BalanceCard: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
            
            Text(String(format: "$%.0f", amount))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.15))
                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        )
    }
}

private struct SheetSummaryView: View {
    @EnvironmentObject private var betManager: BetManager
    @State private var expandedPlayers: Set<UUID> = []
    
    var body: some View {
        VStack(spacing: 0) {
            SheetHeaderView()
            PlayerListView(expandedPlayers: $expandedPlayers)
        }
        .background(Color.gray.opacity(0.05))
    }
}

private struct SheetDetailsView: View {
    @EnvironmentObject private var betManager: BetManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                IndividualMatchesView()
                FourBallMatchesView()
                SkinsView()
                DoDaView()
                AlabamaView()
            }
            .padding()
        }
    }
}

private struct SheetHeaderView: View {
    var body: some View {
        HStack {
            Text("Player")
                .frame(width: 120, alignment: .leading)
            Spacer()
            Text("Net")
                .frame(width: 100)
        }
        .font(.subheadline.bold())
        .foregroundColor(.gray)
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5)
        )
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

private struct PlayerListView: View {
    @EnvironmentObject private var betManager: BetManager
    @Binding var expandedPlayers: Set<UUID>
    
    var body: some View {
        let manager = _betManager.wrappedValue
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(totalsByPlayer(manager).enumerated()), id: \.element.player.id) { index, item in
                    SheetPlayerRowView(
                        player: item.player,
                        total: item.total,
                        isExpanded: expandedPlayers.contains(item.player.id),
                        index: index,
                        onToggle: {
                            if expandedPlayers.contains(item.player.id) {
                                expandedPlayers.remove(item.player.id)
                            } else {
                                expandedPlayers.insert(item.player.id)
                            }
                        }
                    )
                    Divider()
                }
            }
        }
    }
    
    private func totalsByPlayer(_ manager: BetManager) -> [(player: BetComponents.Player, total: Double)] {
        guard let teeBox = manager.teeBox else { return [] }
        return manager.allPlayers.map { player in
            let total = manager.calculateTotalWinnings(
                player: player,
                playerScores: manager.playerScores,
                teeBox: teeBox
            )
            return (player, total)
        }.sorted { $0.total > $1.total }
    }
}

private struct SheetPlayerRowView: View {
    let player: BetComponents.Player
    let total: Double
    let isExpanded: Bool
    let index: Int
    let onToggle: () -> Void
    @EnvironmentObject private var betManager: BetManager
    
    var body: some View {
        Button(action: onToggle) {
            VStack(spacing: 0) {
                HStack {
                    Text(player.firstName)
                        .font(.headline)
                        .frame(width: 120, alignment: .leading)
                    Spacer()
                    Text(String(format: "$%.0f", total))
                        .font(.headline)
                        .foregroundColor(total >= 0 ? .green : .red)
                        .frame(width: 100)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(
                            color: Color.black.opacity(isExpanded ? 0.1 : 0.05),
                            radius: isExpanded ? 8 : 4
                        )
                )
                .padding(.horizontal)
                .padding(.vertical, 4)
                
                if isExpanded {
                    PlayerBetBreakdown(player: player, betManager: betManager)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.05))
                                .shadow(color: .black.opacity(0.05), radius: 4)
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct IndividualMatchesView: View {
    @EnvironmentObject private var betManager: BetManager
    
    var body: some View {
        if !betManager.individualBets.isEmpty {
            BetTypeSection(title: "Individual Matches", icon: "person.2") {
                ForEach(betManager.individualBets, id: \.id) { bet in
                    BetDetailRow(
                        title: "\(bet.player1.firstName) vs \(bet.player2.firstName)",
                        subtitle: "Per hole: $\(Int(bet.perHoleAmount)) • Birdie: $\(Int(bet.perBirdieAmount))",
                        amount: betManager.teeBox.map { bet.calculateWinnings(playerScores: betManager.playerScores, teeBox: $0) }
                    )
                }
            }
        }
    }
}

private struct FourBallMatchesView: View {
    @EnvironmentObject private var betManager: BetManager
    
    var body: some View {
        if !betManager.fourBallBets.isEmpty {
            BetTypeSection(title: "Four-Ball Matches", icon: "person.3") {
                ForEach(betManager.fourBallBets, id: \.id) { bet in
                    BetDetailRow(
                        title: "\(bet.team1Player1.firstName)/\(bet.team1Player2.firstName) vs \(bet.team2Player1.firstName)/\(bet.team2Player2.firstName)",
                        subtitle: "Per hole: $\(Int(bet.perHoleAmount)) • Birdie: $\(Int(bet.perBirdieAmount))",
                        amount: betManager.teeBox.map { bet.calculateWinnings(playerScores: betManager.playerScores, teeBox: $0) }
                    )
                }
            }
        }
    }
}

private struct SkinsView: View {
    @EnvironmentObject private var betManager: BetManager
    
    var body: some View {
        if !betManager.skinsBets.isEmpty {
            BetTypeSection(title: "Skins", icon: "dollarsign.circle") {
                ForEach(betManager.skinsBets, id: \.id) { bet in
                    if let teeBox = betManager.teeBox {
                        let winnings = bet.calculateWinnings(playerScores: betManager.playerScores, teeBox: teeBox)
                        BetDetailRow(
                            title: "\(bet.players.count) Players",
                            subtitle: "$\(Int(bet.amount)) per player",
                            amount: winnings.values.reduce(0, +)
                        )
                    }
                }
            }
        }
    }
}

private struct DoDaView: View {
    @EnvironmentObject private var betManager: BetManager
    
    var body: some View {
        if !betManager.doDaBets.isEmpty {
            BetTypeSection(title: "Do-Da's", icon: "2.circle") {
                ForEach(betManager.doDaBets, id: \.id) { bet in
                    if let teeBox = betManager.teeBox {
                        let winnings = bet.calculateWinnings(playerScores: betManager.playerScores, teeBox: teeBox)
                        BetDetailRow(
                            title: bet.isPool ? "Pool" : "Per Do-Da",
                            subtitle: "$\(Int(bet.amount)) \(bet.isPool ? "per player" : "per Do-Da")",
                            amount: winnings.values.reduce(0, +)
                        )
                    }
                }
            }
        }
    }
}

private struct AlabamaView: View {
    @EnvironmentObject private var betManager: BetManager
    
    var body: some View {
        if !betManager.alabamaBets.isEmpty {
            BetTypeSection(title: "Alabama", icon: "person.3.sequence") {
                ForEach(betManager.alabamaBets, id: \.id) { bet in
                    if let teeBox = betManager.teeBox {
                        let winnings = bet.calculateWinnings(playerScores: betManager.playerScores, teeBox: teeBox)
                        BetDetailRow(
                            title: "\(bet.teams.count) Teams",
                            subtitle: "Front 9: $\(Int(bet.frontNineAmount)) • Back 9: $\(Int(bet.backNineAmount))",
                            amount: winnings.values.reduce(0, +)
                        )
                    }
                }
            }
        }
    }
}

private struct BetDetailRow: View {
    let title: String
    let subtitle: String
    let amount: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
            if let amount = amount {
                Text(String(format: "Total pot: $%.0f", abs(amount)))
                    .font(.caption)
                    .foregroundColor(.primaryGreen)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct PlayerBetBreakdown: View {
    let player: BetComponents.Player
    let betManager: BetManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Individual Matches
            ForEach(betManager.individualBets.filter { bet in
                bet.player1.id == player.id || bet.player2.id == player.id
            }) { bet in
                BetBreakdownRow(
                    title: "\(bet.player1.firstName) vs \(bet.player2.firstName)",
                    amount: bet.calculateWinnings(
                        playerScores: betManager.playerScores,
                        teeBox: betManager.teeBox ?? .championship
                    ) * (bet.player1.id == player.id ? 1 : -1)
                )
            }
            
            // Four Ball Matches
            ForEach(betManager.fourBallBets.filter { bet in
                [bet.team1Player1.id, bet.team1Player2.id,
                 bet.team2Player1.id, bet.team2Player2.id].contains(player.id)
            }) { bet in
                let isTeam1 = bet.team1Player1.id == player.id || bet.team1Player2.id == player.id
                BetBreakdownRow(
                    title: "\(bet.team1Player1.firstName)/\(bet.team1Player2.firstName) vs \(bet.team2Player1.firstName)/\(bet.team2Player2.firstName)",
                    amount: bet.calculateWinnings(
                        playerScores: betManager.playerScores,
                        teeBox: betManager.teeBox ?? .championship
                    ) * (isTeam1 ? 1 : -1)
                )
            }
            
            // Skins
            ForEach(betManager.skinsBets.filter { bet in
                bet.players.contains { $0.id == player.id }
            }) { bet in
                if let amount = bet.calculateWinnings(
                    playerScores: betManager.playerScores,
                    teeBox: betManager.teeBox ?? .championship
                )[player.id] {
                    BetBreakdownRow(
                        title: "Skins",
                        amount: amount
                    )
                }
            }
            
            // Do-Da's
            ForEach(betManager.doDaBets.filter { bet in
                bet.players.contains { $0.id == player.id }
            }) { bet in
                if let amount = bet.calculateWinnings(
                    playerScores: betManager.playerScores,
                    teeBox: betManager.teeBox ?? .championship
                )[player.id] {
                    BetBreakdownRow(
                        title: "Do-Da's",
                        amount: amount
                    )
                }
            }
            
            // Alabama
            ForEach(betManager.alabamaBets.filter { bet in
                bet.teams.contains { team in
                    team.contains { $0.id == player.id }
                }
            }) { bet in
                if let amount = bet.calculateWinnings(
                    playerScores: betManager.playerScores,
                    teeBox: betManager.teeBox ?? .championship
                )[player.id] {
                    BetBreakdownRow(
                        title: "Alabama",
                        amount: amount
                    )
                }
            }
        }
    }
}

struct BetBreakdownRow: View {
    let title: String
    let amount: Double
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(String(format: "$%.0f", amount))
                .font(.subheadline.bold())
                .foregroundColor(amount >= 0 ? .green : .red)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 2)
        )
    }
}

struct BetTypeSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.primaryGreen)
                Text(title)
                    .font(.headline)
            }
            content
        }
    }
}

struct BetSummary {
    let title: String
    let subtitle: String
    let amount: Double
} 