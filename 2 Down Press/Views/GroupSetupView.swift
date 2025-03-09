import SwiftUI
import BetComponents

class GroupSetupViewModel: ObservableObject {
    @Published var numberOfGroups = 2
    @Published var playersPerGroup = 4  // This becomes the maximum players per group
    @Published var groups: [[BetComponents.Player]] = []
    
    private let editingGroups: [[BetComponents.Player]]?
    private var groupManager: GroupManager
    
    init(editingGroups: [[BetComponents.Player]]? = nil, groupManager: GroupManager) {
        self.editingGroups = editingGroups
        self.groupManager = groupManager
        
        if let existing = editingGroups {
            self.groups = existing
            self.numberOfGroups = existing.count
            self.playersPerGroup = existing.map { $0.count }.max() ?? 4
        } else {
            self.groups = Array(repeating: [], count: numberOfGroups)
        }
    }
    
    var isValid: Bool {
        // Validate that:
        // 1. We have at least one group
        // 2. Each group has at least 2 players
        // 3. No group exceeds maximum players
        !groups.isEmpty && 
        groups.allSatisfy { group in
            group.isEmpty || (group.count >= 2 && group.count <= playersPerGroup)
        } &&
        groups.contains { !$0.isEmpty }  // At least one group has players
    }
    
    var navigationTitle: String {
        editingGroups != nil ? "Edit Groups" : "Setup Groups"
    }
    
    func updateGroups(at index: Int, with players: [BetComponents.Player]) {
        while groups.count <= index {
            groups.append([])
        }
        // Only accept up to maximum players per group
        groups[index] = Array(players.prefix(playersPerGroup))
        objectWillChange.send()
    }
    
    func finalizeGroups() {
        // Remove any empty groups before saving
        let nonEmptyGroups = groups.filter { !$0.isEmpty }
        groupManager.setGroups(nonEmptyGroups)
    }
    
    func updateGroupManager(_ groupManager: GroupManager) {
        self.groupManager = groupManager
    }
}

struct GroupSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var groupManager: GroupManager
    @EnvironmentObject private var userProfile: UserProfile
    @EnvironmentObject private var playerManager: PlayerManager
    @StateObject private var viewModel: GroupSetupViewModel
    @State private var showPlayerSelection = false
    @State private var currentGroupIndex = 0
    @State private var selectedPlayers: [BetComponents.Player] = []
    
    // Base colors that will repeat for groups beyond 4
    private let groupColors: [Color] = [
        Color(red: 0.91, green: 0.3, blue: 0.24),   // Vibrant Red
        Color(red: 0.0, green: 0.48, blue: 0.8),    // Ocean Blue
        Color.teamGold,                              // Team Gold
        Color(red: 0.6, green: 0.2, blue: 0.8),     // Royal Purple
        Color(red: 0.2, green: 0.8, blue: 0.4),     // Emerald Green
        Color(red: 1.0, green: 0.6, blue: 0.0),     // Orange
        Color(red: 0.4, green: 0.2, blue: 0.6),     // Deep Purple
        Color(red: 0.8, green: 0.3, blue: 0.5)      // Rose
    ]
    
    init(editingGroups: [[BetComponents.Player]]? = nil, groupManager: GroupManager) {
        self._viewModel = StateObject(wrappedValue: GroupSetupViewModel(editingGroups: editingGroups, groupManager: groupManager))
    }
    
    private var excludedPlayers: [BetComponents.Player] {
        var excluded: [BetComponents.Player] = []
        for (index, group) in viewModel.groups.enumerated() {
            if index != currentGroupIndex {
                excluded.append(contentsOf: group)
            }
        }
        return excluded
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    GameSetupSection(viewModel: viewModel)
                    GroupsSection(
                        viewModel: viewModel,
                        currentGroupIndex: $currentGroupIndex,
                        selectedPlayers: $selectedPlayers,
                        showPlayerSelection: $showPlayerSelection,
                        groupColors: groupColors
                    )
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
                    Button("Create") {
                        viewModel.finalizeGroups()
                        
                        // Set current user's group
                        if let currentUser = userProfile.currentUser,
                           let groupIndex = viewModel.groups.firstIndex(where: { group in
                               group.contains { $0.id == currentUser.id }
                           }) {
                            groupManager.setCurrentGroup(groupIndex)
                            groupManager.setGroupLeader(true)
                        }
                        
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .sheet(isPresented: $showPlayerSelection) {
                MultiPlayerSelectionView(
                    selectedPlayers: $selectedPlayers,
                    requiredCount: viewModel.playersPerGroup,
                    onComplete: { players in
                        viewModel.updateGroups(at: currentGroupIndex, with: players)
                    },
                    allPlayers: playerManager.allPlayers,
                    excludedPlayers: excludedPlayers,
                    teamName: "Group \(currentGroupIndex + 1)",
                    teamColor: groupColors[currentGroupIndex % groupColors.count],
                    isFlexible: true
                )
                .environmentObject(userProfile)
            }
        }
        .onAppear {
            viewModel.updateGroupManager(groupManager)
        }
    }
}

private struct GameSetupSection: View {
    @ObservedObject var viewModel: GroupSetupViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("GROUP SETUP")
                .font(.title3.bold())
                .foregroundColor(.deepNavyBlue)
            
            VStack(spacing: 12) {
                Text("Create groups with 2-6 players each. Groups can have different sizes.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)
                
                Stepper("Number of Groups: \(viewModel.numberOfGroups)", value: $viewModel.numberOfGroups, in: 1...20)
                    .onChange(of: viewModel.numberOfGroups) { oldValue, newValue in
                        if viewModel.groups.count < newValue {
                            viewModel.groups.append([])
                        } else if viewModel.groups.count > newValue {
                            viewModel.groups = Array(viewModel.groups.prefix(newValue))
                        }
                    }
                
                Stepper("Max Players per Group: \(viewModel.playersPerGroup)", value: $viewModel.playersPerGroup, in: 2...6)
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

private struct GroupsSection: View {
    @ObservedObject var viewModel: GroupSetupViewModel
    @Binding var currentGroupIndex: Int
    @Binding var selectedPlayers: [BetComponents.Player]
    @Binding var showPlayerSelection: Bool
    let groupColors: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("GROUPS")
                .font(.title3.bold())
                .foregroundColor(.deepNavyBlue)
            
            ForEach(0..<viewModel.groups.count, id: \.self) { groupIndex in
                GroupRow(
                    groupIndex: groupIndex,
                    group: viewModel.groups[groupIndex],
                    groupColor: groupColors[groupIndex % groupColors.count],
                    onSelectPlayers: {
                        currentGroupIndex = groupIndex
                        selectedPlayers = []
                        showPlayerSelection = true
                    },
                    onChangePlayers: {
                        currentGroupIndex = groupIndex
                        selectedPlayers = viewModel.groups[groupIndex]
                        showPlayerSelection = true
                    }
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
    }
}

private struct GroupRow: View {
    let groupIndex: Int
    let group: [BetComponents.Player]
    let groupColor: Color
    let onSelectPlayers: () -> Void
    let onChangePlayers: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Group \(groupIndex + 1)")
                .font(.title3.bold())
                .foregroundColor(groupColor)
            
            if group.isEmpty {
                Button(action: onSelectPlayers) {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.title2)
                        Text("Select Players")
                            .font(.headline)
                    }
                    .foregroundColor(groupColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(groupColor, lineWidth: 2)
                            .background(groupColor.opacity(0.1))
                    )
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(group, id: \.id) { player in
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(groupColor)
                            Text(player.firstName)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(groupColor.opacity(0.15))
                        )
                    }
                    
                    Button(action: onChangePlayers) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Change Players")
                                .font(.headline)
                        }
                        .foregroundColor(groupColor)
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
                            groupColor.opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: groupColor.opacity(0.1), radius: 8, y: 2)
        )
        .padding(.bottom, 8)
    }
} 