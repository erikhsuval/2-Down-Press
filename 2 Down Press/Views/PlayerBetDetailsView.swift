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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Individual Matches
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
            
            // Four Ball Matches
            ForEach(fourBallBets) { bet in
                HStack {
                    Text("\(bet.team1Player1.firstName)/\(bet.team1Player2.firstName) vs \(bet.team2Player1.firstName)/\(bet.team2Player2.firstName)")
                    Spacer()
                    let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
                    let isTeam1 = bet.team1Player1.id == player.id || bet.team1Player2.id == player.id
                    let amount = isTeam1 ? winnings : -winnings
                    Text(String(format: "$%.0f", amount))
                        .foregroundColor(amount >= 0 ? .primaryGreen : .red)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
} 