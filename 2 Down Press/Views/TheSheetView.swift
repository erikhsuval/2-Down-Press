import SwiftUI

struct TheSheetView: View {
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    
    var body: some View {
        List {
            Group {
                if hasNoBets {
                    Text("No active bets")
                        .foregroundColor(.gray)
                } else {
                    IndividualMatchesSection(bets: betManager.individualBets)
                    FourBallMatchesSection(bets: betManager.fourBallBets)
                    SkinsSection(bets: betManager.skinsBets)
                    DoDaSection(bets: betManager.doDaBets)
                    AlabamaSection(bets: betManager.alabamaBets)
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

private struct IndividualMatchesSection: View {
    let bets: [IndividualMatchBet]
    
    var body: some View {
        if !bets.isEmpty {
            Section("Individual Matches") {
                ForEach(bets) { bet in
                    Text("\(bet.player1.firstName) vs \(bet.player2.firstName)")
                }
            }
        }
    }
}

private struct FourBallMatchesSection: View {
    let bets: [FourBallMatchBet]
    
    var body: some View {
        if !bets.isEmpty {
            Section("Four Ball Matches") {
                ForEach(bets) { bet in
                    Text("\(bet.team1Player1.firstName)/\(bet.team1Player2.firstName) vs \(bet.team2Player1.firstName)/\(bet.team2Player2.firstName)")
                }
            }
        }
    }
}

private struct SkinsSection: View {
    let bets: [SkinsBet]
    
    var body: some View {
        if !bets.isEmpty {
            Section("Skins") {
                ForEach(bets) { bet in
                    Text("$\(Int(bet.amount)) per player")
                }
            }
        }
    }
}

private struct DoDaSection: View {
    let bets: [DoDaBet]
    
    var body: some View {
        if !bets.isEmpty {
            Section("Do-Da's") {
                ForEach(bets) { bet in
                    if bet.isPool {
                        Text("Pool: $\(Int(bet.amount)) per player")
                    } else {
                        Text("$\(Int(bet.amount)) per Do-Da")
                    }
                }
            }
        }
    }
}

private struct AlabamaSection: View {
    let bets: [AlabamaBet]
    
    var body: some View {
        if !bets.isEmpty {
            Section("Alabama") {
                ForEach(bets) { bet in
                    Text("$\(Int(bet.frontNineAmount)) per point")
                }
            }
        }
    }
} 