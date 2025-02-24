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
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        Button(action: { onEdit(bet) }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
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

struct BetTypeSection<Content: View>: View {
    let title: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            content()
                .padding(.horizontal)
        }
    }
}

struct PlayerSelectionButton: View {
    let title: String
    let playerName: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(playerName)
                    .font(.headline)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3))
        )
    }
}

enum TeamPlayerSelection {
    case team1Player1
    case team1Player2
    case team2Player1
    case team2Player2
}

struct MultiPlayerSelectionView: View {
    @Binding var selectedPlayers: [Player]
    let requiredCount: Int
    let onComplete: ([Player]) -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfile: UserProfile
    
    var allPlayers: [Player] {
        var players = MockData.allPlayers
        if let currentUser = userProfile.currentUser {
            players.insert(currentUser, at: 0)
        }
        return players
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(allPlayers) { player in
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
                                    .foregroundColor(.primaryGreen)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Players")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Done") {
                    if selectedPlayers.count == requiredCount {
                        onComplete(selectedPlayers)
                        dismiss()
                    }
                }
                .disabled(selectedPlayers.count != requiredCount)
            )
        }
    }
}

struct DoDaSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    let editingBet: DoDaBet?
    
    @State private var isPool = false
    @State private var amount = ""
    
    init(editingBet: DoDaBet? = nil) {
        self.editingBet = editingBet
        _isPool = State(initialValue: editingBet?.isPool ?? false)
        _amount = State(initialValue: editingBet != nil ? String(editingBet!.amount) : "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Type")) {
                    Picker("Type", selection: $isPool) {
                        Text("Per Do-Da").tag(false)
                        Text("Pool").tag(true)
                    }
                }
                
                Section(header: Text("Amount")) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(editingBet != nil ? "Edit Do-Da" : "New Do-Da")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editingBet != nil ? "Update" : "Create") {
                        createBet()
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !amount.isEmpty && (Double(amount) ?? 0) > 0
    }
    
    private func createBet() {
        guard let amountValue = Double(amount) else { return }
        
        if let existingBet = editingBet {
            betManager.deleteDoDaBet(existingBet)
        }
        
        betManager.addDoDaBet(
            amount: amountValue,
            isPool: isPool
        )
    }
}

struct SkinsBetRow: View {
    let bet: SkinsBet
    let player: Player
    let playerScores: [UUID: [String]]
    let teeBox: TeeBox
    
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

struct PlayerBetDetailsView: View {
    let player: Player
    let betManager: BetManager
    let playerScores: [UUID: [String]]
    let teeBox: TeeBox
    
    var skinsBets: [SkinsBet] {
        print("Checking skins bets for player: \(player.firstName)") // Debug print
        print("Total skins bets in betManager: \(betManager.skinsBets.count)") // Debug print
        let bets = betManager.skinsBets.filter { bet in
            let isInBet = bet.players.contains { $0.id == player.id }
            print("Bet \(bet.id): player \(player.firstName) is in bet: \(isInBet)") // Debug print
            return isInBet
        }
        print("Found \(bets.count) skins bets for player \(player.firstName)")
        return bets
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Individual Match Bets
            let individualBets = betManager.individualBets.filter { 
                $0.player1.id == player.id || $0.player2.id == player.id 
            }
            if !individualBets.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Individual Matches")
                        .font(.headline)
                    ForEach(individualBets) { bet in
                        IndividualBetRow(bet: bet, player: player)
                    }
                }
            }
            
            // Four Ball Match Bets
            let fourBallBets = betManager.fourBallBets.filter { bet in
                bet.team1Player1.id == player.id ||
                bet.team1Player2.id == player.id ||
                bet.team2Player1.id == player.id ||
                bet.team2Player2.id == player.id
            }
            if !fourBallBets.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Four Ball Matches")
                        .font(.headline)
                    ForEach(fourBallBets) { bet in
                        FourBallBetRow(bet: bet, player: player)
                    }
                }
            }
            
            // Alabama Bets
            let alabamaBets = betManager.alabamaBets.filter { bet in
                bet.teams.contains { team in
                    team.contains { $0.id == player.id }
                }
            }
            if !alabamaBets.isEmpty {
        VStack(alignment: .leading, spacing: 8) {
                    Text("Alabama Games")
                        .font(.headline)
                    ForEach(alabamaBets) { bet in
                        AlabamaBetSummaryRow(bet: bet, player: player)
                    }
                }
            }
            
            // Do-Da Bets
            let doDaBets = betManager.doDaBets.filter { bet in
                bet.players.contains { $0.id == player.id }
            }
            if !doDaBets.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Do-Da's")
                        .font(.headline)
                    ForEach(doDaBets) { bet in
                        DoDaBetRow(bet: bet, player: player, playerScores: playerScores, teeBox: teeBox)
                    }
                }
            }
            
            // Skins Bets
            if !skinsBets.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Skins")
                        .font(.headline)
                    ForEach(skinsBets) { bet in
                        SkinsBetRow(bet: bet, player: player, playerScores: playerScores, teeBox: teeBox)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
    }
} 
