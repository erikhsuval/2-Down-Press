import SwiftUI
import BetComponents

class IndividualMatchSetupViewModel: ObservableObject {
    @Published var selectedPlayer1: Player?
    @Published var selectedPlayer2: Player?
    @Published var perHoleAmount: Double = 0
    @Published var perBirdieAmount: Double = 0
    @Published var pressOn9and18 = false
    
    private let editingBet: IndividualMatchBet?
    private var betManager: BetManager
    
    init(editingBet: IndividualMatchBet? = nil, betManager: BetManager) {
        self.editingBet = editingBet
        self.betManager = betManager
        
        if let bet = editingBet {
            self.selectedPlayer1 = bet.player1
            self.selectedPlayer2 = bet.player2
            self.perHoleAmount = bet.perHoleAmount
            self.perBirdieAmount = bet.perBirdieAmount
            self.pressOn9and18 = bet.pressOn9and18
        }
    }
    
    var isValid: Bool {
        selectedPlayer1 != nil && 
        selectedPlayer2 != nil && 
        selectedPlayer1 != selectedPlayer2 &&
        perHoleAmount > 0 && 
        perBirdieAmount > 0
    }
    
    var navigationTitle: String {
        editingBet != nil ? "Edit Individual Match" : "New Individual Match"
    }
    
    func createBet() {
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
    
    func updateBetManager(_ betManager: BetManager) {
        self.betManager = betManager
    }
}

struct IndividualMatchSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    @StateObject private var viewModel: IndividualMatchSetupViewModel
    @State private var showPlayerSelection = false
    @State private var selectingForFirstPlayer = true
    
    init(editingBet: IndividualMatchBet? = nil) {
        _viewModel = StateObject(wrappedValue: IndividualMatchSetupViewModel(editingBet: editingBet, betManager: BetManager()))
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
                            playerName: viewModel.selectedPlayer1?.firstName ?? "Select Player"
                        )
                    }
                    
                    Button(action: {
                        selectingForFirstPlayer = false
                        showPlayerSelection = true
                    }) {
                        PlayerSelectionButton(
                            title: "Player 2",
                            playerName: viewModel.selectedPlayer2?.firstName ?? "Select Player"
                        )
                    }
                }
                
                Section(header: Text("BET DETAILS")) {
                    VStack(spacing: 16) {
                        BetAmountField(
                            label: "Per Hole",
                            emoji: "⛳️",
                            amount: Binding(
                                get: { viewModel.perHoleAmount },
                                set: { viewModel.perHoleAmount = $0 }
                            )
                        )
                        
                        BetAmountField(
                            label: "Per Birdie",
                            emoji: "🐦",
                            amount: Binding(
                                get: { viewModel.perBirdieAmount },
                                set: { viewModel.perBirdieAmount = $0 }
                            )
                        )
                        
                        Toggle("Press on 9 & 18", isOn: $viewModel.pressOn9and18)
                    }
                    .padding(.vertical, 8)
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
                    Button(viewModel.navigationTitle == "Edit Individual Match" ? "Update" : "Create") {
                        viewModel.createBet()
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .sheet(isPresented: $showPlayerSelection) {
                BetPlayerSelectionView(
                    players: MockData.allPlayers,
                    selectedPlayer: selectingForFirstPlayer ? 
                        Binding(
                            get: { viewModel.selectedPlayer1 },
                            set: { viewModel.selectedPlayer1 = $0 }
                        ) :
                        Binding(
                            get: { viewModel.selectedPlayer2 },
                            set: { viewModel.selectedPlayer2 = $0 }
                        )
                )
                .environmentObject(userProfile)
            }
        }
        .onAppear {
            viewModel.updateBetManager(betManager)
        }
    }
} 