private struct IndividualMatchesView: View {
    @EnvironmentObject private var betManager: BetManager
    
    var body: some View {
        if !betManager.individualBets.isEmpty {
            BetTypeSection(title: "Individual Matches", icon: "person.2") {
                ForEach(betManager.individualBets, id: \.id) { bet in
                    if let teeBox = betManager.teeBox {
                        let winnings = bet.calculateWinnings(playerScores: betManager.playerScores, teeBox: teeBox)
                        BetDetailRow(
                            title: "\(bet.player1.firstName) vs \(bet.player2.firstName)",
                            subtitle: "$\(Int(bet.perHoleAmount)) per hole, $\(Int(bet.perBirdieAmount)) per birdie",
                            amount: winnings
                        )
                    }
                }
            }
        }
    }
}

private struct FourBallMatchesView: View {
    @EnvironmentObject private var betManager: BetManager
    
    var body: some View {
        if !betManager.fourBallBets.isEmpty {
            BetTypeSection(title: "Four Ball Matches", icon: "person.3") {
                ForEach(betManager.fourBallBets, id: \.id) { bet in
                    if let teeBox = betManager.teeBox {
                        let winnings = bet.calculateWinnings(playerScores: betManager.playerScores, teeBox: teeBox)
                        BetDetailRow(
                            title: "\(bet.team1Player1.firstName)/\(bet.team1Player2.firstName) vs \(bet.team2Player1.firstName)/\(bet.team2Player2.firstName)",
                            subtitle: "$\(Int(bet.perHoleAmount)) per hole, $\(Int(bet.perBirdieAmount)) per birdie",
                            amount: winnings
                        )
                    }
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
            BetTypeSection(title: "Alabama", icon: "a.circle") {
                ForEach(betManager.alabamaBets, id: \.id) { bet in
                    if let teeBox = betManager.teeBox {
                        let winnings = bet.calculateWinnings(playerScores: betManager.playerScores, teeBox: teeBox)
                        BetDetailRow(
                            title: "Teams: \(bet.teams.count)",
                            subtitle: "Front: $\(Int(bet.frontNineAmount)), Back: $\(Int(bet.backNineAmount)), Low Ball: $\(Int(bet.lowBallAmount))",
                            amount: winnings.values.reduce(0, +)
                        )
                    }
                }
            }
        }
    }
}

private struct IndividualMatchBreakdown: View {
    let player: BetComponents.Player
    @EnvironmentObject private var betManager: BetManager
    
    var body: some View {
        ForEach(betManager.individualBets.filter { bet in
            bet.player1.id == player.id || bet.player2.id == player.id
        }, id: \.id) { bet in
            let winnings = bet.calculateWinnings(
                playerScores: betManager.playerScores,
                teeBox: betManager.teeBox ?? .championship
            )
            let amount = bet.player1.id == player.id ? winnings : -winnings
            
            BetBreakdownRow(
                title: "\(bet.player1.firstName) vs \(bet.player2.firstName)",
                subtitle: "$\(Int(bet.perHoleAmount)) per hole",
                details: "$\(Int(bet.perBirdieAmount)) per birdie",
                amount: amount,
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
            let winnings = bet.calculateWinnings(
                playerScores: betManager.playerScores,
                teeBox: betManager.teeBox ?? .championship
            )
            let isTeam1 = bet.team1Player1.id == player.id || bet.team1Player2.id == player.id
            let amount = isTeam1 ? winnings / 2 : -winnings / 2
            
            BetBreakdownRow(
                title: "\(bet.team1Player1.firstName)/\(bet.team1Player2.firstName) vs \(bet.team2Player1.firstName)/\(bet.team2Player2.firstName)",
                subtitle: "$\(Int(bet.perHoleAmount)) per hole",
                details: "$\(Int(bet.perBirdieAmount)) per birdie",
                amount: amount,
                accentColor: .green
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
    
    private func getSkinsWonByHole(bet: SkinsBet, playerId: UUID) -> [Int] {
        var skinsWon: [Int] = []
        let scores = betManager.playerScores
        
        for holeIndex in 0..<18 {
            let playerScores = bet.players.compactMap { player -> (UUID, Int)? in
                let scoreStr = scores[player.id]?[holeIndex]
                if scoreStr == "X" {
                    return (player.id, (betManager.teeBox ?? .championship).holes[holeIndex].par + 4)
                }
                guard let scoreStr = scoreStr,
                      let score = Int(scoreStr) else { return nil }
                return (player.id, score)
            }
            
            guard playerScores.count == bet.players.count else { continue }
            
            let lowestScore = playerScores.min { $0.1 < $1.1 }?.1
            let playersWithLowest = playerScores.filter { $0.1 == lowestScore }
            
            if playersWithLowest.count == 1 && playersWithLowest[0].0 == playerId {
                skinsWon.append(holeIndex + 1)
            }
        }
        
        return skinsWon
    }
    
    private func getTotalSkinsCount(bet: SkinsBet) -> Int {
        var totalSkins = 0
        let scores = betManager.playerScores
        
        for holeIndex in 0..<18 {
            let playerScores = bet.players.compactMap { player -> (UUID, Int)? in
                let scoreStr = scores[player.id]?[holeIndex]
                if scoreStr == "X" {
                    return (player.id, (betManager.teeBox ?? .championship).holes[holeIndex].par + 4)
                }
                guard let scoreStr = scoreStr,
                      let score = Int(scoreStr) else { return nil }
                return (player.id, score)
            }
            
            guard playerScores.count == bet.players.count else { continue }
            
            let lowestScore = playerScores.min { $0.1 < $1.1 }?.1
            let playersWithLowest = playerScores.filter { $0.1 == lowestScore }
            
            if playersWithLowest.count == 1 {
                totalSkins += 1
            }
        }
        
        return totalSkins
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
    let player: BetComponents.Player
    @EnvironmentObject private var betManager: BetManager
    
    var body: some View {
        ForEach(betManager.alabamaBets.filter { bet in
            bet.teams.contains { team in team.contains { $0.id == player.id } }
        }, id: \.id) { bet in
            if let amount = bet.calculateWinnings(
                playerScores: betManager.playerScores,
                teeBox: betManager.teeBox ?? .championship
            )[player.id] {
                BetBreakdownRow(
                    title: "Alabama",
                    subtitle: "Front: $\(Int(bet.frontNineAmount)), Back: $\(Int(bet.backNineAmount))",
                    details: "Low Ball: $\(Int(bet.lowBallAmount)), Birdies: $\(Int(bet.perBirdieAmount))",
                    amount: amount,
                    accentColor: .purple
                )
            }
        }
    }
} 