import SwiftUI

struct PlayerBetDetailsView: View {
    let player: Player
    let betManager: BetManager
    let playerScores: [UUID: [String]]
    let teeBox: TeeBox
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Individual Matches
            ForEach(betManager.individualBets.filter { $0.player1.id == player.id || $0.player2.id == player.id }) { bet in
                HStack {
                    Text("\(bet.player1.firstName) vs \(bet.player2.firstName)")
                    Spacer()
                    let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
                    let amount = bet.player1.id == player.id ? winnings : -winnings
                    Text(String(format: "$%.0f", amount))
                        .foregroundColor(amount >= 0 ? .green : .red)
                }
            }
            
            // Four Ball Matches
            ForEach(betManager.fourBallBets.filter { 
                $0.team1Player1.id == player.id || 
                $0.team1Player2.id == player.id || 
                $0.team2Player1.id == player.id || 
                $0.team2Player2.id == player.id 
            }) { bet in
                HStack {
                    Text("\(bet.team1Player1.firstName)/\(bet.team1Player2.firstName) vs \(bet.team2Player1.firstName)/\(bet.team2Player2.firstName)")
                    Spacer()
                    let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
                    let isTeam1 = bet.team1Player1.id == player.id || bet.team1Player2.id == player.id
                    let amount = isTeam1 ? winnings : -winnings
                    Text(String(format: "$%.0f", amount))
                        .foregroundColor(amount >= 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
} 