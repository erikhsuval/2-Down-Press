import SwiftUI
import BetComponents

class DoDaSetupViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var isPool: Bool = false
    @Published var selectedPlayerIds: Set<UUID>
    private let editingBet: DoDaBet?
    private let availablePlayers: [BetComponents.Player]
    private var betManager: BetManager
    
    init(editingBet: DoDaBet? = nil, players: [BetComponents.Player], betManager: BetManager) {
        self.editingBet = editingBet
        self.availablePlayers = players
        self.betManager = betManager
        self.selectedPlayerIds = Set(players.map { $0.id }) // All players selected by default
        
        if let bet = editingBet {
            self.amount = String(bet.amount)
            self.isPool = bet.isPool
            self.selectedPlayerIds = Set(bet.players.map { $0.id })
        }
    }
    
    var isValid: Bool {
        let amountValue = Double(amount) ?? 0
        return amountValue > 0 && selectedPlayerIds.count >= 1 // Need at least 1 player for Do Da
    }
    
    var navigationTitle: String {
        editingBet != nil ? "Edit Do Da" : "New Do Da"
    }
    
    func createBet() {
        guard let amountValue = Double(amount) else { return }
        
        if let existingBet = editingBet {
            betManager.deleteDoDaBet(existingBet)
        }
        
        let selectedPlayers = availablePlayers.filter { selectedPlayerIds.contains($0.id) }
        
        betManager.addDoDaBet(
            isPool: isPool,
            amount: amountValue,
            players: selectedPlayers
        )
    }
    
    func updateBetManager(_ betManager: BetManager) {
        self.betManager = betManager
    }
    
    func togglePlayer(_ player: BetComponents.Player) {
        if selectedPlayerIds.contains(player.id) {
            // Only allow deselection if there will still be at least one player
            if selectedPlayerIds.count > 1 {
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

struct DoDaSetupView: View {
    @StateObject private var viewModel: DoDaSetupViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userProfile: UserProfile
    let selectedPlayers: [BetComponents.Player]
    let betManager: BetManager
    
    init(editingBet: DoDaBet? = nil, selectedPlayers: [BetComponents.Player], betManager: BetManager) {
        _viewModel = StateObject(wrappedValue: DoDaSetupViewModel(editingBet: editingBet, players: selectedPlayers, betManager: betManager))
        self.selectedPlayers = selectedPlayers
        self.betManager = betManager
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("✌️ Do-Da Game")
                            .font(.title2.bold())
                            .foregroundColor(.primaryGreen)
                        
                        Text("A Do-Da is when you score a 2 on any hole. Choose between paying per Do-Da or creating a pool.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    )
                    .padding(.horizontal)
                    
                    // Game Type Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("GAME TYPE")
                            .font(.subheadline.bold())
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 12) {
                            GameTypeButton(
                                title: "Per Do-Da",
                                description: "Pay a fixed amount for each Do-Da scored",
                                isSelected: !viewModel.isPool,
                                action: { viewModel.isPool = false }
                            )
                            
                            GameTypeButton(
                                title: "Pool",
                                description: "Everyone contributes to a pool, split between Do-Da scorers",
                                isSelected: viewModel.isPool,
                                action: { viewModel.isPool = true }
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    )
                    .padding(.horizontal)
                    
                    // Amount Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("AMOUNT")
                            .font(.subheadline.bold())
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.isPool ? "Entry Amount" : "Per Do-Da")
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
                    
                    // Players Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PLAYERS")
                            .font(.subheadline.bold())
                            .foregroundColor(.gray)
                        
                        ForEach(selectedPlayers) { player in
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
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    )
                    .padding(.horizontal)
                    
                    // Create Button
                    Button(action: {
                        viewModel.createBet()
                        dismiss()
                    }) {
                        Text(viewModel.navigationTitle == "Edit Do-Da's" ? "Update" : "Create")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(viewModel.isValid ? Color.primaryGreen : Color.gray)
                            )
                    }
                    .disabled(!viewModel.isValid)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .background(Color.gray.opacity(0.1))
        }
        .onAppear {
            viewModel.updateBetManager(betManager)
        }
    }
}

struct GameTypeButton: View {
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Circle()
                    .stroke(isSelected ? Color.primaryGreen : Color.gray, lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(isSelected ? Color.primaryGreen : Color.clear)
                            .frame(width: 16, height: 16)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primaryGreen : Color.gray.opacity(0.3), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.primaryGreen.opacity(0.1) : Color.white)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickAmountSelector: View {
    @Binding var amount: Double
    let quickAmounts = [1, 2, 5, 10]
    
    var body: some View {
        VStack(spacing: 12) {
            // Quick amount buttons
            HStack(spacing: 8) {
                ForEach(quickAmounts, id: \.self) { value in
                    Button(action: { 
                        withAnimation {
                            amount = Double(value)
                        }
                    }) {
                        Text("$\(value)")
                            .font(.headline)
                            .foregroundColor(amount == Double(value) ? .white : .primaryGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(amount == Double(value) ? Color.primaryGreen : Color.primaryGreen.opacity(0.1))
                            )
                    }
                }
            }
            
            // Custom amount field
            HStack {
                Text("$")
                    .font(.headline)
                TextField("Custom amount", value: $amount, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}

