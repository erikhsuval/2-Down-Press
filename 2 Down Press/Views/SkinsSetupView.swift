import SwiftUI
import BetComponents

class SkinsSetupViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var selectedPlayerIds: Set<UUID>
    private let editingBet: SkinsBet?
    private let availablePlayers: [BetComponents.Player]
    private var betManager: BetManager
    
    init(editingBet: SkinsBet? = nil, players: [BetComponents.Player], betManager: BetManager) {
        self.editingBet = editingBet
        self.availablePlayers = players
        self.betManager = betManager
        self.selectedPlayerIds = Set(players.map { $0.id }) // All players selected by default
        
        if let bet = editingBet {
            self.amount = String(bet.amount)
            self.selectedPlayerIds = Set(bet.players.map { $0.id })
        }
    }
    
    var isValid: Bool {
        let amountValue = Double(amount) ?? 0
        return amountValue > 0 && selectedPlayerIds.count >= 2 // Need at least 2 players for skins
    }
    
    var totalPool: Int {
        Int((Double(amount) ?? 0) * Double(selectedPlayerIds.count))
    }
    
    var navigationTitle: String {
        editingBet != nil ? "Edit Skins" : "New Skins"
    }
    
    func createBet() {
        guard let amountValue = Double(amount) else { return }
        
        if let existingBet = editingBet {
            betManager.deleteSkinsBet(existingBet)
        }
        
        let selectedPlayers = availablePlayers.filter { selectedPlayerIds.contains($0.id) }
        
        betManager.addSkinsBet(
            amount: amountValue,
            players: selectedPlayers
        )
    }
    
    func updateBetManager(_ betManager: BetManager) {
        self.betManager = betManager
    }
    
    func togglePlayer(_ player: BetComponents.Player) {
        if selectedPlayerIds.contains(player.id) {
            // Only allow deselection if there will still be at least two players
            if selectedPlayerIds.count > 2 {
                selectedPlayerIds.remove(player.id)
            }
        } else {
            // Allow reselection
            selectedPlayerIds.insert(player.id)
        }
    }
    
    func isPlayerSelected(_ player: BetComponents.Player) -> Bool {
        selectedPlayerIds.contains(player.id)
    }
}

struct SkinsSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    @StateObject private var viewModel: SkinsSetupViewModel
    let players: [BetComponents.Player]
    
    init(editingBet: SkinsBet? = nil, players: [BetComponents.Player], betManager: BetManager) {
        self.players = players
        _viewModel = StateObject(wrappedValue: SkinsSetupViewModel(editingBet: editingBet, players: players, betManager: betManager))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AmountSection(viewModel: viewModel)
                GameExplanationSection()
                PlayersSection(viewModel: viewModel, players: players)
                if viewModel.totalPool > 0 {
                    TotalPoolSection(totalPool: viewModel.totalPool)
                }
            }
            .padding(.vertical)
        }
        .background(Color.gray.opacity(0.1))
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(viewModel.navigationTitle == "Edit Skins" ? "Update" : "Create") {
                    viewModel.createBet()
                    dismiss()
                }
                .disabled(!viewModel.isValid)
            }
        }
        .onAppear {
            viewModel.updateBetManager(betManager)
        }
    }
}

private struct AmountSection: View {
    @ObservedObject var viewModel: SkinsSetupViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AMOUNT")
                .font(.subheadline.bold())
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Entry Amount")
                    .font(.headline)
                
                QuickAmountSelector(amount: Binding(
                    get: { Double(viewModel.amount) ?? 0 },
                    set: { viewModel.amount = String($0) }
                ))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .padding(.horizontal)
    }
}

private struct GameExplanationSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HOW IT WORKS")
                .font(.subheadline.bold())
                .foregroundColor(.gray)
            
            Text("Each player puts in the amount. Win a skin by having the lowest score on a hole. If any player ties the low score, no skin is awarded for that hole. The total pool is divided by the number of skins won.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .padding(.horizontal)
    }
}

private struct PlayersSection: View {
    @ObservedObject var viewModel: SkinsSetupViewModel
    let players: [BetComponents.Player]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PLAYERS")
                .font(.subheadline.bold())
                .foregroundColor(.gray)
            
            ForEach(players) { player in
                PlayerRow(player: player, viewModel: viewModel)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .padding(.horizontal)
    }
}

private struct PlayerRow: View {
    let player: BetComponents.Player
    @ObservedObject var viewModel: SkinsSetupViewModel
    
    var body: some View {
        Button(action: {
            viewModel.togglePlayer(player)
        }) {
            HStack {
                Text(player.firstName + " " + player.lastName)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: viewModel.isPlayerSelected(player) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(viewModel.isPlayerSelected(player) ? .primaryGreen : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(viewModel.isPlayerSelected(player) ? Color.primaryGreen.opacity(0.1) : Color.gray.opacity(0.05))
            )
        }
    }
}

private struct TotalPoolSection: View {
    let totalPool: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TOTAL POOL")
                .font(.subheadline.bold())
                .foregroundColor(.gray)
            Text("$\(totalPool)")
                .font(.title2.bold())
                .foregroundColor(.primaryGreen)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .padding(.horizontal)
    }
} 
