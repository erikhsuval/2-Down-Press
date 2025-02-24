import SwiftUI
import BetComponents

class DoDaSetupViewModel: ObservableObject {
    @Published var isPool = false
    @Published var amount = ""
    private let editingBet: DoDaBet?
    private var betManager: BetManager
    private let selectedPlayers: [Player]
    
    init(editingBet: DoDaBet? = nil, betManager: BetManager, selectedPlayers: [Player]) {
        self.editingBet = editingBet
        self.betManager = betManager
        self.selectedPlayers = selectedPlayers
        
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
        
        betManager.addDoDaBet(
            isPool: isPool,
            amount: amountValue,
            players: selectedPlayers
        )
    }
    
    func updateBetManager(_ betManager: BetManager) {
        self.betManager = betManager
    }
}

struct DoDaSetupView: View {
    @StateObject private var viewModel: DoDaSetupViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var betManager: BetManager
    let selectedPlayers: [Player]
    
    init(editingBet: DoDaBet? = nil, selectedPlayers: [Player], betManager: BetManager) {
        _viewModel = StateObject(wrappedValue: DoDaSetupViewModel(editingBet: editingBet, betManager: betManager, selectedPlayers: selectedPlayers))
        self.selectedPlayers = selectedPlayers
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Type")) {
                    Picker("Type", selection: $viewModel.isPool) {
                        Text("Per Do-Da").tag(false)
                        Text("Pool").tag(true)
                    }
                }
                
                Section(header: Text("Amount")) {
                    TextField("Amount", text: $viewModel.amount)
                        .keyboardType(.decimalPad)
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
                    Button("Create") {
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

