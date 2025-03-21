import SwiftUI
import Foundation
import BetComponents

class FourBallMatchSetupViewModel: ObservableObject {
    @Published var team1Player1: BetComponents.Player? = nil
    @Published var team1Player2: BetComponents.Player? = nil
    @Published var team2Player1: BetComponents.Player? = nil
    @Published var team2Player2: BetComponents.Player? = nil
    @Published var perHoleAmount: String = ""
    @Published var perBirdieAmount: String = ""
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
            self.perHoleAmount = String(bet.perHoleAmount)
            self.perBirdieAmount = String(bet.perBirdieAmount)
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
        (Double(perHoleAmount) ?? 0) > 0 &&
        (Double(perBirdieAmount) ?? 0) > 0
    }
    
    var navigationTitle: String {
        editingBet != nil ? "Edit Four-Ball Match" : "New Four-Ball Match"
    }
    
    func createBet() {
        guard let t1p1 = team1Player1,
              let t1p2 = team1Player2,
              let t2p1 = team2Player1,
              let t2p2 = team2Player2,
              let holeAmount = Double(perHoleAmount),
              let birdieAmount = Double(perBirdieAmount) else { return }
        
        if let existingBet = editingBet {
            betManager.deleteFourBallBet(existingBet)
        }
        
        betManager.addFourBallBet(
            team1Player1: t1p1,
            team1Player2: t1p2,
            team2Player1: t2p1,
            team2Player2: t2p2,
            perHoleAmount: holeAmount,
            perBirdieAmount: birdieAmount,
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
    
    init(editingBet: FourBallMatchBet? = nil, selectedPlayers: [BetComponents.Player], betManager: BetManager) {
        self.selectedPlayers = selectedPlayers
        _viewModel = StateObject(wrappedValue: FourBallMatchSetupViewModel(editingBet: editingBet, betManager: betManager))
    }
    
    private func availablePlayers(for selection: TeamPlayerSelection) -> [BetComponents.Player] {
        // Filter out players already selected in other positions
        selectedPlayers.filter { player in
            switch selection {
            case .team1Player1:
                return player.id != viewModel.team1Player2?.id &&
                       player.id != viewModel.team2Player1?.id &&
                       player.id != viewModel.team2Player2?.id
            case .team1Player2:
                return player.id != viewModel.team1Player1?.id &&
                       player.id != viewModel.team2Player1?.id &&
                       player.id != viewModel.team2Player2?.id
            case .team2Player1:
                return player.id != viewModel.team1Player1?.id &&
                       player.id != viewModel.team1Player2?.id &&
                       player.id != viewModel.team2Player2?.id
            case .team2Player2:
                return player.id != viewModel.team1Player1?.id &&
                       player.id != viewModel.team1Player2?.id &&
                       player.id != viewModel.team2Player1?.id
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Group {
                    TeamSection(
                        teamNumber: 1,
                        player1: (viewModel.team1Player1, .team1Player1),
                        player2: (viewModel.team1Player2, .team1Player2),
                        onPlayerSelect: { selection in
                            currentSelection = selection
                            showPlayerSelection = true
                        }
                    )
                    
                    TeamSection(
                        teamNumber: 2,
                        player1: (viewModel.team2Player1, .team2Player1),
                        player2: (viewModel.team2Player2, .team2Player2),
                        onPlayerSelect: { selection in
                            currentSelection = selection
                            showPlayerSelection = true
                        }
                    )
                    
                    BetDetailsSection(viewModel: viewModel)
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
                    Button(viewModel.navigationTitle == "Edit Four-Ball Match" ? "Update" : "Create") {
                        viewModel.createBet()
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
        .sheet(isPresented: $showPlayerSelection) {
            BetPlayerSelectionView(
                players: availablePlayers(for: currentSelection),
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
        .onAppear {
            viewModel.updateBetManager(betManager)
        }
    }
}

// MARK: - Subviews

private struct TeamSection: View {
    let teamNumber: Int
    let player1: (BetComponents.Player?, TeamPlayerSelection)
    let player2: (BetComponents.Player?, TeamPlayerSelection)
    let onPlayerSelect: (TeamPlayerSelection) -> Void
    
    var body: some View {
        Section("TEAM \(teamNumber)") {
            Button(action: { onPlayerSelect(player1.1) }) {
                HStack {
                    Text("Player 1")
                        .font(.headline)
                    Spacer()
                    Text(player1.0?.firstName ?? "Select Player")
                        .foregroundColor(.gray)
                    Image(systemName: "person.fill")
                        .foregroundColor(.primaryGreen)
                }
            }
            
            Button(action: { onPlayerSelect(player2.1) }) {
                HStack {
                    Text("Player 2")
                        .font(.headline)
                    Spacer()
                    Text(player2.0?.firstName ?? "Select Player")
                        .foregroundColor(.gray)
                    Image(systemName: "person.fill")
                        .foregroundColor(.primaryGreen)
                }
            }
        }
    }
}

private struct BetDetailsSection: View {
    @ObservedObject var viewModel: FourBallMatchSetupViewModel
    
    var body: some View {
        Section("BET DETAILS") {
            VStack(spacing: 16) {
                AmountField(
                    title: "Per Hole",
                    amount: $viewModel.perHoleAmount
                )
                
                AmountField(
                    title: "Per Birdie",
                    amount: $viewModel.perBirdieAmount
                )
                
                Toggle("Press on 9 & 18", isOn: $viewModel.pressOn9and18)
            }
            .padding(.vertical, 8)
        }
    }
}

private struct AmountField: View {
    let title: String
    @Binding var amount: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            HStack {
                Text("$")
                    .font(.headline)
                    .foregroundColor(.primaryGreen)
                TextField("Amount", text: $amount)
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
    }
} 