import SwiftUI
import BetComponents

struct TheSheetView: View {
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    @State private var selectedTab = 0
    @State private var isRoundPosted = false  // Add state for tracking posted status
    
    private var playerTotals: [(player: BetComponents.Player, total: Double)] {
        guard let teeBox = betManager.teeBox else { return [] }
        return betManager.allPlayers.map { player in
            let total = betManager.calculateTotalWinnings(
                player: player,
                playerScores: betManager.playerScores,
                teeBox: teeBox
            )
            return (player, total)
        }.sorted { $0.total > $1.total }
    }
    
    private var totalWinningsAndLosses: (winnings: Double, losses: Double) {
        let totals = playerTotals.reduce((winnings: 0.0, losses: 0.0)) { result, playerTotal in
            if playerTotal.total > 0 {
                return (result.winnings + playerTotal.total, result.losses)
            } else {
                return (result.winnings, result.losses + abs(playerTotal.total))
            }
        }
        return (
            totals.winnings.rounded(to: 2),
            totals.losses.rounded(to: 2)
        )
    }
    
    private var hasAlabamaWithSwingMan: Bool {
        betManager.alabamaBets.contains { bet in
            bet.swingMan != nil
        }
    }
    
    private var balanceImbalance: Double? {
        let (winnings, losses) = totalWinningsAndLosses
        let difference = winnings - losses
        // Only show imbalance if it exists and there's an Alabama bet with Swing Man
        return abs(difference) > 0.01 && hasAlabamaWithSwingMan ? difference : nil
    }
    
    private var totalBalance: Double {
        totalWinningsAndLosses.winnings - totalWinningsAndLosses.losses
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with balance
            VStack(spacing: 16) {
                // Title with icon
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                    
                    Text("The Sheet")
                        .font(.custom("Avenir-Heavy", size: 34))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Balance Indicator
                VStack(spacing: 4) {
                    BalanceIndicatorView(
                        winnings: totalWinningsAndLosses.winnings,
                        losses: totalWinningsAndLosses.losses
                    )
                    
                    if let imbalance = balanceImbalance {
                        Text("($\(String(format: "%.2f", abs(imbalance))) imbalance due to rounding in Alabama bet with Swing Man)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.bottom, 4)
                    }
                }
            }
            .padding(.vertical, 16)
            .background(Color.deepNavyBlue)
            
            // Updated view selector with gradient background
            Picker("View", selection: $selectedTab) {
                Text("Summary").tag(0)
                Text("Details").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.deepNavyBlue.opacity(0.1), .clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            if selectedTab == 0 {
                SheetSummaryView()
            } else {
                SheetDetailsView()
            }
        }
        .background(Color.white)
    }

    // Add function to reset sheet data
    private func resetSheetData() {
        betManager.playerScores = [:]
        betManager.teeBox = nil
        betManager.objectWillChange.send()
        isRoundPosted = false
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
                .foregroundColor(.white)
            
            Text(String(format: "$%.2f", amount))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
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
                AlabamaView(player: betManager.allPlayers[0])
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
        .foregroundColor(.deepNavyBlue)
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.primaryGreen.opacity(0.05), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
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
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(total >= 0 ? Color.primaryGreen.opacity(0.2) : Color.red.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(player.firstName.prefix(1))
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(total >= 0 ? .primaryGreen : .red)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(player.firstName)
                                .font(.headline)
                            Text("Total Winnings")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 160, alignment: .leading)
                    
                    Spacer()
                    
                    Text(String(format: "$%.2f", total))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(total >= 0 ? .primaryGreen : .red)
                        .frame(width: 100)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(
                            color: Color.black.opacity(isExpanded ? 0.15 : 0.08),
                            radius: isExpanded ? 10 : 6,
                            y: isExpanded ? 5 : 3
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .padding(.vertical, 4)
            
            if isExpanded {
                ScrollView {
                    PlayerBetBreakdown(player: player)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
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
    let player: BetComponents.Player
    
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

private struct PlayerBetBreakdown: View {
    let player: BetComponents.Player
    @EnvironmentObject var betManager: BetManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            IndividualMatchBreakdown(player: player)
            FourBallBreakdown(player: player)
            SkinsBreakdown(player: player)
            DoDaBreakdown(player: player)
            AlabamaBreakdown(player: player)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

private struct IndividualMatchBreakdown: View {
    let player: BetComponents.Player
    @EnvironmentObject private var betManager: BetManager
    
    var body: some View {
        if let individualBets = betManager.individualBets.first(where: { bet in
            bet.player1.id == player.id || bet.player2.id == player.id
        }) {
            let isPlayer1 = individualBets.player1.id == player.id
            let opponent = isPlayer1 ? individualBets.player2 : individualBets.player1
            let winnings = individualBets.calculateWinnings(
                playerScores: betManager.playerScores,
                teeBox: betManager.teeBox ?? .championship
            ) * (isPlayer1 ? 1 : -1)
            
            BetBreakdownRow(
                title: "Match vs \(opponent.firstName)",
                subtitle: "Per Hole: $\(Int(individualBets.perHoleAmount)) • Birdie: $\(Int(individualBets.perBirdieAmount))",
                details: "Press on 9 & 18: \(individualBets.pressOn9and18 ? "Yes" : "No")",
                amount: winnings,
                accentColor: .blue
            )
        }
    }
}

private struct FourBallBreakdown: View {
    let player: BetComponents.Player
    @EnvironmentObject private var betManager: BetManager
    
    var body: some View {
        ForEach(betManager.fourBallBets.filter { bet in
            [bet.team1Player1.id, bet.team1Player2.id,
             bet.team2Player1.id, bet.team2Player2.id].contains(player.id)
        }, id: \.id) { bet in
            let isTeam1 = bet.team1Player1.id == player.id || bet.team1Player2.id == player.id
            let partner = isTeam1 ? 
                (bet.team1Player1.id == player.id ? bet.team1Player2 : bet.team1Player1) :
                (bet.team2Player1.id == player.id ? bet.team2Player2 : bet.team2Player1)
            let opponents = isTeam1 ? 
                "\(bet.team2Player1.firstName)/\(bet.team2Player2.firstName)" :
                "\(bet.team1Player1.firstName)/\(bet.team1Player2.firstName)"
            
            BetBreakdownRow(
                title: "Four-Ball Match",
                subtitle: "Partner: \(partner.firstName) vs \(opponents)",
                details: "Per Hole: $\(Int(bet.perHoleAmount)) • Birdie: $\(Int(bet.perBirdieAmount)) • Press on 9 & 18: \(bet.pressOn9and18 ? "Yes" : "No")",
                amount: bet.calculateWinnings(
                    playerScores: betManager.playerScores,
                    teeBox: betManager.teeBox ?? .championship
                ) * (isTeam1 ? 1 : -1),
                accentColor: .purple
            )
        }
    }
}

private struct SkinsBreakdown: View {
    let player: BetComponents.Player
    @EnvironmentObject private var betManager: BetManager
    
    var body: some View {
        ForEach(betManager.skinsBets.filter { bet in
            bet.players.contains { $0.id == player.id }
        }, id: \.id) { bet in
            if let amount = bet.calculateWinnings(
                playerScores: betManager.playerScores,
                teeBox: betManager.teeBox ?? .championship
            )[player.id] {
                let skinsWon = getSkinsWonByHole(bet: bet, playerId: player.id)
                let totalSkins = getTotalSkinsCount(bet: bet)
                let valuePerSkin = bet.amount * Double(bet.players.count) / Double(max(1, totalSkins))
                let skinsDetail = skinsWon.isEmpty ? "No skins won yet" :
                    "Holes won: \(skinsWon.map { String($0) }.joined(separator: ", "))"
                
                BetBreakdownRow(
                    title: "Skins Game",
                    subtitle: "Value per skin: $\(Int(valuePerSkin))",
                    details: skinsDetail,
                    amount: amount,
                    accentColor: .orange
                )
            }
        }
    }
    
    private func getTotalSkinsCount(bet: SkinsBet) -> Int {
        var totalSkins = 0
        let scores = betManager.playerScores
        let teeBox = betManager.teeBox ?? .championship
        
        for holeIndex in 0..<18 {
            var lowestScore = Int.max
            var lowestScorePlayers: Set<UUID> = []
            
            for player in bet.players {
                if let scoreStr = scores[player.id]?[holeIndex],
                   let score = Int(scoreStr) {
                    if score < lowestScore {
                        lowestScore = score
                        lowestScorePlayers = [player.id]
                    } else if score == lowestScore {
                        lowestScorePlayers.insert(player.id)
                    }
                }
            }
            
            if lowestScorePlayers.count == 1 {
                totalSkins += 1
            }
        }
        
        return totalSkins
    }
    
    private func getSkinsWonByHole(bet: SkinsBet, playerId: UUID) -> [Int] {
        var skinsWon: [Int] = []
        let scores = betManager.playerScores
        let teeBox = betManager.teeBox ?? .championship
        
        for holeIndex in 0..<18 {
            var lowestScore = Int.max
            var lowestScorePlayers: Set<UUID> = []
            
            for player in bet.players {
                if let scoreStr = scores[player.id]?[holeIndex],
                   let score = Int(scoreStr) {
                    if score < lowestScore {
                        lowestScore = score
                        lowestScorePlayers = [player.id]
                    } else if score == lowestScore {
                        lowestScorePlayers.insert(player.id)
                    }
                }
            }
            
            if lowestScorePlayers.count == 1 && lowestScorePlayers.contains(playerId) {
                skinsWon.append(holeIndex + 1)
            }
        }
        
        return skinsWon
    }
}

private struct DoDaBreakdown: View {
    let player: BetComponents.Player
    @EnvironmentObject private var betManager: BetManager
    
    private func countDoDas() -> Int {
        let scores = betManager.playerScores[player.id] ?? []
        var count = 0
        for scoreStr in scores {
            if let score = Int(scoreStr), score == 2 {
                count += 1
            }
        }
        return count
    }
    
    var body: some View {
        ForEach(betManager.doDaBets.filter { bet in
            bet.players.contains { $0.id == player.id }
        }, id: \.id) { bet in
            let doDaCount = countDoDas()
            let totalDoDas = getTotalDoDaCount(bet: bet)
            
            // Calculate value per Do-Da based on bet type
            let valuePerDoDa = totalDoDas > 0 ? (
                bet.isPool ?
                    (bet.amount * Double(bet.players.count)) / Double(totalDoDas) :
                    bet.amount * Double(bet.players.count)
            ) : 0.0
            
            BetBreakdownRow(
                title: "Do-Da's",
                subtitle: "\(doDaCount) Do-Da\(doDaCount == 1 ? "" : "'s") made",
                details: "Value per Do-Da: $\(Int(valuePerDoDa))",
                amount: bet.calculateWinnings(
                    playerScores: betManager.playerScores,
                    teeBox: betManager.teeBox ?? .championship
                )[player.id] ?? 0,
                accentColor: .red
            )
        }
    }
    
    private func getTotalDoDaCount(bet: DoDaBet) -> Int {
        var totalCount = 0
        let scores = betManager.playerScores
        
        for player in bet.players {
            if let playerScores = scores[player.id] {
                for scoreStr in playerScores {
                    if let score = Int(scoreStr), score == 2 {
                        totalCount += 1
                    }
                }
            }
        }
        return totalCount
    }
}

private extension Double {
    func rounded(to places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}

private struct AlabamaResults {
    let front9: Double
    let back9: Double
    let lowBallFront9: Double
    let lowBallBack9: Double
    let birdies: Double
    
    var total: Double {
        (front9 + back9 + lowBallFront9 + lowBallBack9 + birdies).rounded(to: 2)
    }
}

private struct AlabamaTeamResultsRow: View {
    let label: String
    let amount: Double
    
    private var amountText: some View {
        Text(String(format: "$%.2f", amount))
            .font(.caption.bold())
            .foregroundColor(amount >= 0 ? .green : .red)
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
            amountText
        }
    }
}

private struct AlabamaTeamResultsView: View {
    let bet: AlabamaBet
    let playerTeamIndex: Int
    let otherTeamIndex: Int
    let teamResults: AlabamaResults
    
    private var headerView: some View {
        Text("vs Team \(otherTeamIndex + 1)")
            .font(.subheadline)
            .foregroundColor(.gray)
    }
    
    private var resultsView: some View {
        VStack(alignment: .leading, spacing: 4) {
            AlabamaTeamResultsRow(label: "Alabama Front 9:", amount: teamResults.front9)
            AlabamaTeamResultsRow(label: "Alabama Back 9:", amount: teamResults.back9)
            AlabamaTeamResultsRow(label: "Low Ball Front 9:", amount: teamResults.lowBallFront9)
            AlabamaTeamResultsRow(label: "Low Ball Back 9:", amount: teamResults.lowBallBack9)
            AlabamaTeamResultsRow(label: "Birdies:", amount: teamResults.birdies)
            AlabamaTeamResultsRow(label: "Total:", amount: teamResults.total)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            headerView
            resultsView
        }
        .padding(.vertical, 4)
    }
}

// NEW VERSION WITH MAPPING
private struct AlabamaBreakdown: View {
    @EnvironmentObject private var betManager: BetManager
    let player: BetComponents.Player
    
    private func mapToAlabamaResults(_ betResults: AlabamaBet.TeamResults) -> AlabamaResults {
        return AlabamaResults(
            front9: betResults.front9,
            back9: betResults.back9,
            lowBallFront9: betResults.lowBallFront9,
            lowBallBack9: betResults.lowBallBack9,
            birdies: betResults.birdies
        )
    }
    
    var body: some View {
        let relevantBets = betManager.alabamaBets.filter { bet in
            bet.teams.contains { team in team.contains { $0.id == player.id } } || bet.swingMan?.id == player.id
        }
        
        ForEach(relevantBets, id: \.id) { bet in
            if let teeBox = betManager.teeBox {
                let playerTeamIndex = bet.teams.firstIndex { team in
                    team.contains { $0.id == player.id }
                } ?? bet.swingManTeamIndex ?? 0
                
                // Calculate all matchup results first
                let matchupResults = bet.teams.indices.compactMap { index -> AlabamaResults? in
                    if index != playerTeamIndex {
                        let betResults = bet.calculateTeamResults(
                            playerTeamIndex: playerTeamIndex,
                            otherTeamIndex: index,
                            scores: betManager.playerScores,
                            teeBox: teeBox
                        )
                        return mapToAlabamaResults(betResults)
                    }
                    return nil
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // Use AlabamaTeamHeader for consistent display
                    AlabamaTeamHeader(
                        bet: bet,
                        playerTeamIndex: playerTeamIndex,
                        player: player,
                        teeBox: teeBox,
                        matchupResults: matchupResults
                    )
                    
                    // Show matchup details
                    ForEach(Array(bet.teams.enumerated()), id: \.offset) { index, team in
                        if index != playerTeamIndex {
                            let betResults = bet.calculateTeamResults(
                                playerTeamIndex: playerTeamIndex,
                                otherTeamIndex: index,
                                scores: betManager.playerScores,
                                teeBox: teeBox
                            )
                            let results = mapToAlabamaResults(betResults)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("vs Team \(index + 1)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    AlabamaTeamResultsRow(label: "Alabama Front 9:", amount: results.front9)
                                    AlabamaTeamResultsRow(label: "Alabama Back 9:", amount: results.back9)
                                    AlabamaTeamResultsRow(label: "Low Ball Front 9:", amount: results.lowBallFront9)
                                    AlabamaTeamResultsRow(label: "Low Ball Back 9:", amount: results.lowBallBack9)
                                    AlabamaTeamResultsRow(label: "Birdies:", amount: results.birdies)
                                    AlabamaTeamResultsRow(label: "Total:", amount: results.total)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
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

private struct AlabamaTeamHeader: View {
    @EnvironmentObject private var betManager: BetManager
    let bet: AlabamaBet
    let playerTeamIndex: Int
    let player: BetComponents.Player
    let teeBox: BetComponents.TeeBox
    let matchupResults: [AlabamaResults]  // Updated type
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Alabama")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                let netTotal = matchupResults.reduce(0.0) { $0 + $1.total }
                Text(String(format: "$%.2f", netTotal))
                    .font(.headline)
                    .foregroundColor(netTotal >= 0 ? .primaryGreen : .red)
            }
            
            // Show team info
            HStack {
                Text(player.id == bet.swingMan?.id ? 
                    "Swing Man - Team \(playerTeamIndex + 1)" : 
                    "Team \(playerTeamIndex + 1)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                let teamBirdies = bet.countTeamBirdies(
                    team: bet.teams[playerTeamIndex],
                    scores: betManager.playerScores,
                    teeBox: teeBox,
                    swingMan: bet.swingMan
                )
                Text("Total Birdies: \(teamBirdies)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
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
                .font(.headline)
                .foregroundColor(.deepNavyBlue)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
            if let amount = amount {
                Text(String(format: "Total pot: $%.0f", abs(amount)))
                    .font(.subheadline)
                    .foregroundColor(.primaryGreen)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.primaryGreen.opacity(0.05), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.05), radius: 4)
        )
    }
}

struct BetBreakdownRow: View {
    let title: String
    let subtitle: String?
    let details: String?
    let amount: Double
    let accentColor: Color
    
    init(
        title: String,
        subtitle: String? = nil,
        details: String? = nil,
        amount: Double,
        accentColor: Color = .primaryGreen
    ) {
        self.title = title
        self.subtitle = subtitle
        self.details = details
        self.amount = amount
        self.accentColor = accentColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Text(String(format: "$%.2f", amount))
                    .font(.headline)
                    .foregroundColor(amount >= 0 ? .primaryGreen : .red)
            }
            
            if let details = details {
                Text(details)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    amount >= 0 ? .primaryGreen.opacity(0.1) : .deepNavyBlue.opacity(0.1),
                                    amount >= 0 ? .primaryGreen.opacity(0.05) : .deepNavyBlue.opacity(0.05)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 4)
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
                    .foregroundColor(.deepNavyBlue)
            }
            .padding(.horizontal, 4)
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.primaryGreen.opacity(0.05), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
    }
}

struct BetSummary {
    let title: String
    let subtitle: String
    let amount: Double
}

struct BalanceIndicatorView: View {
    let winnings: Double
    let losses: Double
    
    private var isBalanced: Bool {
        abs(winnings - losses) < 0.01
    }
    
    var body: some View {
        HStack(spacing: 16) {
            BalanceCard(
                title: "WINNINGS",
                amount: winnings,
                color: .primaryGreen
            )
            
            BalanceCard(
                title: "LOSSES",
                amount: losses,
                color: .red
            )
        }
        .padding(.horizontal)
        .background(Color.deepNavyBlue)
    }
} 
