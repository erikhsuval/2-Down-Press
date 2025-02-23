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
                    IndividualBetRow(bet: bet, onDelete: onDelete, onEdit: onEdit)
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

struct MyBetsView: View {
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    @State private var showEditIndividualBet = false
    @State private var showEditFourBallBet = false
    @State private var showEditAlabamaBet = false
    @State private var showEditDoDaBet = false
    @State private var showEditSkinsBet = false
    @State private var showNewSkinsBet = false
    @State private var showNewIndividualBet = false
    @State private var showNewFourBallBet = false
    @State private var showNewAlabamaBet = false
    @State private var showNewDoDaBet = false
    @State private var betToEdit: Any? = nil
    
    var myIndividualBets: [IndividualMatchBet] {
        guard let currentUser = userProfile.currentUser else { return [] }
        return betManager.individualBets.filter { bet in
            bet.player1.id == currentUser.id || bet.player2.id == currentUser.id
        }
    }
    
    var myFourBallBets: [FourBallMatchBet] {
        guard let currentUser = userProfile.currentUser else { return [] }
        return betManager.fourBallBets.filter { bet in
            bet.team1Player1.id == currentUser.id || 
            bet.team1Player2.id == currentUser.id ||
            bet.team2Player1.id == currentUser.id || 
            bet.team2Player2.id == currentUser.id
        }
    }
    
    var myAlabamaBets: [AlabamaBet] {
        guard let currentUser = userProfile.currentUser else { return [] }
        return betManager.alabamaBets.filter { bet in
            bet.teams.contains { team in
                team.contains { player in
                    player.id == currentUser.id
                }
            }
        }
    }
    
    var myDoDaBets: [DoDaBet] {
        guard let currentUser = userProfile.currentUser else { return [] }
        return betManager.doDaBets.filter { bet in
            bet.players.contains { $0.id == currentUser.id }
        }
    }
    
    var mySkinsBets: [SkinsBet] {
        guard let currentUser = userProfile.currentUser else { return [] }
        return betManager.skinsBets.filter { bet in
            bet.players.contains { $0.id == currentUser.id }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                IndividualBetsSection(
                    bets: myIndividualBets,
                    onDelete: { bet in
                        betManager.deleteIndividualBet(bet)
                    },
                    onEdit: { bet in
                        betToEdit = bet
                        showEditIndividualBet = true
                    }
                )
                
                FourBallBetsSection(
                    bets: myFourBallBets,
                    onDelete: { bet in
                        betManager.deleteFourBallBet(bet)
                    },
                    onEdit: { bet in
                        betToEdit = bet
                        showEditFourBallBet = true
                    }
                )
                
                AlabamaBetsSection(
                    bets: myAlabamaBets,
                    onDelete: { bet in
                        betManager.deleteAlabamaBet(bet)
                    },
                    onEdit: { bet in
                        betToEdit = bet
                        showEditAlabamaBet = true
                    }
                )
                
                SkinsBetsSection(
                    bets: mySkinsBets,
                    onDelete: { bet in
                        betManager.deleteSkinsBet(bet)
                    },
                    onEdit: { bet in
                        betToEdit = bet
                        showEditSkinsBet = true
                    }
                )
                
                DoDaBetsSection(
                    bets: myDoDaBets,
                    onDelete: { bet in
                        betManager.deleteDoDaBet(bet)
                    },
                    onEdit: { bet in
                        betToEdit = bet
                        showEditDoDaBet = true
                    }
                )
                
                if myIndividualBets.isEmpty && myFourBallBets.isEmpty && 
                   myAlabamaBets.isEmpty && myDoDaBets.isEmpty && mySkinsBets.isEmpty {
                    Text("No active bets")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("My Bets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            print("Skins bet tapped directly")
                            showNewSkinsBet = true
                        }) {
                            Image(systemName: "dollarsign.circle")
                        }
                        
                        Menu {
                            Button(action: { showNewIndividualBet = true }) {
                                Label("Individual Match", systemImage: "person.2")
                            }
                            Button(action: { showNewFourBallBet = true }) {
                                Label("Four-Ball Match", systemImage: "person.3")
                            }
                            Button(action: { showNewAlabamaBet = true }) {
                                Label("Alabama Game", systemImage: "person.3.sequence")
                            }
                            Button(action: { showNewDoDaBet = true }) {
                                Label("Do-Da", systemImage: "2.circle")
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showNewSkinsBet) {
                NavigationStack {
                    SkinsSetupView()
                        .environmentObject(betManager)
                        .environmentObject(userProfile)
                }
            }
            .sheet(isPresented: $showNewIndividualBet) {
                NavigationView {
                    IndividualMatchSetupView()
                        .environmentObject(betManager)
                        .environmentObject(userProfile)
                }
            }
            .sheet(isPresented: $showNewFourBallBet) {
                NavigationView {
                    FourBallMatchSetupView()
                        .environmentObject(betManager)
                        .environmentObject(userProfile)
                }
            }
            .sheet(isPresented: $showNewAlabamaBet) {
                NavigationView {
                    AlabamaSetupView()
                        .environmentObject(betManager)
                        .environmentObject(userProfile)
                }
            }
            .sheet(isPresented: $showNewDoDaBet) {
                NavigationView {
                    DoDaSetupView()
                        .environmentObject(betManager)
                        .environmentObject(userProfile)
                }
            }
            .sheet(isPresented: $showEditIndividualBet, onDismiss: {
                betToEdit = nil
                showEditIndividualBet = false
            }) {
                if let bet = betToEdit as? IndividualMatchBet {
                    NavigationView {
                        IndividualMatchSetupView(editingBet: bet)
                            .environmentObject(betManager)
                            .environmentObject(userProfile)
                            .interactiveDismissDisabled()
                    }
                }
            }
            .sheet(isPresented: $showEditFourBallBet, onDismiss: {
                betToEdit = nil
                showEditFourBallBet = false
            }) {
                if let bet = betToEdit as? FourBallMatchBet {
                    NavigationView {
                        FourBallMatchSetupView(editingBet: bet)
                            .environmentObject(betManager)
                            .environmentObject(userProfile)
                            .interactiveDismissDisabled()
                    }
                }
            }
            .sheet(isPresented: $showEditAlabamaBet, onDismiss: {
                betToEdit = nil
                showEditAlabamaBet = false
            }) {
                if let bet = betToEdit as? AlabamaBet {
                    NavigationView {
                        AlabamaSetupView(editingBet: bet)
                            .environmentObject(betManager)
                            .environmentObject(userProfile)
                            .interactiveDismissDisabled()
                    }
                }
            }
            .sheet(isPresented: $showEditDoDaBet, onDismiss: {
                betToEdit = nil
                showEditDoDaBet = false
            }) {
                if let bet = betToEdit as? DoDaBet {
                    NavigationView {
                        DoDaSetupView(editingBet: bet)
                            .environmentObject(betManager)
                            .environmentObject(userProfile)
                            .interactiveDismissDisabled()
                    }
                }
            }
            .sheet(isPresented: $showEditSkinsBet, onDismiss: {
                betToEdit = nil
                showEditSkinsBet = false
            }) {
                if let bet = betToEdit as? SkinsBet {
                    NavigationView {
                        SkinsSetupView(editingBet: bet, players: bet.players)
                            .environmentObject(betManager)
                            .environmentObject(userProfile)
                            .interactiveDismissDisabled()
                    }
                }
            }
        }
    }
}

struct TheSheetView: View {
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    private var defaultTeeBox: TeeBox {
        // First try to get teeBox from any posted bet
        if let firstBet = betManager.individualBets.first, let teeBox = firstBet.teeBox {
            return teeBox
        }
        if let firstBet = betManager.fourBallBets.first, let teeBox = firstBet.teeBox {
            return teeBox
        }
        if let firstBet = betManager.alabamaBets.first, let teeBox = firstBet.teeBox {
            return teeBox
        }
        if let firstBet = betManager.doDaBets.first, let teeBox = firstBet.teeBox {
            return teeBox
        }
        
        // Fallback to default if no posted bets
        let holes = (0..<18).map { i in 
            HoleInfo(
                id: UUID(),
                number: i + 1,
                par: 4,
                yardage: 400,
                handicap: i + 1
            )
        }
        return TeeBox(
            id: UUID(),
            name: "Default",
            rating: 72.0,
            slope: 113,
            holes: holes
        )
    }
    
    private var playerBalances: [UUID: Double] {
        var balances: [UUID: Double] = [:]
        
        // Get all players involved in bets
        var allPlayers = Set<Player>()
        for bet in betManager.individualBets {
            allPlayers.insert(bet.player1)
            allPlayers.insert(bet.player2)
        }
        for bet in betManager.fourBallBets {
            allPlayers.insert(bet.team1Player1)
            allPlayers.insert(bet.team1Player2)
            allPlayers.insert(bet.team2Player1)
            allPlayers.insert(bet.team2Player2)
        }
        for bet in betManager.alabamaBets {
            for team in bet.teams {
                allPlayers.formUnion(team)
            }
            if let swingMan = bet.swingMan {
                allPlayers.insert(swingMan)
            }
        }
        for bet in betManager.doDaBets {
            allPlayers.formUnion(bet.players)
        }
        for bet in betManager.skinsBets {
            allPlayers.formUnion(bet.players)
        }
        
        // Calculate balances for individual bets
        for bet in betManager.individualBets {
            if let scores = bet.playerScores {  // Only calculate if scores are available (bet is posted)
                let winnings = bet.calculateWinnings(playerScores: scores, teeBox: bet.teeBox ?? defaultTeeBox)
                balances[bet.player1.id, default: 0] += winnings
                balances[bet.player2.id, default: 0] -= winnings
            }
        }
        
        // Calculate balances for four ball bets
        for bet in betManager.fourBallBets {
            if let scores = bet.playerScores {  // Only calculate if scores are available (bet is posted)
                let winnings = bet.calculateWinnings(playerScores: scores, teeBox: bet.teeBox ?? defaultTeeBox)
                balances[bet.team1Player1.id, default: 0] += winnings
                balances[bet.team1Player2.id, default: 0] += winnings
                balances[bet.team2Player1.id, default: 0] -= winnings
                balances[bet.team2Player2.id, default: 0] -= winnings
            }
        }
        
        // Calculate balances for alabama bets
        for bet in betManager.alabamaBets {
            if let scores = bet.playerScores {  // Only calculate if scores are available (bet is posted)
                let winnings = bet.calculateWinnings(playerScores: scores, teeBox: bet.teeBox ?? defaultTeeBox)
                for (playerId, amount) in winnings {
                    balances[playerId, default: 0] += amount
                }
            }
        }
        
        // Calculate balances for do-da bets
        for bet in betManager.doDaBets {
            if let scores = bet.playerScores {  // Only calculate if scores are available (bet is posted)
                let winnings = bet.calculateWinnings(playerScores: scores, teeBox: bet.teeBox ?? defaultTeeBox)
                for (playerId, amount) in winnings {
                    balances[playerId, default: 0] += amount
                }
            }
        }
        
        // Calculate balances for skins bets
        for bet in betManager.skinsBets {
            if let scores = bet.playerScores {  // Only calculate if scores are available (bet is posted)
                let winnings = bet.calculateWinnings(playerScores: scores, teeBox: bet.teeBox ?? defaultTeeBox)
                for (playerId, amount) in winnings {
                    balances[playerId, default: 0] += amount
                }
            }
        }
        
        return balances
    }
    
    private var totalWinnings: Double {
        playerBalances.values.filter { $0 > 0 }.reduce(0, +)
    }
    
    private var totalLosses: Double {
        playerBalances.values.filter { $0 < 0 }.reduce(0, +)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    SummaryCard(totalWinnings: totalWinnings, totalLosses: totalLosses)
                    
                    PlayerBalancesSection(
                        balances: playerBalances,
                        getPlayer: { id in
                            // First check if it's the current user
                            if let currentUser = userProfile.currentUser, currentUser.id == id {
                                return currentUser
                            }
                            // Then check MockData.allPlayers
                            return MockData.allPlayers.first { $0.id == id }
                        }
                    )
                }
                .padding()
            }
            .navigationTitle("The Sheet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SummaryCard: View {
    let totalWinnings: Double
    let totalLosses: Double
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Total Wins:")
                    .font(.title3)
                    .fontWeight(.medium)
                Spacer()
                Text(String(format: "$%.2f", totalWinnings))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Total Losses:")
                    .font(.title3)
                    .fontWeight(.medium)
                Spacer()
                Text(String(format: "$%.2f", abs(totalLosses)))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct PlayerBalancesSection: View {
    let balances: [UUID: Double]
    let getPlayer: (UUID) -> Player?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Player Balances")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ForEach(balances.sorted(by: { $0.value > $1.value }), id: \.key) { playerId, balance in
                if let player = getPlayer(playerId) {
                    PlayerBalanceRow(player: player, balance: balance)
                }
            }
        }
    }
}

struct PlayerBalanceRow: View {
    let player: Player
    let balance: Double
    @State private var isExpanded = false
    @EnvironmentObject private var betManager: BetManager
    
    private func getIndividualBets() -> [IndividualMatchBet] {
        betManager.individualBets.filter { 
            $0.player1.id == player.id || $0.player2.id == player.id 
        }
    }
    
    private func getFourBallBets() -> [FourBallMatchBet] {
        betManager.fourBallBets.filter { bet in
            bet.team1Player1.id == player.id ||
            bet.team1Player2.id == player.id ||
            bet.team2Player1.id == player.id ||
            bet.team2Player2.id == player.id
        }
    }
    
    private func getAlabamaBets() -> [AlabamaBet] {
        betManager.alabamaBets.filter { bet in
            bet.teams.contains { team in 
                team.contains { $0.id == player.id }
            }
        }
    }
    
    private func getDoDaBets() -> [DoDaBet] {
        betManager.doDaBets.filter { bet in
            bet.players.contains { $0.id == player.id }
        }
    }
    
    private func getSkinsBets() -> [SkinsBet] {
        betManager.skinsBets.filter { bet in
            bet.players.contains { $0.id == player.id }
        }
    }
    
    var body: some View {
        VStack {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(player.firstName + " " + player.lastName)
                        .font(.title3)
                    Spacer()
                    Text(String(format: "$%.2f", balance))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(balance >= 0 ? .green : .red)
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut, value: isExpanded)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    let individualBets = getIndividualBets()
                    if !individualBets.isEmpty {
                        BetTypeSection(title: "Individual Matches") {
                            ForEach(individualBets) { bet in
                                IndividualBetRow(bet: bet, player: player)
                            }
                        }
                    }
                    
                    let fourBallBets = getFourBallBets()
                    if !fourBallBets.isEmpty {
                        BetTypeSection(title: "Four Ball Matches") {
                            ForEach(fourBallBets) { bet in
                                FourBallBetRow(bet: bet, player: player)
                            }
                        }
                    }
                    
                    let alabamaBets = getAlabamaBets()
                    if !alabamaBets.isEmpty {
                        BetTypeSection(title: "Alabama Games") {
                            ForEach(alabamaBets) { bet in
                                AlabamaBetSummaryRow(bet: bet, player: player)
                            }
                        }
                    }
                    
                    let doDaBets = getDoDaBets()
                    if !doDaBets.isEmpty {
                        BetTypeSection(title: "Do-Da's") {
                            ForEach(doDaBets) { bet in
                                if let scores = bet.playerScores,
                                   let teeBox = bet.teeBox {
                                    DoDaBetRow(
                                        bet: bet,
                                        player: player,
                                        playerScores: scores,
                                        teeBox: teeBox
                                    )
                                }
                            }
                        }
                    }
                    
                    let skinsBets = getSkinsBets()
                    if !skinsBets.isEmpty {
                        BetTypeSection(title: "Skins") {
                            ForEach(skinsBets) { bet in
                                if let scores = bet.playerScores,
                                   let teeBox = bet.teeBox {
                                    SkinsBetRow(
                                        bet: bet,
                                        player: player,
                                        playerScores: scores,
                                        teeBox: teeBox
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
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

struct AlabamaBetSummaryRow: View {
    let bet: AlabamaBet
    let player: Player
    @EnvironmentObject private var betManager: BetManager
    
    var playerTeamIndex: Int? {
        bet.teams.firstIndex(where: { team in
            team.contains(where: { $0.id == player.id })
        })
    }
    
    struct TeamResult {
        let teamIndex: Int
        let frontNineAlabama: Double
        let backNineAlabama: Double
        let frontNineLowBall: Double
        let backNineLowBall: Double
        let birdies: Double
        
        var total: Double {
            frontNineAlabama + backNineAlabama + frontNineLowBall + backNineLowBall + birdies
        }
    }
    
    var teamResults: [TeamResult] {
        guard let scores = bet.playerScores,
              let teeBox = bet.teeBox,
              let ourTeamIndex = playerTeamIndex else { return [] }
        
        var results: [TeamResult] = []
        
        // For each team (except our own)
        for otherTeamIndex in 0..<bet.teams.count where otherTeamIndex != ourTeamIndex {
            // Get team scores
            let ourTeamScores = bet.teams[ourTeamIndex].compactMap { player in
                scores[player.id]
            }
            let otherTeamScores = bet.teams[otherTeamIndex].compactMap { player in
                scores[player.id]
            }
            
            // Skip if either team is missing scores
            guard !ourTeamScores.isEmpty && !otherTeamScores.isEmpty else { continue }
            
            var frontNineAlabama = 0.0
            var backNineAlabama = 0.0
            var frontNineLowBall = 0.0
            var backNineLowBall = 0.0
            var birdiesDiff = 0
            
            // Front Nine (0-8)
            var ourFrontNineTotal = 0
            var theirFrontNineTotal = 0
            var ourFrontNineLowBall = 0
            var theirFrontNineLowBall = 0
            
            for hole in 0..<9 {
                // Get valid scores for this hole
                let ourHoleScores = ourTeamScores.compactMap { scores in
                    hole < scores.count ? Int(scores[hole]) : nil
                }.sorted()
                let theirHoleScores = otherTeamScores.compactMap { scores in
                    hole < scores.count ? Int(scores[hole]) : nil
                }.sorted()
                
                // Alabama scoring (best N scores)
                let ourBestN = Array(ourHoleScores.prefix(bet.countingScores))
                let theirBestN = Array(theirHoleScores.prefix(bet.countingScores))
                
                ourFrontNineTotal += ourBestN.reduce(0, +)
                theirFrontNineTotal += theirBestN.reduce(0, +)
                
                // Low ball
                if let ourLow = ourHoleScores.first,
                   let theirLow = theirHoleScores.first {
                    ourFrontNineLowBall += ourLow
                    theirFrontNineLowBall += theirLow
                }
                
                // Count birdies
                let par = teeBox.holes[hole].par
                birdiesDiff += ourHoleScores.filter { $0 < par }.count
                birdiesDiff -= theirHoleScores.filter { $0 < par }.count
            }
            
            // Back Nine (9-17)
            var ourBackNineTotal = 0
            var theirBackNineTotal = 0
            var ourBackNineLowBall = 0
            var theirBackNineLowBall = 0
            
            for hole in 9..<18 {
                let ourHoleScores = ourTeamScores.compactMap { scores in
                    hole < scores.count ? Int(scores[hole]) : nil
                }.sorted()
                let theirHoleScores = otherTeamScores.compactMap { scores in
                    hole < scores.count ? Int(scores[hole]) : nil
                }.sorted()
                
                // Alabama scoring
                let ourBestN = Array(ourHoleScores.prefix(bet.countingScores))
                let theirBestN = Array(theirHoleScores.prefix(bet.countingScores))
                
                ourBackNineTotal += ourBestN.reduce(0, +)
                theirBackNineTotal += theirBestN.reduce(0, +)
                
                // Low ball
                if let ourLow = ourHoleScores.first,
                   let theirLow = theirHoleScores.first {
                    ourBackNineLowBall += ourLow
                    theirBackNineLowBall += theirLow
                }
                
                // Count birdies
                let par = teeBox.holes[hole].par
                birdiesDiff += ourHoleScores.filter { $0 < par }.count
                birdiesDiff -= theirHoleScores.filter { $0 < par }.count
            }
            
            // Calculate winnings
            frontNineAlabama = ourFrontNineTotal < theirFrontNineTotal ? bet.frontNineAmount : (ourFrontNineTotal > theirFrontNineTotal ? -bet.frontNineAmount : 0)
            backNineAlabama = ourBackNineTotal < theirBackNineTotal ? bet.backNineAmount : (ourBackNineTotal > theirBackNineTotal ? -bet.backNineAmount : 0)
            frontNineLowBall = ourFrontNineLowBall < theirFrontNineLowBall ? bet.lowBallAmount : (ourFrontNineLowBall > theirFrontNineLowBall ? -bet.lowBallAmount : 0)
            backNineLowBall = ourBackNineLowBall < theirBackNineLowBall ? bet.lowBallAmount : (ourBackNineLowBall > theirBackNineLowBall ? -bet.lowBallAmount : 0)
            
            results.append(TeamResult(
                teamIndex: otherTeamIndex,
                frontNineAlabama: frontNineAlabama,
                backNineAlabama: backNineAlabama,
                frontNineLowBall: frontNineLowBall,
                backNineLowBall: backNineLowBall,
                birdies: Double(birdiesDiff) * bet.perBirdieAmount
            ))
        }
        
        return results
    }
    
    var totalWinnings: Double {
        teamResults.reduce(0) { $0 + $1.total }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
                if let teamIndex = playerTeamIndex {
                    Text("Team \(teamIndex + 1)")
                    .font(.headline)
                
                ForEach(Array(teamResults.enumerated()), id: \.offset) { _, result in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("vs Team \(result.teamIndex + 1)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Front 9: \(formatAmount(result.frontNineAlabama + result.frontNineLowBall))")
                                Text("Back 9: \(formatAmount(result.backNineAlabama + result.backNineLowBall))")
                                if result.birdies != 0 {
                                    Text("Birdies: \(formatAmount(result.birdies))")
                                }
                            }
                            .font(.caption)
                            
                Spacer()
                            
                            Text(formatAmount(result.total))
                                .foregroundColor(result.total >= 0 ? .green : .red)
                    .fontWeight(.semibold)
                        }
                        .padding(.leading)
                    }
                    
                    if result.teamIndex < teamResults.count - 1 {
                        Divider()
                    }
            }
            
            HStack {
                    Text("Total")
                        .fontWeight(.bold)
                    Spacer()
                    Text(formatAmount(totalWinnings))
                        .foregroundColor(totalWinnings >= 0 ? .green : .red)
                        .fontWeight(.bold)
                }
                .padding(.top, 4)
            }
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        String(format: "$%.0f", abs(amount))
    }
}

struct FourBallBetRow: View {
    let bet: FourBallMatchBet
    let player: Player
    
    var isTeam1: Bool {
        bet.team1Player1.id == player.id || bet.team1Player2.id == player.id
    }
    
    var betAmount: Double {
        if let scores = bet.playerScores,
           let teeBox = bet.teeBox {
            let winnings = bet.calculateWinnings(playerScores: scores, teeBox: teeBox)
            return isTeam1 ? winnings : -winnings
        }
        return 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(bet.team1Player1.firstName)/\(bet.team1Player2.firstName) vs \(bet.team2Player1.firstName)/\(bet.team2Player2.firstName)")
                    .fontWeight(.medium)
                Spacer()
                Text(String(format: "$%.2f", betAmount))
                    .foregroundColor(betAmount >= 0 ? .green : .red)
                    .fontWeight(.semibold)
            }
            
            HStack {
                Text("Per Hole: $\(String(format: "%.0f", bet.perHoleAmount))")
                Text("Per Birdie: $\(String(format: "%.0f", bet.perBirdieAmount))")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
    }
}

struct IndividualBetRow: View {
    let bet: IndividualMatchBet
    let player: Player
    let isExpanded: Bool = false
    
    var betWinnings: Double {
        if let scores = bet.playerScores,
           let teeBox = bet.teeBox {
            let winnings = bet.calculateWinnings(playerScores: scores, teeBox: teeBox)
            return bet.player1.id == player.id ? winnings : -winnings
        }
        return 0
    }
    
    var body: some View {
        if isExpanded {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(bet.player1.firstName) vs \(bet.player2.firstName)")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "$%.0f", abs(betWinnings)))
                        .foregroundColor(betWinnings >= 0 ? .green : .red)
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("Per Hole: $\(String(format: "%.2f", bet.perHoleAmount))")
                    Spacer()
                    Text("Per Birdie: $\(String(format: "%.2f", bet.perBirdieAmount))")
                }
                .font(.subheadline)
                .foregroundColor(.gray)
            }
        } else {
            HStack {
                Text("\(bet.player1.firstName) vs \(bet.player2.firstName)")
                Spacer()
                Text(String(format: "$%.0f", betWinnings))
                    .foregroundColor(betWinnings >= 0 ? .green : .red)
            }
            .font(.subheadline)
        }
    }
}

struct SkinsSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    @State private var amount = ""
    let editingBet: SkinsBet?
    let players: [Player]
    
    init(editingBet: SkinsBet? = nil, players: [Player] = []) {
        self.editingBet = editingBet
        self.players = players
        _amount = State(initialValue: editingBet != nil ? String(editingBet!.amount) : "")
    }
    
    var body: some View {
        Form {
            Section(header: Text("Amount")) {
                BetAmountField(
                    label: "Entry Amount",
                    emoji: "💰",
                    amount: Binding(
                        get: { Double(amount) ?? 0 },
                        set: { amount = String($0) }
                    )
                )
            }
            
            Section {
                Text("Each player puts in the amount. Win a skin by having the lowest score on a hole. If any player ties the low score, no skin is awarded for that hole. The total pool is divided by the number of skins won.")
                .font(.subheadline)
                .foregroundColor(.gray)
            }
            
            Section(header: Text("Players")) {
                ForEach(players) { player in
                    HStack {
                        Text(player.firstName + " " + player.lastName)
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(.primaryGreen)
                    }
                }
            }
        }
        .navigationTitle(editingBet != nil ? "Edit Skins" : "New Skins")
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
    
    private var isValid: Bool {
        !amount.isEmpty && (Double(amount) ?? 0) > 0 && !players.isEmpty
    }
    
    private func createBet() {
        guard let amountValue = Double(amount) else { return }
        
        if let existingBet = editingBet {
            betManager.deleteSkinsBet(existingBet)
        }
        
        // Create the new bet with the provided players
        let newBet = SkinsBet(
            id: UUID(),
            amount: amountValue,
            players: players,
            playerScores: editingBet?.playerScores,  // Preserve existing scores if editing
            teeBox: editingBet?.teeBox  // Preserve existing teeBox if editing
        )
        
        // Add to bet manager
        betManager.skinsBets.append(newBet)
        print("Added skins bet to betManager. Total skins bets: \(betManager.skinsBets.count)") // Debug print
    }
}

struct DoDaBetRow: View {
    let bet: DoDaBet
    let player: Player
    let playerScores: [UUID: [String]]
    let teeBox: TeeBox
    
    var doDaCount: Int {
        guard let scores = playerScores[player.id] else { return 0 }
        return scores.filter { score in
            guard !score.isEmpty,
                  let scoreInt = Int(score) else { return false }
            return scoreInt == 2
        }.count
    }
    
    var winnings: Double {
        let allWinnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
        return allWinnings[player.id] ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(bet.isPool ? "Pool Winnings" : "Total Do-Da Winnings")
                    .fontWeight(.medium)
                Spacer()
                Text(String(format: "$%.2f", winnings))
                    .foregroundColor(winnings >= 0 ? .green : .red)
                    .fontWeight(.semibold)
            }
            
            HStack {
                Text("Amount: $\(String(format: "%.0f", bet.amount))")
                if doDaCount > 0 {
                    Text("• Made \(doDaCount) Do-Da\(doDaCount > 1 ? "s" : "")")
                        .foregroundColor(.primaryGreen)
                }
            }
            .font(.caption)
            .foregroundColor(.gray)
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

struct IndividualMatchSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    
    @State private var selectedPlayer1: Player?
    @State private var selectedPlayer2: Player?
    @State private var perHoleAmount: Double = 0
    @State private var perBirdieAmount: Double = 0
    @State private var pressOn9and18 = false
    @State private var showPlayerSelection = false
    @State private var selectingForFirstPlayer = true
    let editingBet: IndividualMatchBet?
    
    init(editingBet: IndividualMatchBet? = nil) {
        self.editingBet = editingBet
        _selectedPlayer1 = State(initialValue: editingBet?.player1)
        _selectedPlayer2 = State(initialValue: editingBet?.player2)
        _perHoleAmount = State(initialValue: editingBet != nil ? editingBet!.perHoleAmount : 0)
        _perBirdieAmount = State(initialValue: editingBet != nil ? editingBet!.perBirdieAmount : 0)
        _pressOn9and18 = State(initialValue: editingBet?.pressOn9and18 ?? false)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("PLAYERS")) {
                    Button(action: {
                        selectingForFirstPlayer = true
                        showPlayerSelection = true
                    }) {
                        PlayerSelectionButton(
                            title: "Player 1",
                            playerName: selectedPlayer1?.firstName ?? "Select Player"
                        )
                    }
                    
                    Button(action: {
                        selectingForFirstPlayer = false
                        showPlayerSelection = true
                    }) {
                        PlayerSelectionButton(
                            title: "Player 2",
                            playerName: selectedPlayer2?.firstName ?? "Select Player"
                        )
                    }
                }
                
                Section(header: Text("BET DETAILS")) {
                    VStack(spacing: 16) {
                        BetAmountField(
                            label: "Per Hole",
                            emoji: "⛳️",
                            amount: $perHoleAmount
                        )
                        
                        BetAmountField(
                            label: "Per Birdie",
                            emoji: "🐦",
                            amount: $perBirdieAmount
                        )
                        
                        Toggle("Press on 9 & 18", isOn: $pressOn9and18)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(editingBet != nil ? "Edit Individual Match" : "New Individual Match")
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
            .sheet(isPresented: $showPlayerSelection) {
                BetPlayerSelectionView(
                    players: MockData.allPlayers,
                    selectedPlayer: selectingForFirstPlayer ? $selectedPlayer1 : $selectedPlayer2
                )
                .environmentObject(userProfile)
            }
        }
    }
    
    private var isValid: Bool {
        selectedPlayer1 != nil && 
        selectedPlayer2 != nil && 
        selectedPlayer1 != selectedPlayer2 &&
        perHoleAmount > 0 && 
        perBirdieAmount > 0
    }
    
    private func createBet() {
        guard let player1 = selectedPlayer1,
              let player2 = selectedPlayer2 else { return }
        
        if let existingBet = editingBet {
            betManager.deleteIndividualBet(existingBet)
        }
        
        betManager.addIndividualBet(
            player1: player1,
            player2: player2,
            perHoleAmount: perHoleAmount,
            perBirdieAmount: perBirdieAmount,
            pressOn9and18: pressOn9and18
        )
    }
}

struct FourBallMatchSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    
    @State private var team1Player1: Player?
    @State private var team1Player2: Player?
    @State private var team2Player1: Player?
    @State private var team2Player2: Player?
    @State private var perHoleAmount: Double = 0
    @State private var perBirdieAmount: Double = 0
    @State private var pressOn9and18 = false
    @State private var showPlayerSelection = false
    @State private var currentSelection: TeamPlayerSelection = .team1Player1
    let editingBet: FourBallMatchBet?
    
    init(editingBet: FourBallMatchBet? = nil) {
        self.editingBet = editingBet
        _team1Player1 = State(initialValue: editingBet?.team1Player1)
        _team1Player2 = State(initialValue: editingBet?.team1Player2)
        _team2Player1 = State(initialValue: editingBet?.team2Player1)
        _team2Player2 = State(initialValue: editingBet?.team2Player2)
        _perHoleAmount = State(initialValue: editingBet != nil ? editingBet!.perHoleAmount : 0)
        _perBirdieAmount = State(initialValue: editingBet != nil ? editingBet!.perBirdieAmount : 0)
        _pressOn9and18 = State(initialValue: editingBet?.pressOn9and18 ?? false)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("TEAM 1")) {
                    Button(action: {
                        currentSelection = .team1Player1
                        showPlayerSelection = true
                    }) {
                        PlayerSelectionButton(
                            title: "Player 1",
                            playerName: team1Player1?.firstName ?? "Select Player"
                        )
                    }
                    
                    Button(action: {
                        currentSelection = .team1Player2
                        showPlayerSelection = true
                    }) {
                        PlayerSelectionButton(
                            title: "Player 2",
                            playerName: team1Player2?.firstName ?? "Select Player"
                        )
                    }
                }
                
                Section(header: Text("TEAM 2")) {
                Button(action: {
                    currentSelection = .team2Player1
                    showPlayerSelection = true
                }) {
                    PlayerSelectionButton(
                        title: "Player 1",
                        playerName: team2Player1?.firstName ?? "Select Player"
                    )
                }
                
                Button(action: {
                    currentSelection = .team2Player2
                    showPlayerSelection = true
                }) {
                    PlayerSelectionButton(
                        title: "Player 2",
                        playerName: team2Player2?.firstName ?? "Select Player"
                    )
                    }
                }
                
                Section(header: Text("BET DETAILS")) {
                    VStack(spacing: 16) {
                        BetAmountField(
                            label: "Per Hole",
                            emoji: "⛳️",
                            amount: $perHoleAmount
                        )
                        
                        BetAmountField(
                            label: "Per Birdie",
                            emoji: "🐦",
                            amount: $perBirdieAmount
                        )
                        
                        Toggle("Press on 9 & 18", isOn: $pressOn9and18)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(editingBet != nil ? "Edit Four-Ball Match" : "New Four-Ball Match")
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
            .sheet(isPresented: $showPlayerSelection) {
                BetPlayerSelectionView(
                    players: MockData.allPlayers,
                    selectedPlayer: Binding(
                        get: {
                            switch currentSelection {
                            case .team1Player1: return team1Player1
                            case .team1Player2: return team1Player2
                            case .team2Player1: return team2Player1
                            case .team2Player2: return team2Player2
                            }
                        },
                        set: { newValue in
                            switch currentSelection {
                            case .team1Player1: team1Player1 = newValue
                            case .team1Player2: team1Player2 = newValue
                            case .team2Player1: team2Player1 = newValue
                            case .team2Player2: team2Player2 = newValue
                            }
                        }
                    )
                )
                .environmentObject(userProfile)
            }
        }
    }
    
    private var isValid: Bool {
        team1Player1 != nil &&
        team1Player2 != nil &&
        team2Player1 != nil &&
        team2Player2 != nil &&
        team1Player1 != team1Player2 &&
        team2Player1 != team2Player2 &&
        !Set([team1Player1?.id, team1Player2?.id, team2Player1?.id, team2Player2?.id].compactMap { $0 }).isEmpty &&
        perHoleAmount > 0 &&
        perBirdieAmount > 0
    }
    
    private func createBet() {
        guard let t1p1 = team1Player1,
              let t1p2 = team1Player2,
              let t2p1 = team2Player1,
              let t2p2 = team2Player2 else { return }
        
        if let existingBet = editingBet {
            betManager.deleteFourBallBet(existingBet)
        }
        
        betManager.addFourBallBet(
            team1Player1: t1p1,
            team1Player2: t1p2,
            team2Player1: t2p1,
            team2Player2: t2p2,
            perHoleAmount: perHoleAmount,
            perBirdieAmount: perBirdieAmount,
            pressOn9and18: pressOn9and18
        )
    }
}

struct AlabamaSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    let editingBet: AlabamaBet?
    
    @State private var numberOfTeams = 3
    @State private var playersPerTeam = 5
    @State private var countingScores = 4
    @State private var teams: [[Player]] = []
    @State private var alabamaAmount = ""
    @State private var lowBallAmount = ""
    @State private var perBirdieAmount = ""
    @State private var showPlayerSelection = false
    @State private var currentTeamIndex = 0
    @State private var selectedPlayers: [Player] = []
    
    init(editingBet: AlabamaBet? = nil) {
        self.editingBet = editingBet
        let initialTeams = editingBet?.teams ?? []
        _teams = State(initialValue: initialTeams)
        _alabamaAmount = State(initialValue: editingBet != nil ? String(editingBet!.frontNineAmount) : "")
        _lowBallAmount = State(initialValue: editingBet != nil ? String(editingBet!.lowBallAmount) : "")
        _perBirdieAmount = State(initialValue: editingBet != nil ? String(editingBet!.perBirdieAmount) : "")
        _numberOfTeams = State(initialValue: max(editingBet?.teams.count ?? 3, 2))
        _playersPerTeam = State(initialValue: max(editingBet?.teams.first?.count ?? 5, 2))
        _countingScores = State(initialValue: editingBet?.countingScores ?? 4)
        
        // Initialize empty teams array
        if initialTeams.isEmpty {
            _teams = State(initialValue: Array(repeating: [], count: numberOfTeams))
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Game Setup")) {
                    Stepper("Number of Teams: \(numberOfTeams)", value: $numberOfTeams, in: 2...4)
                        .onChange(of: numberOfTeams) { oldValue, newValue in
                            if teams.count < newValue {
                                teams.append([])
                            } else if teams.count > newValue {
                                teams = Array(teams.prefix(newValue))
                            }
                        }
                    Stepper("Players per Team: \(playersPerTeam)", value: $playersPerTeam, in: 2...6)
                    Stepper("Counting Scores: \(countingScores)", value: $countingScores, in: 2...playersPerTeam)
                }
                
                Section(header: Text("Teams")) {
                    ForEach(0..<teams.count, id: \.self) { teamIndex in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Team \(teamIndex + 1)")
                                .font(.headline)
                            
                            if teams[teamIndex].isEmpty {
                                Button(action: {
                                    currentTeamIndex = teamIndex
                                    selectedPlayers = []
                                    showPlayerSelection = true
                                }) {
                                    Text("Select Players")
                                        .foregroundColor(.blue)
                    }
                } else {
                                ForEach(teams[teamIndex], id: \.id) { player in
                                    Text(player.firstName)
                                        .foregroundColor(.primary)
                                }
                                Button(action: {
                                    currentTeamIndex = teamIndex
                                    selectedPlayers = teams[teamIndex]
                                    showPlayerSelection = true
                                }) {
                                    Text("Change Players")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Amounts")) {
                    BetAmountField(
                        label: "Alabama",
                        emoji: "🎯",
                        amount: Binding(
                            get: { Double(alabamaAmount) ?? 0 },
                            set: { alabamaAmount = String($0) }
                        )
                    )
                    
                    BetAmountField(
                        label: "Low-Ball",
                        emoji: "⛳️",
                        amount: Binding(
                            get: { Double(lowBallAmount) ?? 0 },
                            set: { lowBallAmount = String($0) }
                        )
                    )
                    
                    BetAmountField(
                        label: "Birdies",
                        emoji: "🐦",
                        amount: Binding(
                            get: { Double(perBirdieAmount) ?? 0 },
                            set: { perBirdieAmount = String($0) }
                        )
                    )
                }
            }
            .navigationTitle(editingBet != nil ? "Edit Alabama Game" : "New Alabama Game")
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
            .sheet(isPresented: $showPlayerSelection) {
                MultiPlayerSelectionView(
                    selectedPlayers: $selectedPlayers,
                    requiredCount: playersPerTeam,
                    onComplete: { players in
                        teams[currentTeamIndex] = players
                    }
                )
                .environmentObject(userProfile)
            }
        }
    }
    
    private var isValid: Bool {
        !teams.contains(where: { $0.count != playersPerTeam }) &&
        !alabamaAmount.isEmpty &&
        !lowBallAmount.isEmpty &&
        !perBirdieAmount.isEmpty
    }
    
    private func createBet() {
        guard let alabama = Double(alabamaAmount),
              let lowBall = Double(lowBallAmount),
              let perBirdie = Double(perBirdieAmount) else {
            return
        }
        
        if let existingBet = editingBet {
            betManager.deleteAlabamaBet(existingBet)
        }
        
        betManager.addAlabamaBet(
            teams: teams,
            countingScores: countingScores,
            frontNineAmount: alabama,
            backNineAmount: alabama,
            lowBallAmount: lowBall,
            perBirdieAmount: perBirdie
        )
    }
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
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Amount")) {
                    BetAmountField(
                        label: isPool ? "Pool Entry" : "Per Do-Da",
                        emoji: "✌️",
                        amount: Binding(
                            get: { Double(amount) ?? 0 },
                            set: { amount = String($0) }
                        )
                    )
                }
                
                if isPool {
                    Section {
                        Text("Each player puts in the pool amount. The total pool is divided by the number of Do-Da's made and paid out per Do-Da.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    Section {
                        Text("Each player pays the amount per Do-Da made by any player. Players who make Do-Da's get paid by everyone else.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle(editingBet != nil ? "Edit Do-Da's" : "New Do-Da's")
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
        
        // Get all players from the round
        var players = MockData.allPlayers
        if let currentUser = userProfile.currentUser {
            players.insert(currentUser, at: 0)
        }
        
        betManager.addDoDaBet(
            isPool: isPool,
            amount: amountValue,
            players: players
        )
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
