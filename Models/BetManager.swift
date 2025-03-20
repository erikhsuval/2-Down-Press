class BetManager: ObservableObject {
    @Published var individualBets: [IndividualBet] = []
    @Published var fourBallBets: [FourBallBet] = []
    @Published var alabamaBets: [AlabamaBet] = []
    @Published var doDaBets: [DoDaBet] = []
    @Published var skinsBets: [SkinsBet] = []
    @Published var groupScores: [Int: [UUID: [String]]] = [:]
    @Published var teeBox: BetComponents.TeeBox?
    
    func calculateTotalWinnings(player: BetComponents.Player, playerScores: [UUID: [String]], teeBox: BetComponents.TeeBox) -> Double {
        var total = 0.0
        
        // Calculate individual bet winnings
        for bet in individualBets {
            let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
            if bet.player1.id == player.id {
                total += winnings
            } else if bet.player2.id == player.id {
                total -= winnings
            }
        }
        
        // Calculate four ball bet winnings
        for bet in fourBallBets {
            let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
            if bet.team1Player1.id == player.id || bet.team1Player2.id == player.id {
                total += winnings / 2
            } else if bet.team2Player1.id == player.id || bet.team2Player2.id == player.id {
                total -= winnings / 2
            }
        }
        
        // Calculate skins bet winnings
        for bet in skinsBets {
            if let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
                total += winnings
            }
        }
        
        // Calculate Do-Da bet winnings
        for bet in doDaBets {
            if let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
                total += winnings
            }
        }
        
        // Calculate Alabama bet winnings
        for bet in alabamaBets {
            if let teamIndex = bet.teams.firstIndex(where: { team in team.contains { $0.id == player.id } }) {
                for otherTeamIndex in bet.teams.indices where otherTeamIndex != teamIndex {
                    let results = bet.calculateTeamResults(
                        playerTeamIndex: teamIndex,
                        otherTeamIndex: otherTeamIndex,
                        scores: playerScores,
                        teeBox: teeBox
                    )
                    total += results.total
                }
            }
        }
        
        return total
    }

    func clearAllBets() {
        individualBets.removeAll()
        fourBallBets.removeAll()
        alabamaBets.removeAll()
        doDaBets.removeAll()
        skinsBets.removeAll()
        groupScores.removeAll()
        teeBox = nil
    }
} 