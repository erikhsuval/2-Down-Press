import SwiftUI
import BetComponents
import os

class IndividualMatchSetupViewModel: ObservableObject {
    @Published var selectedPlayer1: BetComponents.Player?
    @Published var selectedPlayer2: BetComponents.Player?
    @Published var perHoleAmount: String = ""
    @Published var perBirdieAmount: String = ""
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
            self.perHoleAmount = String(bet.perHoleAmount)
            self.perBirdieAmount = String(bet.perBirdieAmount)
            self.pressOn9and18 = bet.pressOn9and18
            logger.debug("Initialized with existing bet between \(bet.player1.firstName) and \(bet.player2.firstName)")
        }
    }
    
    var isValid: Bool {
        selectedPlayer1 != nil && 
        selectedPlayer2 != nil && 
        selectedPlayer1 != selectedPlayer2 &&
        (Double(perHoleAmount) ?? 0) > 0 && 
        (Double(perBirdieAmount) ?? 0) > 0
    }
    
    var navigationTitle: String {
        editingBet != nil ? "Edit Individual Match" : "New Individual Match"
    }
    
    func createBet() {
        guard let player1 = selectedPlayer1,
              let player2 = selectedPlayer2,
              let holeAmount = Double(perHoleAmount),
              let birdieAmount = Double(perBirdieAmount) else { return }
        
        logger.debug("Creating bet between \(player1.firstName) and \(player2.firstName)")
        
        if let existingBet = editingBet {
            logger.debug("Deleting existing bet")
            betManager.deleteIndividualBet(existingBet)
        }
        
        betManager.addIndividualBet(
            player1: player1,
            player2: player2,
            perHoleAmount: holeAmount,
            perBirdieAmount: birdieAmount,
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
        NavigationView {
            List {
                Section("PLAYERS") {
                    Button(action: {
                        selectingForFirstPlayer = true
                        showPlayerSelection = true
                    }) {
                        HStack {
                            Text("Player 1")
                                .font(.headline)
                            Spacer()
                            Text(viewModel.selectedPlayer1?.firstName ?? "Select Player")
                                .foregroundColor(.gray)
                            Image(systemName: "person.fill")
                                .foregroundColor(.primaryGreen)
                        }
                    }
                    
                    Button(action: {
                        selectingForFirstPlayer = false
                        showPlayerSelection = true
                    }) {
                        HStack {
                            Text("Player 2")
                                .font(.headline)
                            Spacer()
                            Text(viewModel.selectedPlayer2?.firstName ?? "Select Player")
                                .foregroundColor(.gray)
                            Image(systemName: "person.fill")
                                .foregroundColor(.primaryGreen)
                        }
                    }
                }
                
                Section("BET DETAILS") {
                    VStack(spacing: 16) {
                        // Per Hole Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Per Hole")
                                .font(.headline)
                            HStack {
                                Text("$")
                                    .font(.headline)
                                    .foregroundColor(.primaryGreen)
                                TextField("Amount", text: $viewModel.perHoleAmount)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primaryGreen.opacity(0.5), lineWidth: 1)
                            )
                        }
                        
                        // Per Birdie Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Per Birdie")
                                .font(.headline)
                            HStack {
                                Text("$")
                                    .font(.headline)
                                    .foregroundColor(.primaryGreen)
                                TextField("Amount", text: $viewModel.perBirdieAmount)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primaryGreen.opacity(0.5), lineWidth: 1)
                            )
                        }
                        
                        Toggle("Press on 9 & 18", isOn: $viewModel.pressOn9and18)
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(InsetGroupedListStyle())
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
        }
        .sheet(isPresented: $showPlayerSelection) {
            BetPlayerSelectionView(
                players: selectedPlayers.filter { player in
                    if selectingForFirstPlayer {
                        return player.id != viewModel.selectedPlayer2?.id
                    } else {
                        return player.id != viewModel.selectedPlayer1?.id
                    }
                },
                selectedPlayer: Binding(
                    get: { selectingForFirstPlayer ? viewModel.selectedPlayer1 : viewModel.selectedPlayer2 },
                    set: { player in
                        if selectingForFirstPlayer {
                            viewModel.selectedPlayer1 = player
                        } else {
                            viewModel.selectedPlayer2 = player
                        }
                    }
                )
            )
            .environmentObject(userProfile)
        }
        .onAppear {
            viewModel.updateBetManager(betManager)
        }
    }
} 