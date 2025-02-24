import SwiftUI
import BetComponents
import os

class IndividualMatchSetupViewModel: ObservableObject {
    @Published var selectedPlayer1: BetComponents.Player?
    @Published var selectedPlayer2: BetComponents.Player?
    @Published var perHoleAmount: Double = 0
    @Published var perBirdieAmount: Double = 0
    @Published var pressOn9and18 = false
    
    private let editingBet: IndividualMatchBet?
    private var betManager: BetManager
    private let logger = Logger(subsystem: "com.2downpress", category: "IndividualMatchSetup")
    
    init(editingBet: IndividualMatchBet? = nil, betManager: BetManager) {
        self.editingBet = editingBet
        self.betManager = betManager
        
        if let bet = editingBet {
            self.selectedPlayer1 = bet.player1
            self.selectedPlayer2 = bet.player2
            self.perHoleAmount = bet.perHoleAmount
            self.perBirdieAmount = bet.perBirdieAmount
            self.pressOn9and18 = bet.pressOn9and18
            logger.debug("Initialized with existing bet between \(bet.player1.firstName) and \(bet.player2.firstName)")
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
        
        logger.debug("Creating bet between \(player1.firstName) and \(player2.firstName)")
        
        if let existingBet = editingBet {
            logger.debug("Deleting existing bet")
            betManager.deleteIndividualBet(existingBet)
        }
        
        betManager.addIndividualBet(
            player1: player1,
            player2: player2,
            perHoleAmount: perHoleAmount,
            perBirdieAmount: perBirdieAmount,
            pressOn9and18: pressOn9and18
        )
        
        logger.debug("Successfully created bet")
    }
    
    func updateBetManager(_ betManager: BetManager) {
        self.betManager = betManager
        logger.debug("Updated BetManager reference")
    }
}

struct IndividualMatchSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userProfile: UserProfile
    @StateObject private var viewModel: IndividualMatchSetupViewModel
    @State private var showPlayerSelection = false
    @State private var selectingForFirstPlayer = true
    let editingBet: IndividualMatchBet?
    let selectedPlayers: [BetComponents.Player]
    let betManager: BetManager
    
    init(editingBet: IndividualMatchBet? = nil, selectedPlayers: [BetComponents.Player], betManager: BetManager) {
        self.editingBet = editingBet
        self.selectedPlayers = selectedPlayers
        self.betManager = betManager
        _viewModel = StateObject(wrappedValue: IndividualMatchSetupViewModel(editingBet: editingBet, betManager: betManager))
    }
    
    var body: some View {
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
            
            Section(header: Text("AMOUNTS")) {
                HStack {
                    Text("Per Hole")
                    Spacer()
                    TextField("Amount", value: $viewModel.perHoleAmount, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Per Birdie")
                    Spacer()
                    TextField("Amount", value: $viewModel.perBirdieAmount, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Section {
                Toggle("Press on 9 & 18", isOn: $viewModel.pressOn9and18)
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
                Button(editingBet != nil ? "Update" : "Create") {
                    viewModel.createBet()
                    dismiss()
                }
                .disabled(!viewModel.isValid)
            }
        }
        .sheet(isPresented: $showPlayerSelection) {
            MultiPlayerSelectionView(
                selectedPlayers: selectingForFirstPlayer ? 
                    Binding(
                        get: { viewModel.selectedPlayer1.map { [$0] } ?? [] },
                        set: { players in viewModel.selectedPlayer1 = players.first }
                    ) :
                    Binding(
                        get: { viewModel.selectedPlayer2.map { [$0] } ?? [] },
                        set: { players in viewModel.selectedPlayer2 = players.first }
                    ),
                requiredCount: 1,
                onComplete: { _ in },
                allPlayers: selectedPlayers
            )
            .environmentObject(userProfile)
        }
        .onAppear {
            viewModel.updateBetManager(betManager)
        }
    }
} 