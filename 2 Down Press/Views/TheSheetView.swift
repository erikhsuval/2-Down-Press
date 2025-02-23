import SwiftUI

struct TheSheetView: View {
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    
    var body: some View {
        List {
            if hasNoBets {
                Text("No active bets")
                    .foregroundColor(.gray)
            } else {
                // Individual Match Bets
                if !betManager.individualBets.isEmpty {
                    Section("Individual Matches") {
                        ForEach(betManager.individualBets) { bet in
                            Text("\(bet.player1.firstName) vs \(bet.player2.firstName)")
                        }
                    }
                }
                
                // Four Ball Match Bets
                if !betManager.fourBallBets.isEmpty {
                    Section("Four Ball Matches") {
                        ForEach(betManager.fourBallBets) { bet in
                            Text("\(bet.team1Player1.firstName)/\(bet.team1Player2.firstName) vs \(bet.team2Player1.firstName)/\(bet.team2Player2.firstName)")
                        }
                    }
                }
                
                // Skins Bets
                if !betManager.skinsBets.isEmpty {
                    Section("Skins") {
                        ForEach(betManager.skinsBets) { bet in
                            Text("$\(Int(bet.amount)) per player")
                        }
                    }
                }
                
                // Do-Da Bets
                if !betManager.doDaBets.isEmpty {
                    Section("Do-Da's") {
                        ForEach(betManager.doDaBets) { bet in
                            if bet.isPool {
                                Text("Pool: $\(Int(bet.amount)) per player")
                            } else {
                                Text("$\(Int(bet.amount)) per Do-Da")
                            }
                        }
                    }
                }
                
                // Alabama Bets
                if !betManager.alabamaBets.isEmpty {
                    Section("Alabama") {
                        ForEach(betManager.alabamaBets) { bet in
                            Text("$\(Int(bet.amount)) per point")
                        }
                    }
                }
            }
        }
        .navigationTitle("The Sheet")
    }
    
    private var hasNoBets: Bool {
        betManager.individualBets.isEmpty &&
        betManager.fourBallBets.isEmpty &&
        betManager.alabamaBets.isEmpty &&
        betManager.doDaBets.isEmpty &&
        betManager.skinsBets.isEmpty
    }
} 