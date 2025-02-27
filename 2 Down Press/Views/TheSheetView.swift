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
        playerTotals.reduce((0.0, 0.0)) { result, playerTotal in
            if playerTotal.total > 0 {
                return (result.0 + playerTotal.total, result.1)
            } else {
                return (result.0, result.1 + abs(playerTotal.total))
            }
        }
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
                BalanceIndicatorView(
                    winnings: totalWinningsAndLosses.winnings,
                    losses: totalWinningsAndLosses.losses
                )
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

private struct AlabamaBreakdown: View {
    @EnvironmentObject private var betManager: BetManager
    let player: BetComponents.Player
    
    private func calculateTeamScore(
        team: [BetComponents.Player],
        holes: Range<Int>,
        scores: [UUID: [String]],
        teeBox: BetComponents.TeeBox,
        swingMan: BetComponents.Player?
    ) -> Int {
        var totalScore = 0
        for hole in holes {
            var lowestScore = Int.max
            for player in team {
                if let scoreStr = scores[player.id]?[hole],
                   let score = Int(scoreStr) {
                    lowestScore = min(lowestScore, score)
                }
            }
            if let swingMan = swingMan,
               let scoreStr = scores[swingMan.id]?[hole],
               let score = Int(scoreStr) {
                lowestScore = min(lowestScore, score)
            }
            if lowestScore != Int.max {
                totalScore += lowestScore
            }
        }
        return totalScore
    }
    
    private func calculateLowBallTotal(
        team: [BetComponents.Player],
        holes: Range<Int>,
        scores: [UUID: [String]],
        swingMan: BetComponents.Player?
    ) -> Int {
        var lowBallWins = 0
        for hole in holes {
            var lowestScore = Int.max
            for player in team {
                if let scoreStr = scores[player.id]?[hole],
                   let score = Int(scoreStr) {
                    lowestScore = min(lowestScore, score)
                }
            }
            if let swingMan = swingMan,
               let scoreStr = scores[swingMan.id]?[hole],
               let score = Int(scoreStr) {
                lowestScore = min(lowestScore, score)
            }
            if lowestScore != Int.max {
                lowBallWins += 1
            }
        }
        return lowBallWins
    }
    
    private func countTeamBirdies(
        team: [BetComponents.Player],
        scores: [UUID: [String]],
        teeBox: BetComponents.TeeBox,
        swingMan: BetComponents.Player?
    ) -> Int {
        var birdieCount = 0
        for holeIndex in 0..<18 {
            let par = teeBox.holes[holeIndex].par
            for player in team {
                if let scoreStr = scores[player.id]?[holeIndex],
                   let score = Int(scoreStr),
                   score < par {
                    birdieCount += 1
                }
            }
            if let swingMan = swingMan,
               let scoreStr = scores[swingMan.id]?[holeIndex],
               let score = Int(scoreStr),
               score < par {
                birdieCount += 1
            }
        }
        return birdieCount
    }
    
    private func calculateAlabamaTeamResults(
        bet: AlabamaBet,
        playerTeamIndex: Int,
        otherTeamIndex: Int
    ) -> (front9: Double, back9: Double, lowBallFront9: Double, lowBallBack9: Double, birdies: Double) {
        let scores = betManager.playerScores
        let teeBox = betManager.teeBox ?? .championship
        
        // Calculate Alabama front 9
        let playerTeamFront9 = calculateTeamScore(
            team: bet.teams[playerTeamIndex],
            holes: 0..<9,
            scores: scores,
            teeBox: teeBox,
            swingMan: playerTeamIndex == bet.swingManTeamIndex ? bet.swingMan : nil
        )
        let otherTeamFront9 = calculateTeamScore(
            team: bet.teams[otherTeamIndex],
            holes: 0..<9,
            scores: scores,
            teeBox: teeBox,
            swingMan: otherTeamIndex == bet.swingManTeamIndex ? bet.swingMan : nil
        )
        let front9Total = playerTeamFront9 < otherTeamFront9 ? bet.frontNineAmount :
                         playerTeamFront9 > otherTeamFront9 ? -bet.frontNineAmount : 0
        
        // Calculate Alabama back 9
        let playerTeamBack9 = calculateTeamScore(
            team: bet.teams[playerTeamIndex],
            holes: 9..<18,
            scores: scores,
            teeBox: teeBox,
            swingMan: playerTeamIndex == bet.swingManTeamIndex ? bet.swingMan : nil
        )
        let otherTeamBack9 = calculateTeamScore(
            team: bet.teams[otherTeamIndex],
            holes: 9..<18,
            scores: scores,
            teeBox: teeBox,
            swingMan: otherTeamIndex == bet.swingManTeamIndex ? bet.swingMan : nil
        )
        let back9Total = playerTeamBack9 < otherTeamBack9 ? bet.backNineAmount :
                        playerTeamBack9 > otherTeamBack9 ? -bet.backNineAmount : 0
        
        // Calculate Low Ball totals for front and back 9
        let playerTeamLowBallFront9 = calculateLowBallTotal(
            team: bet.teams[playerTeamIndex],
            holes: 0..<9,
            scores: scores,
            swingMan: playerTeamIndex == bet.swingManTeamIndex ? bet.swingMan : nil
        )
        let otherTeamLowBallFront9 = calculateLowBallTotal(
            team: bet.teams[otherTeamIndex],
            holes: 0..<9,
            scores: scores,
            swingMan: otherTeamIndex == bet.swingManTeamIndex ? bet.swingMan : nil
        )
        
        let playerTeamLowBallBack9 = calculateLowBallTotal(
            team: bet.teams[playerTeamIndex],
            holes: 9..<18,
            scores: scores,
            swingMan: playerTeamIndex == bet.swingManTeamIndex ? bet.swingMan : nil
        )
        let otherTeamLowBallBack9 = calculateLowBallTotal(
            team: bet.teams[otherTeamIndex],
            holes: 9..<18,
            scores: scores,
            swingMan: otherTeamIndex == bet.swingManTeamIndex ? bet.swingMan : nil
        )
        
        // Calculate Low Ball results for each nine
        let lowBallFront9 = playerTeamLowBallFront9 < otherTeamLowBallFront9 ? bet.lowBallAmount :
                           playerTeamLowBallFront9 > otherTeamLowBallFront9 ? -bet.lowBallAmount : 0
        
        let lowBallBack9 = playerTeamLowBallBack9 < otherTeamLowBallBack9 ? bet.lowBallAmount :
                          playerTeamLowBallBack9 > otherTeamLowBallBack9 ? -bet.lowBallAmount : 0
        
        // Calculate birdies
        let playerTeamBirdies = countTeamBirdies(
            team: bet.teams[playerTeamIndex],
            scores: scores,
            teeBox: teeBox,
            swingMan: playerTeamIndex == bet.swingManTeamIndex ? bet.swingMan : nil
        )
        let otherTeamBirdies = countTeamBirdies(
            team: bet.teams[otherTeamIndex],
            scores: scores,
            teeBox: teeBox,
            swingMan: otherTeamIndex == bet.swingManTeamIndex ? bet.swingMan : nil
        )
        let birdieTotal = Double(playerTeamBirdies - otherTeamBirdies) * bet.perBirdieAmount
        
        // Calculate team sizes
        let playerTeamSize = bet.teams[playerTeamIndex].count + 
            (bet.swingManTeamIndex == playerTeamIndex ? 1 : 0)
        let otherTeamSize = bet.teams[otherTeamIndex].count + 
            (bet.swingManTeamIndex == otherTeamIndex ? 1 : 0)
        let teamSizeRatio = Double(otherTeamSize) / Double(playerTeamSize)
        
        return (
            front9: front9Total * teamSizeRatio,
            back9: back9Total * teamSizeRatio,
            lowBallFront9: lowBallFront9 * teamSizeRatio,
            lowBallBack9: lowBallBack9 * teamSizeRatio,
            birdies: birdieTotal * teamSizeRatio
        )
    }
    
    var body: some View {
        let relevantBets = betManager.alabamaBets.filter { bet in
            bet.teams.contains { team in
                team.contains { $0.id == player.id }
            } || bet.swingMan?.id == player.id
        }
        
        ForEach(relevantBets, id: \.id) { bet in
            if let teeBox = betManager.teeBox {
                let playerTeamIndex = bet.teams.firstIndex { team in
                    team.contains { $0.id == player.id }
                } ?? bet.swingManTeamIndex ?? 0
                
                VStack(alignment: .leading, spacing: 8) {
                    // Add total winnings at the top
                    HStack {
                        Text("Alabama")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        let totalWinnings = bet.calculateWinnings(playerScores: betManager.playerScores, teeBox: teeBox)[player.id] ?? 0
                        Text(String(format: "$%.2f", totalWinnings))
                            .font(.headline)
                            .foregroundColor(totalWinnings >= 0 ? .primaryGreen : .red)
                    }
                    
                    Text(player.id == bet.swingMan?.id ? 
                        "Swing Man - Team \(playerTeamIndex + 1)" : 
                        "Team \(playerTeamIndex + 1)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    ForEach(Array(bet.teams.enumerated()), id: \.offset) { index, team in
                        if index != playerTeamIndex {
                            let teamResults = calculateAlabamaTeamResults(
                                bet: bet,
                                playerTeamIndex: playerTeamIndex,
                                otherTeamIndex: index
                            )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("vs Team \(index + 1)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Text("Alabama Front 9:")
                                        .font(.caption)
                                    Text(String(format: "$%.2f", teamResults.front9))
                                        .font(.caption.bold())
                                        .foregroundColor(teamResults.front9 >= 0 ? .green : .red)
                                }
                                
                                HStack {
                                    Text("Alabama Back 9:")
                                        .font(.caption)
                                    Text(String(format: "$%.2f", teamResults.back9))
                                        .font(.caption.bold())
                                        .foregroundColor(teamResults.back9 >= 0 ? .green : .red)
                                }
                                
                                HStack {
                                    Text("Low Ball Front 9:")
                                        .font(.caption)
                                    Text(String(format: "$%.2f", teamResults.lowBallFront9))
                                        .font(.caption.bold())
                                        .foregroundColor(teamResults.lowBallFront9 >= 0 ? .green : .red)
                                }
                                
                                HStack {
                                    Text("Low Ball Back 9:")
                                        .font(.caption)
                                    Text(String(format: "$%.2f", teamResults.lowBallBack9))
                                        .font(.caption.bold())
                                        .foregroundColor(teamResults.lowBallBack9 >= 0 ? .green : .red)
                                }
                                
                                HStack {
                                    Text("Birdies:")
                                        .font(.caption)
                                    Text(String(format: "$%.2f", teamResults.birdies))
                                        .font(.caption.bold())
                                        .foregroundColor(teamResults.birdies >= 0 ? .green : .red)
                                }
                                
                                Divider()
                                    .padding(.vertical, 4)
                                
                                HStack {
                                    Text("Total:")
                                        .font(.caption)
                                    Text(String(format: "$%.2f", teamResults.front9 + teamResults.back9 + 
                                                               teamResults.lowBallFront9 + teamResults.lowBallBack9 + 
                                                               teamResults.birdies))
                                        .font(.caption.bold())
                                        .foregroundColor((teamResults.front9 + teamResults.back9 + 
                                                        teamResults.lowBallFront9 + teamResults.lowBallBack9 + 
                                                        teamResults.birdies) >= 0 ? .green : .red)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.05), radius: 2)
                            )
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
