import SwiftUI

class DoDaSetupViewModel: ObservableObject {
    @Published var isPool = false
    @Published var amount = ""
    private let editingBet: DoDaBet?
    private var betManager: BetManager
    
    init(editingBet: DoDaBet? = nil, betManager: BetManager) {
        self.editingBet = editingBet
        self.betManager = betManager
        
        if let bet = editingBet {
            self.isPool = bet.isPool
            self.amount = String(bet.amount)
        }
    }
    
    var isValid: Bool {
        !amount.isEmpty && (Double(amount) ?? 0) > 0
    }
    
    var navigationTitle: String {
        editingBet != nil ? "Edit Do-Da's" : "New Do-Da's"
    }
    
    func createBet() {
        guard let amountValue = Double(amount) else { return }
        
        if let existingBet = editingBet {
            betManager.deleteDoDaBet(existingBet)
        }
        
        // Get all players from the round
        var players = MockData.allPlayers
        
        betManager.addDoDaBet(
            isPool: isPool,
            amount: amountValue,
            players: players
        )
    }
    
    func updateBetManager(_ betManager: BetManager) {
        self.betManager = betManager
    }
}

struct DoDaSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    @StateObject private var viewModel: DoDaSetupViewModel
    
    init(editingBet: DoDaBet? = nil) {
        _viewModel = StateObject(wrappedValue: DoDaSetupViewModel(editingBet: editingBet, betManager: BetManager()))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Type")) {
                    Picker("Type", selection: $viewModel.isPool) {
                        Text("Per Do-Da").tag(false)
                        Text("Pool").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Amount")) {
                    BetAmountField(
                        label: viewModel.isPool ? "Pool Entry" : "Per Do-Da",
                        emoji: "✌️",
                        amount: Binding(
                            get: { Double(viewModel.amount) ?? 0 },
                            set: { viewModel.amount = String($0) }
                        )
                    )
                }
                
                if viewModel.isPool {
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
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.navigationTitle == "Edit Do-Da's" ? "Update" : "Create") {
                        viewModel.createBet()
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
        .onAppear {
            viewModel.updateBetManager(betManager)
        }
    }
} 