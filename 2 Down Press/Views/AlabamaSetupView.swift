import SwiftUI
import BetComponents

class AlabamaSetupViewModel: ObservableObject {
    @Published var numberOfTeams = 3
    @Published var playersPerTeam = 5
    @Published var countingScores = 4
    @Published var teams: [[Player]] = []
    @Published var alabamaAmount = ""
    @Published var lowBallAmount = ""
    @Published var perBirdieAmount = ""
    
    private let editingBet: AlabamaBet?
    private var betManager: BetManager
    
    init(editingBet: AlabamaBet? = nil, betManager: BetManager) {
        self.editingBet = editingBet
        self.betManager = betManager
        
        if let bet = editingBet {
            self.teams = bet.teams
            self.numberOfTeams = bet.teams.count
            self.playersPerTeam = bet.teams.first?.count ?? 5
            self.countingScores = bet.countingScores
            self.alabamaAmount = String(bet.frontNineAmount)
            self.lowBallAmount = String(bet.lowBallAmount)
            self.perBirdieAmount = String(bet.perBirdieAmount)
        } else {
            self.teams = Array(repeating: [], count: numberOfTeams)
        }
    }
    
    var isValid: Bool {
        !teams.contains(where: { $0.count != playersPerTeam }) &&
        !alabamaAmount.isEmpty &&
        !lowBallAmount.isEmpty &&
        !perBirdieAmount.isEmpty
    }
    
    var navigationTitle: String {
        editingBet != nil ? "Edit Alabama Game" : "New Alabama Game"
    }
    
    func updateTeams(at index: Int, with players: [Player]) {
        teams[index] = players
    }
    
    func createBet() {
        guard let alabama = Double(alabamaAmount),
              let lowBall = Double(lowBallAmount),
              let perBirdie = Double(perBirdieAmount) else {
            return
        }
        
        if let existingBet = editingBet {
            betManager.deleteAlabamaBet(existingBet)
        }
        
        betManager.addAlabamaBet(
            teams: teams,
            countingScores: countingScores,
            frontNineAmount: alabama,
            backNineAmount: alabama,
            lowBallAmount: lowBall,
            perBirdieAmount: perBirdie
        )
    }
    
    func updateBetManager(_ betManager: BetManager) {
        self.betManager = betManager
    }
}

struct AlabamaSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    @StateObject private var viewModel: AlabamaSetupViewModel
    @State private var showPlayerSelection = false
    @State private var currentTeamIndex = 0
    @State private var selectedPlayers: [Player] = []
    let allPlayers: [Player]
    
    init(editingBet: AlabamaBet? = nil, allPlayers: [Player]) {
        self.allPlayers = allPlayers
        _viewModel = StateObject(wrappedValue: AlabamaSetupViewModel(editingBet: editingBet, betManager: BetManager()))
    }
    
    var body: some View {
        NavigationView {
            Form {
                gameSetupSection
                teamsSection
                amountsSection
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showPlayerSelection) {
                MultiPlayerSelectionView(
                    selectedPlayers: $selectedPlayers,
                    requiredCount: viewModel.playersPerTeam,
                    onComplete: { players in
                        viewModel.updateTeams(at: currentTeamIndex, with: players)
                    },
                    allPlayers: allPlayers
                )
                .environmentObject(userProfile)
            }
        }
        .onAppear {
            viewModel.updateBetManager(betManager)
        }
    }
    
    private var gameSetupSection: some View {
        Section(header: Text("Game Setup")) {
            Stepper("Number of Teams: \(viewModel.numberOfTeams)", value: $viewModel.numberOfTeams, in: 2...4)
                .onChange(of: viewModel.numberOfTeams) { oldValue, newValue in
                    if viewModel.teams.count < newValue {
                        viewModel.teams.append([])
                    } else if viewModel.teams.count > newValue {
                        viewModel.teams = Array(viewModel.teams.prefix(newValue))
                    }
                }
            Stepper("Players per Team: \(viewModel.playersPerTeam)", value: $viewModel.playersPerTeam, in: 2...6)
            Stepper("Counting Scores: \(viewModel.countingScores)", value: $viewModel.countingScores, in: 2...viewModel.playersPerTeam)
        }
    }
    
    private var teamsSection: some View {
        Section(header: Text("Teams")) {
            ForEach(0..<viewModel.teams.count, id: \.self) { teamIndex in
                TeamRow(
                    teamIndex: teamIndex,
                    team: viewModel.teams[teamIndex],
                    onSelectPlayers: {
                        currentTeamIndex = teamIndex
                        selectedPlayers = []
                        showPlayerSelection = true
                    },
                    onChangePlayers: {
                        currentTeamIndex = teamIndex
                        selectedPlayers = viewModel.teams[teamIndex]
                        showPlayerSelection = true
                    }
                )
            }
        }
    }
    
    private var amountsSection: some View {
        Section(header: Text("Amounts")) {
            BetAmountField(
                label: "Alabama",
                emoji: "🎯",
                amount: Binding(
                    get: { Double(viewModel.alabamaAmount) ?? 0 },
                    set: { viewModel.alabamaAmount = String($0) }
                )
            )
            BetAmountField(
                label: "Low-Ball",
                emoji: "⛳️",
                amount: Binding(
                    get: { Double(viewModel.lowBallAmount) ?? 0 },
                    set: { viewModel.lowBallAmount = String($0) }
                )
            )
            BetAmountField(
                label: "Birdies",
                emoji: "🐦",
                amount: Binding(
                    get: { Double(viewModel.perBirdieAmount) ?? 0 },
                    set: { viewModel.perBirdieAmount = String($0) }
                )
            )
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(viewModel.navigationTitle == "Edit Alabama Game" ? "Update" : "Create") {
                    viewModel.createBet()
                    dismiss()
                }
                .disabled(!viewModel.isValid)
            }
        }
    }
}

private struct TeamRow: View {
    let teamIndex: Int
    let team: [Player]
    let onSelectPlayers: () -> Void
    let onChangePlayers: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Team \(teamIndex + 1)")
                .font(.headline)
            
            if team.isEmpty {
                Button(action: onSelectPlayers) {
                    Text("Select Players")
                        .foregroundColor(.blue)
                }
            } else {
                ForEach(team, id: \.id) { player in
                    Text(player.firstName)
                        .foregroundColor(.primary)
                }
                Button(action: onChangePlayers) {
                    Text("Change Players")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
