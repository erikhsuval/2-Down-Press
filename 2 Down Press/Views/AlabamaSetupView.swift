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
    @Published var swingMan: BetComponents.Player?
    @Published var hasSwingMan = false
    
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
            self.swingMan = bet.swingMan
            self.hasSwingMan = bet.swingMan != nil
        } else {
            self.teams = Array(repeating: [], count: numberOfTeams)
        }
    }
    
    var isValid: Bool {
        !teams.contains(where: { $0.count != playersPerTeam }) &&
        !alabamaAmount.isEmpty &&
        !lowBallAmount.isEmpty &&
        !perBirdieAmount.isEmpty &&
        (!hasSwingMan || swingMan != nil)
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
            swingMan: hasSwingMan ? swingMan : nil,
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
    @State private var showSwingManSelection = false
    @State private var currentTeamIndex = 0
    @State private var selectedPlayers: [BetComponents.Player] = []
    let allPlayers: [BetComponents.Player]
    
    private let teamColors: [Color] = [
        Color(red: 0.91, green: 0.3, blue: 0.24),   // Vibrant Red
        Color(red: 0.0, green: 0.48, blue: 0.8),    // Ocean Blue
        Color.teamGold,                              // Team Gold
        Color(red: 0.6, green: 0.2, blue: 0.8)      // Royal Purple
    ]
    
    public init(editingBet: AlabamaBet? = nil, allPlayers: [BetComponents.Player], betManager: BetManager) {
        self.allPlayers = allPlayers
        self._viewModel = StateObject(wrappedValue: AlabamaSetupViewModel(editingBet: editingBet, betManager: betManager))
    }
    
    private var excludedPlayers: [BetComponents.Player] {
        var excluded: [BetComponents.Player] = []
        for (index, team) in viewModel.teams.enumerated() {
            if index != currentTeamIndex {
                excluded.append(contentsOf: team)
            }
        }
        if let swingMan = viewModel.swingMan {
            excluded.append(swingMan)
        }
        return excluded
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    GameSetupSection(viewModel: viewModel)
                    TeamsSection(
                        viewModel: viewModel,
                        currentTeamIndex: $currentTeamIndex,
                        selectedPlayers: $selectedPlayers,
                        showPlayerSelection: $showPlayerSelection,
                        teamColors: teamColors
                    )
                    SwingManSection(
                        viewModel: viewModel,
                        showSwingManSelection: $showSwingManSelection
                    )
                    AmountsSection(viewModel: viewModel)
                }
                .padding(.vertical)
            }
            .background(Color.gray.opacity(0.1))
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
            .sheet(isPresented: $showSwingManSelection) {
                SinglePlayerSelectionView(
                    selectedPlayer: Binding(
                        get: { viewModel.swingMan },
                        set: { viewModel.swingMan = $0 }
                    ),
                    allPlayers: allPlayers,
                    excludedPlayers: excludedPlayers,
                    title: "Select Swing Man"
                )
                .environmentObject(userProfile)
            }
        }
        .onAppear {
            viewModel.updateBetManager(betManager)
        }
    }
}

private struct GameSetupSection: View {
    @ObservedObject var viewModel: AlabamaSetupViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("GAME SETUP")
                .font(.subheadline.bold())
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
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
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .padding(.horizontal)
    }
}

private struct TeamsSection: View {
    @ObservedObject var viewModel: AlabamaSetupViewModel
    @Binding var currentTeamIndex: Int
    @Binding var selectedPlayers: [BetComponents.Player]
    @Binding var showPlayerSelection: Bool
    let teamColors: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TEAMS")
                .font(.subheadline.bold())
                .foregroundColor(.gray)
            
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color.gray.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .padding(.horizontal)
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
        Color.teamGold,                              // Team Gold
        Color(red: 0.6, green: 0.2, blue: 0.8)      // Royal Purple
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Team \(teamIndex + 1)")
                .font(.title3.bold())
                .foregroundColor(teamColors[teamIndex])
            
            if team.isEmpty {
                Button(action: onSelectPlayers) {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.title2)
                        Text("Select Players")
                            .font(.headline)
                    }
                    .foregroundColor(teamColors[teamIndex])
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(teamColors[teamIndex], lineWidth: 2)
                            .background(teamColors[teamIndex].opacity(0.1))
                    )
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(team, id: \.id) { player in
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(teamColors[teamIndex])
                            Text(player.firstName)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(teamColors[teamIndex].opacity(0.15))
                        )
                    }
                    
                    Button(action: onChangePlayers) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Change Players")
                                .font(.headline)
                        }
                        .foregroundColor(teamColors[teamIndex])
                        .padding(.top, 8)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            .white,
                            teamColors[teamIndex].opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: teamColors[teamIndex].opacity(0.1), radius: 8, y: 2)
        )
        .padding(.bottom, 8)
    }
}

private struct SwingManSection: View {
    @ObservedObject var viewModel: AlabamaSetupViewModel
    @Binding var showSwingManSelection: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SWING MAN")
                .font(.subheadline.bold())
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                Toggle("Use Swing Man", isOn: $viewModel.hasSwingMan)
                
                if viewModel.hasSwingMan {
                    if let swingMan = viewModel.swingMan {
                        HStack {
                            Text(swingMan.firstName + " " + swingMan.lastName)
                                .foregroundColor(.primary)
                            Spacer()
                            Button("Change") {
                                showSwingManSelection = true
                            }
                            .foregroundColor(.blue)
                        }
                    } else {
                        Button("Select Swing Man") {
                            showSwingManSelection = true
                        }
                    }
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
    }
}

private struct AmountsSection: View {
    @ObservedObject var viewModel: AlabamaSetupViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AMOUNTS")
                .font(.subheadline.bold())
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Alabama")
                        .font(.headline)
                    QuickAmountSelector(amount: Binding(
                        get: { Double(viewModel.alabamaAmount) ?? 0 },
                        set: { viewModel.alabamaAmount = String($0) }
                    ))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Low-Ball")
                        .font(.headline)
                    QuickAmountSelector(amount: Binding(
                        get: { Double(viewModel.lowBallAmount) ?? 0 },
                        set: { viewModel.lowBallAmount = String($0) }
                    ))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Birdies")
                        .font(.headline)
                    QuickAmountSelector(amount: Binding(
                        get: { Double(viewModel.perBirdieAmount) ?? 0 },
                        set: { viewModel.perBirdieAmount = String($0) }
                    ))
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
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
