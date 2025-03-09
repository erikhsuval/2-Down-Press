// Calculate individual bet winnings
for bet in betManager.individualBets {
    let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
    if bet.player1.id == player.id {
        total += winnings
    } else if bet.player2.id == player.id {
        total -= winnings
    }
}

// Calculate four ball bet winnings
for bet in betManager.fourBallBets {
    let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
    if bet.team1Player1.id == player.id || bet.team1Player2.id == player.id {
        total += winnings
    } else if bet.team2Player1.id == player.id || bet.team2Player2.id == player.id {
        total -= winnings
    }
}

// Calculate skins bet winnings
for bet in betManager.skinsBets {
    if bet.players.contains(where: { $0.id == player.id }) {
        if let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
            total += winnings
        }
    }
}

private func calculateWinnings(for player: BetComponents.Player) -> Double {
    guard let teeBox = betManager.teeBox else { return 0 }
    var total = 0.0
    
    // Calculate individual bet winnings
    for bet in betManager.individualBets {
        let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
        if bet.player1.id == player.id {
            total += winnings
        } else if bet.player2.id == player.id {
            total -= winnings
        }
    }
    
    // Calculate four ball bet winnings
    for bet in betManager.fourBallBets {
        let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
        if bet.team1Player1.id == player.id || bet.team1Player2.id == player.id {
            total += winnings
        } else if bet.team2Player1.id == player.id || bet.team2Player2.id == player.id {
            total -= winnings
        }
    }
    
    // Calculate skins bet winnings
    for bet in betManager.skinsBets {
        if bet.players.contains(where: { $0.id == player.id }) {
            if let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
                total += winnings
            }
        }
    }
    
    // Calculate Do-Da bet winnings
    for bet in betManager.doDaBets {
        if bet.players.contains(where: { $0.id == player.id }) {
            if let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
                total += winnings
            }
        }
    }
    
    // Calculate Alabama bet winnings
    for bet in betManager.alabamaBets {
        if let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
            total += winnings
        }
    }
    
    // Calculate putting with puff bet winnings
    for bet in betManager.puttingWithPuffBets {
        if bet.players.contains(where: { $0.id == player.id }) {
            total += bet.playerTotals[player.id] ?? 0
        }
    }
    
    return total.rounded(to: 2)
} 