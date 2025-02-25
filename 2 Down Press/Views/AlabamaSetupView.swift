import SwiftUI
import BetComponents

class AlabamaSetupViewModel: ObservableObject {
    @Published var numberOfTeams = 3
    @Published var playersPerTeam = 5
    @Published var countingScores = 4
    @Published var teams: [[BetComponents.Player]] = []
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
    
    func updateTeams(at index: Int, with players: [BetComponents.Player]) {
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
    @State private var selectedPlayers: [BetComponents.Player] = []
    let allPlayers: [BetComponents.Player]
    
    private let teamColors: [Color] = [
        Color(red: 0.91, green: 0.3, blue: 0.24),   // Vibrant Red
        Color(red: 0.0, green: 0.48, blue: 0.8),    // Ocean Blue
        Color(red: 0.13, green: 0.55, blue: 0.13),  // Forest Green
        Color(red: 0.6, green: 0.2, blue: 0.8)      // Royal Purple
    ]
    
    public init(editingBet: AlabamaBet? = nil, allPlayers: [BetComponents.Player]) {
        self.allPlayers = allPlayers
        self._viewModel = StateObject(wrappedValue: AlabamaSetupViewModel(editingBet: editingBet, betManager: BetManager()))
    }
    
    private var excludedPlayers: [BetComponents.Player] {
        var excluded: [BetComponents.Player] = []
        for (index, team) in viewModel.teams.enumerated() {
            if index != currentTeamIndex {
                excluded.append(contentsOf: team)
            }
        }
        return excluded
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("GAME SETUP")) {
                    Stepper("Number of Teams: \(viewModel.numberOfTeams)", value: $viewModel.numberOfTeams, in: 2...4)
                        .onChange(of: viewModel.numberOfTeams) { oldValue, newValue in
                            if viewModel.teams.count < newValue {
                                viewModel.teams.append([])
                            } else if viewModel.teams.count > newValue {
                                viewModel.teams = Array(viewModel.teams.prefix(newValue))
                            }
                        }
                    
                    Stepper("Players per Team: \(viewModel.playersPerTeam)", value: $viewModel.playersPerTeam, in: 2...6)
                    
                    Stepper("Counting Scores: \(viewModel.countingScores)", value: $viewModel.countingScores, in: 1...viewModel.playersPerTeam)
                }
                
                teamsSection
                
                amountsSection
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
                    Button(viewModel.navigationTitle == "Edit Alabama" ? "Update" : "Create") {
                        viewModel.createBet()
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .sheet(isPresented: $showPlayerSelection) {
                MultiPlayerSelectionView(
                    selectedPlayers: $selectedPlayers,
                    requiredCount: viewModel.playersPerTeam,
                    onComplete: { players in
                        viewModel.teams[currentTeamIndex] = players
                    },
                    allPlayers: allPlayers,
                    excludedPlayers: excludedPlayers,
                    teamName: "Team \(currentTeamIndex + 1)",
                    teamColor: teamColors[currentTeamIndex]
                )
                .environmentObject(userProfile)
            }
        }
        .onAppear {
            viewModel.updateBetManager(betManager)
        }
    }
    
    private var teamsSection: some View {
        Section(header: Text("TEAMS")) {
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
        Section(header: Text("AMOUNTS")) {
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
}

private struct TeamRow: View {
    let teamIndex: Int
    let team: [BetComponents.Player]
    let onSelectPlayers: () -> Void
    let onChangePlayers: () -> Void
    
    private let teamColors: [Color] = [
        Color(red: 0.91, green: 0.3, blue: 0.24),   // Vibrant Red
        Color(red: 0.0, green: 0.48, blue: 0.8),    // Ocean Blue
        Color(red: 0.13, green: 0.55, blue: 0.13),  // Forest Green
        Color(red: 0.6, green: 0.2, blue: 0.8)      // Royal Purple
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Team \(teamIndex + 1)")
                .font(.headline)
                .foregroundColor(teamColors[teamIndex])
            
            if team.isEmpty {
                Button(action: onSelectPlayers) {
                    Text("Select Players")
                        .foregroundColor(teamColors[teamIndex])
                }
            } else {
                ForEach(team, id: \.id) { player in
                    Text(player.firstName)
                        .foregroundColor(.primary)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(teamColors[teamIndex].opacity(0.2))
                        )
                }
                Button(action: onChangePlayers) {
                    Text("Change Players")
                        .foregroundColor(teamColors[teamIndex])
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(teamColors[teamIndex].opacity(0.1))
        )
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
