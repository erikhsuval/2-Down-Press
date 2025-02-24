import SwiftUI
import Foundation
import BetComponents

class FourBallMatchSetupViewModel: ObservableObject {
    @Published var team1Player1: BetComponents.Player? = nil
    @Published var team1Player2: BetComponents.Player? = nil
    @Published var team2Player1: BetComponents.Player? = nil
    @Published var team2Player2: BetComponents.Player? = nil
    @Published var perHoleAmount: Double = 0
    @Published var perBirdieAmount: Double = 0
    @Published var pressOn9and18 = false
    
    private let editingBet: FourBallMatchBet?
    private var betManager: BetManager
    
    init(editingBet: FourBallMatchBet? = nil, betManager: BetManager) {
        self.editingBet = editingBet
        self.betManager = betManager
        
        if let bet = editingBet {
            self.team1Player1 = bet.team1Player1
            self.team1Player2 = bet.team1Player2
            self.team2Player1 = bet.team2Player1
            self.team2Player2 = bet.team2Player2
            self.perHoleAmount = bet.perHoleAmount
            self.perBirdieAmount = bet.perBirdieAmount
            self.pressOn9and18 = bet.pressOn9and18
        }
    }
    
    var isValid: Bool {
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
    
    var navigationTitle: String {
        editingBet != nil ? "Edit Four-Ball Match" : "New Four-Ball Match"
    }
    
    func createBet() {
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
    
    func updateBetManager(_ betManager: BetManager) {
        self.betManager = betManager
    }
}

struct FourBallMatchSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    @StateObject private var viewModel: FourBallMatchSetupViewModel
    @State private var showPlayerSelection = false
    @State private var currentSelection: TeamPlayerSelection = .team1Player1
    let selectedPlayers: [BetComponents.Player]
    
    init(editingBet: FourBallMatchBet? = nil, selectedPlayers: [BetComponents.Player]) {
        self.selectedPlayers = selectedPlayers
        _viewModel = StateObject(wrappedValue: FourBallMatchSetupViewModel(editingBet: editingBet, betManager: BetManager()))
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
                            playerName: viewModel.team1Player1?.firstName ?? "Select Player"
                        )
                    }
                    
                    Button(action: {
                        currentSelection = .team1Player2
                        showPlayerSelection = true
                    }) {
                        PlayerSelectionButton(
                            title: "Player 2",
                            playerName: viewModel.team1Player2?.firstName ?? "Select Player"
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
                            playerName: viewModel.team2Player1?.firstName ?? "Select Player"
                        )
                    }
                    
                    Button(action: {
                        currentSelection = .team2Player2
                        showPlayerSelection = true
                    }) {
                        PlayerSelectionButton(
                            title: "Player 2",
                            playerName: viewModel.team2Player2?.firstName ?? "Select Player"
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
                    Button(viewModel.navigationTitle == "Edit Four-Ball Match" ? "Update" : "Create") {
                        viewModel.createBet()
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .sheet(isPresented: $showPlayerSelection) {
                BetPlayerSelectionView(
                    players: selectedPlayers,
                    selectedPlayer: Binding(
                        get: {
                            switch currentSelection {
                            case .team1Player1: return viewModel.team1Player1
                            case .team1Player2: return viewModel.team1Player2
                            case .team2Player1: return viewModel.team2Player1
                            case .team2Player2: return viewModel.team2Player2
                            }
                        },
                        set: { newValue in
                            switch currentSelection {
                            case .team1Player1: viewModel.team1Player1 = newValue
                            case .team1Player2: viewModel.team1Player2 = newValue
                            case .team2Player1: viewModel.team2Player1 = newValue
                            case .team2Player2: viewModel.team2Player2 = newValue
                            }
                        }
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