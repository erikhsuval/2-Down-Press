import SwiftUI
import Foundation
import BetComponents

struct IndividualBetsSection: View {
    let bets: [IndividualMatchBet]
    let onDelete: (IndividualMatchBet) -> Void
    let onEdit: (IndividualMatchBet) -> Void
    
    var body: some View {
        if !bets.isEmpty {
            Section("Individual Matches") {
                ForEach(bets) { bet in
                    IndividualBetListItem(bet: bet, onDelete: onDelete, onEdit: onEdit)
                }
            }
        }
    }
}

struct IndividualBetListItem: View {
    let bet: IndividualMatchBet
    let onDelete: (IndividualMatchBet) -> Void
    let onEdit: (IndividualMatchBet) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(bet.player1.firstName) vs \(bet.player2.firstName)")
                    .font(.headline)
                Spacer()
                Image(systemName: "person.2")
                    .foregroundColor(.primaryGreen)
            }
            
            HStack {
                Text("Per Hole: $\(String(format: "%.2f", bet.perHoleAmount))")
                Spacer()
                Text("Per Birdie: $\(String(format: "%.2f", bet.perBirdieAmount))")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            if bet.pressOn9and18 {
                Text("Press on 9 & 18")
                    .font(.subheadline)
                    .foregroundColor(.primaryGreen)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete(bet)
            } label: {
                Text("Delete")
            }
            
            Button {
                onEdit(bet)
            } label: {
                Text("Edit")
            }
            .tint(.blue)
        }
    }
}

struct FourBallBetsSection: View {
    let bets: [FourBallMatchBet]
    let onDelete: (FourBallMatchBet) -> Void
    let onEdit: (FourBallMatchBet) -> Void
    
    var body: some View {
        if !bets.isEmpty {
            Section(header: Text("Four Ball Matches")) {
                ForEach(bets) { bet in
                    FourBallBetListItem(bet: bet, onDelete: onDelete, onEdit: onEdit)
                }
            }
        }
    }
}

struct FourBallBetListItem: View {
    let bet: FourBallMatchBet
    let onDelete: (FourBallMatchBet) -> Void
    let onEdit: (FourBallMatchBet) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(bet.team1Player1.firstName)/\(bet.team1Player2.firstName) vs \(bet.team2Player1.firstName)/\(bet.team2Player2.firstName)")
                    .font(.headline)
                Spacer()
                Image(systemName: "person.3")
                    .foregroundColor(.primaryGreen)
            }
            
            HStack {
                Text("Per Hole: $\(String(format: "%.2f", bet.perHoleAmount))")
                Spacer()
                Text("Per Birdie: $\(String(format: "%.2f", bet.perBirdieAmount))")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            if bet.pressOn9and18 {
                Text("Press on 9 & 18")
                    .font(.subheadline)
                    .foregroundColor(.primaryGreen)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete(bet)
            } label: {
                Text("Delete")
            }
            
            Button {
                onEdit(bet)
            } label: {
                Text("Edit")
            }
            .tint(.blue)
        }
    }
}

struct AlabamaBetsSection: View {
    let bets: [AlabamaBet]
    let onDelete: (AlabamaBet) -> Void
    let onEdit: (AlabamaBet) -> Void
    
    var body: some View {
        if !bets.isEmpty {
            Section(header: Text("Alabama Matches")) {
                ForEach(bets) { bet in
                    AlabamaBetListItem(bet: bet, onDelete: onDelete, onEdit: onEdit)
                }
            }
        }
    }
}

struct AlabamaBetListItem: View {
    let bet: AlabamaBet
    let onDelete: (AlabamaBet) -> Void
    let onEdit: (AlabamaBet) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Alabama Match")
                    .font(.headline)
                Spacer()
                Image(systemName: "person.3.sequence")
                    .foregroundColor(.primaryGreen)
            }
            
            HStack {
                Text("Front 9: $\(String(format: "%.2f", bet.frontNineAmount))")
                Spacer()
                Text("Back 9: $\(String(format: "%.2f", bet.backNineAmount))")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            Text("Per Birdie: $\(String(format: "%.2f", bet.perBirdieAmount))")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Best \(bet.countingScores) scores")
                .font(.subheadline)
                .foregroundColor(.primaryGreen)
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete(bet)
            } label: {
                Text("Delete")
            }
            
            Button {
                onEdit(bet)
            } label: {
                Text("Edit")
            }
            .tint(.blue)
        }
    }
}

struct SkinsBetsSection: View {
    let bets: [SkinsBet]
    let onDelete: (SkinsBet) -> Void
    let onEdit: (SkinsBet) -> Void
    
    var body: some View {
        if !bets.isEmpty {
            Section(header: Text("Skins")) {
                ForEach(bets) { bet in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Skins Game")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "dollarsign.circle")
                                .foregroundColor(.primaryGreen)
                        }
                        
                        Text("Entry Amount: $\(String(format: "%.2f", bet.amount))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            onDelete(bet)
                        } label: {
                            Text("Delete")
                        }
                        
                        Button {
                            onEdit(bet)
                        } label: {
                            Text("Edit")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
    }
}

struct DoDaBetsSection: View {
    let bets: [DoDaBet]
    let onDelete: (DoDaBet) -> Void
    let onEdit: (DoDaBet) -> Void
    
    var body: some View {
        if !bets.isEmpty {
            Section("Do-Da's") {
                ForEach(bets) { bet in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(bet.isPool ? "Pool" : "Per Do-Da")
                                .font(.headline)
                            Text(String(format: "$%.2f", bet.amount))
                                .foregroundColor(.primaryGreen)
                        }
                        
                        Spacer()
                        
                        Button(action: { onEdit(bet) }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.primaryGreen)
                        }
                        
                        Button(action: { onDelete(bet) }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
}

enum TeamPlayerSelection {
    case team1Player1
    case team1Player2
    case team2Player1
    case team2Player2
}

struct MultiPlayerSelectionView: View {
    @Binding var selectedPlayers: [BetComponents.Player]
    let requiredCount: Int
    let onComplete: ([BetComponents.Player]) -> Void
    let allPlayers: [BetComponents.Player]
    let excludedPlayers: [BetComponents.Player]
    let teamName: String
    let teamColor: Color
    let isFlexible: Bool
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfile: UserProfile
    
    var displayPlayers: [BetComponents.Player] {
        var players = allPlayers
        // Add current user if available and not already in the list
        if let currentUser = userProfile.currentUser,
           !players.contains(where: { $0.id == currentUser.id }) {
            players.insert(currentUser, at: 0)
        }
        // Filter out excluded players
        return players.filter { player in
            !excludedPlayers.contains { $0.id == player.id }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(displayPlayers) { player in
                    Button(action: {
                        if selectedPlayers.contains(where: { $0.id == player.id }) {
                            selectedPlayers.removeAll { $0.id == player.id }
                        } else if selectedPlayers.count < requiredCount {
                            selectedPlayers.append(player)
                        }
                    }) {
                        HStack {
                            Text(player.firstName + " " + player.lastName)
                            Spacer()
                            if selectedPlayers.contains(where: { $0.id == player.id }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(teamColor)
                            } else if selectedPlayers.count >= requiredCount {
                                // Show disabled state when max players reached
                                Text("Max")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .disabled(!selectedPlayers.contains(where: { $0.id == player.id }) && selectedPlayers.count >= requiredCount)
                }
            }
            .navigationTitle("Select \(teamName) Players")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Done") {
                    if isFlexible ? selectedPlayers.count >= 2 : selectedPlayers.count == requiredCount {
                        onComplete(selectedPlayers)
                        dismiss()
                    }
                }
                .disabled(isFlexible ? selectedPlayers.count < 2 : selectedPlayers.count != requiredCount)
            )
        }
    }
}

struct SkinsBetRow: View {
    let bet: SkinsBet
    let player: BetComponents.Player
    let playerScores: [UUID: [String]]
    let teeBox: BetComponents.TeeBox
    
    var betAmount: Double {
        let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
        return winnings[player.id] ?? 0
    }
    
    var wonSkinHoles: [Int] {
        var holes: [Int] = []
        
        // Only include players who have scores
        let activePlayers = bet.players.filter { playerScores.keys.contains($0.id) }
        
        // For each hole
        for holeIndex in 0..<18 {
            // Get valid scores for this hole
            var holeScores: [(playerId: UUID, score: Int)] = []
            for betPlayer in activePlayers {
                if let score = Int(playerScores[betPlayer.id]?[holeIndex] ?? "") {
                    holeScores.append((betPlayer.id, score))
                }
            }
            
            // Skip hole if not all players have scores
            guard holeScores.count == activePlayers.count else { continue }
            
            // Find lowest score for the hole
            let lowestScore = holeScores.min { $0.score < $1.score }?.score
            guard let lowestScore = lowestScore else { continue }
            
            // Count how many players have the lowest score
            let playersWithLowestScore = holeScores.filter { $0.score == lowestScore }
            
            // If only one player has the lowest score and it's our player, they won this skin
            if playersWithLowestScore.count == 1 && playersWithLowestScore[0].playerId == player.id {
                holes.append(holeIndex + 1)
            }
        }
        
        return holes
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if wonSkinHoles.isEmpty {
                    Text("No skins won")
                        .fontWeight(.medium)
                } else {
                    Text("Won skins on holes: \(wonSkinHoles.map(String.init).joined(separator: ", "))")
                        .fontWeight(.medium)
                }
                Spacer()
                Text(String(format: "$%.2f", betAmount))
                    .foregroundColor(betAmount >= 0 ? .green : .red)
                    .fontWeight(.semibold)
            }
            
            Text("\(bet.players.count) players")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
} 
