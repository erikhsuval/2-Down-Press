import SwiftUI

class SkinsSetupViewModel: ObservableObject {
    @Published var amount: String = ""
    private let editingBet: SkinsBet?
    private let players: [Player]
    private var betManager: BetManager
    
    init(editingBet: SkinsBet? = nil, players: [Player], betManager: BetManager) {
        self.editingBet = editingBet
        self.players = players
        self.betManager = betManager
        self.amount = editingBet != nil ? String(editingBet!.amount) : ""
    }
    
    var isValid: Bool {
        let amountValue = Double(amount) ?? 0
        return amountValue > 0 && !players.isEmpty
    }
    
    var totalPool: Int {
        Int((Double(amount) ?? 0) * Double(players.count))
    }
    
    var navigationTitle: String {
        editingBet != nil ? "Edit Skins" : "New Skins"
    }
    
    func createBet() {
        guard let amountValue = Double(amount) else { return }
        betManager.addSkinsBet(
            amount: amountValue,
            players: players
        )
    }
    
    func updateBetManager(_ betManager: BetManager) {
        self.betManager = betManager
    }
}

struct SkinsSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var betManager: BetManager
    @StateObject private var viewModel: SkinsSetupViewModel
    let players: [Player]
    
    init(editingBet: SkinsBet? = nil, players: [Player]) {
        self.players = players
        _viewModel = StateObject(wrappedValue: SkinsSetupViewModel(editingBet: editingBet, players: players, betManager: BetManager()))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Amount")) {
                BetAmountField(
                    label: "Entry Amount",
                    emoji: "💰",
                    amount: Binding(
                        get: { Double(viewModel.amount) ?? 0 },
                        set: { viewModel.amount = String($0) }
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
            
            if !players.isEmpty {
                Section {
                    Text("Total pool: $\(viewModel.totalPool)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
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