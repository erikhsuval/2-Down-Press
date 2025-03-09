import SwiftUI
import BetComponents

struct PlayerBetDetailsView: View {
    let player: BetComponents.Player
    let betManager: BetComponents.BetManager
    let playerScores: [UUID: [String]]
    let teeBox: BetComponents.TeeBox
    
    private var individualBets: [IndividualMatchBet] {
        betManager.individualBets.filter { bet in
            bet.player1.id == player.id || bet.player2.id == player.id
        }
    }
    
    private var fourBallBets: [FourBallMatchBet] {
        betManager.fourBallBets.filter { bet in
            [bet.team1Player1.id, bet.team1Player2.id,
             bet.team2Player1.id, bet.team2Player2.id].contains(player.id)
        }
    }
    
    private var skinsBets: [SkinsBet] {
        betManager.skinsBets.filter { bet in
            bet.players.contains { $0.id == player.id }
        }
    }
    
    private var doDaBets: [DoDaBet] {
        betManager.doDaBets.filter { bet in
            bet.players.contains { $0.id == player.id }
        }
    }
    
    private var alabamaBets: [AlabamaBet] {
        betManager.alabamaBets.filter { bet in
            bet.teams.contains { team in team.contains { $0.id == player.id } }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Individual Matches
            if !individualBets.isEmpty {
                Text("Individual Matches")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                ForEach(individualBets) { bet in
                    HStack {
                        Text("\(bet.player1.firstName) vs \(bet.player2.firstName)")
                        Spacer()
                        let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
                        let amount = bet.player1.id == player.id ? winnings : -winnings
                        Text(String(format: "$%.0f", amount))
                            .foregroundColor(amount >= 0 ? .primaryGreen : .red)
                    }
                }
            }
            
            // Four Ball Matches
            if !fourBallBets.isEmpty {
                Text("Four Ball Matches")
                    .font(.headline)
                    .padding(.vertical, 4)
                
                ForEach(fourBallBets) { bet in
                    HStack {
                        Text("\(bet.team1Player1.firstName)/\(bet.team1Player2.firstName) vs \(bet.team2Player1.firstName)/\(bet.team2Player2.firstName)")
                        Spacer()
                        let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
                        let isTeam1 = bet.team1Player1.id == player.id || bet.team1Player2.id == player.id
                        let amount = isTeam1 ? winnings / 2 : -winnings / 2
                        Text(String(format: "$%.0f", amount))
                            .foregroundColor(amount >= 0 ? .primaryGreen : .red)
                    }
                }
            }
            
            // Skins
            if !skinsBets.isEmpty {
                Text("Skins")
                    .font(.headline)
                    .padding(.vertical, 4)
                
                ForEach(skinsBets) { bet in
                    HStack {
                        Text("$\(Int(bet.amount)) per player")
                        Spacer()
                        if let amount = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
                            Text(String(format: "$%.0f", amount))
                                .foregroundColor(amount >= 0 ? .primaryGreen : .red)
                        }
                    }
                }
            }
            
            // Do-Da's
            if !doDaBets.isEmpty {
                Text("Do-Da's")
                    .font(.headline)
                    .padding(.vertical, 4)
                
                ForEach(doDaBets) { bet in
                    HStack {
                        Text(bet.isPool ? "Pool" : "Per Do-Da")
                        Text("$\(Int(bet.amount)) \(bet.isPool ? "per player" : "per Do-Da")")
                        Spacer()
                        if let amount = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
                            Text(String(format: "$%.0f", amount))
                                .foregroundColor(amount >= 0 ? .primaryGreen : .red)
                        }
                    }
                }
            }
            
            // Alabama
            if !alabamaBets.isEmpty {
                Text("Alabama")
                    .font(.headline)
                    .padding(.vertical, 4)
                
                ForEach(alabamaBets) { bet in
                    HStack {
                        Text("Front: $\(Int(bet.frontNineAmount)) Back: $\(Int(bet.backNineAmount))")
                        Spacer()
                        if let amount = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
                            Text(String(format: "$%.0f", amount))
                                .foregroundColor(amount >= 0 ? .primaryGreen : .red)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
} 