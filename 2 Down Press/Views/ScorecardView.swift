import SwiftUI
import BetComponents
import AVFoundation
import CoreImage.CIFilterBuiltins

private extension View {
    func standardHorizontalPadding() -> some View {
        self.padding(.horizontal, 16)
    }
}

struct ScorecardView: View {
    let course: GolfCourse
    let teeBox: BetComponents.TeeBox
    let isNewRound: Bool
    @State private var showMenu = false
    @State private var showBetCreation = false
    @State private var showPlayerSelection = false
    @State private var selectedPlayerId: UUID? = nil
    @State private var scores: [UUID: [String]] = [:]
    @State private var showLeaderboard = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isTimerRunning = false
    @State private var hasStartedRound = false
    @EnvironmentObject private var userProfile: UserProfile
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var groupManager: GroupManager
    @EnvironmentObject private var gameStateManager: GameStateManager
    @EnvironmentObject private var playerManager: PlayerManager
    @GestureState private var dragOffset: CGFloat = 0
    @State private var selectedPlayers: [BetComponents.Player] = []
    @State private var expandedPlayers: Set<UUID> = []
    @State private var showPostConfirmation = false
    @State private var showUnpostConfirmation = false
    @State private var showPostAnimation = false
    @State private var isPosted = false
    @FocusState private var isScoreFieldFocused: Bool
    
    private let maxTimerDuration: TimeInterval = 6 * 60 * 60 // 6 hours in seconds
    
    private var players: [BetComponents.Player] {
        var allPlayers = Set<BetComponents.Player>()
        
        // Add selected players first to maintain order
        allPlayers.formUnion(selectedPlayers)
        
        // Add current user if available and not already included
        if let currentUser = userProfile.currentUser,
           !allPlayers.contains(where: { $0.id == currentUser.id }) {
            allPlayers.insert(currentUser)
        }
        
        // Add players from current round only
        allPlayers.formUnion(playerManager.currentRoundPlayers)
        
        return Array(allPlayers)
    }
    
    private var currentPlayer: BetComponents.Player {
        guard let playerId = selectedPlayerId,
              let player = players.first(where: { $0.id == playerId }) else { return players[0] }
        return player
    }
    
    private var currentPlayerScores: [String] {
        guard let playerId = selectedPlayerId,
              let scores = scores[playerId] else {
            return Array(repeating: "", count: 18)
        }
        return scores
    }
    
    private var sortedPlayers: [BetComponents.Player] {
        // Get all groups
        let allGroups = groupManager.groups
        
        // Create a dictionary to store player indices for stable sorting
        var playerIndices: [UUID: Int] = [:]
        
        // First, add all players from groups in order
        var sorted: [BetComponents.Player] = []
        for (groupIndex, group) in allGroups.enumerated() {
            for (playerIndex, player) in group.enumerated() {
                sorted.append(player)
                playerIndices[player.id] = groupIndex * 100 + playerIndex // Use group index as major sort key
            }
        }
        
        // Then add any remaining players that aren't in any group
        let remainingPlayers = players.filter { player in
            !sorted.contains { $0.id == player.id }
        }
        for (index, player) in remainingPlayers.enumerated() {
            sorted.append(player)
            playerIndices[player.id] = allGroups.count * 100 + index
        }
        
        // Sort by the stable indices we created
        return sorted.sorted { player1, player2 in
            playerIndices[player1.id, default: Int.max] < playerIndices[player2.id, default: Int.max]
        }
    }
    
    private func getTeamColor(for player: BetComponents.Player, groupManager: GroupManager) -> Color? {
        // First check Alabama teams
        if let alabamaBet = betManager.alabamaBets.first(where: { bet in
            bet.teams.contains(where: { team in
                team.contains(where: { $0.id == player.id })
            })
        }) {
            for (index, team) in alabamaBet.teams.enumerated() {
                if team.contains(where: { $0.id == player.id }) {
                    return teamColors[index]
                }
            }
        }
        
        // If no Alabama color, check if player is in current group
        if let currentGroup = groupManager.currentGroup,
           currentGroup.contains(where: { $0.id == player.id }) {
            return .primaryGreen
        }
        
        return nil
    }
    
    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    public var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Header
                    ScorecardHeaderView(
                        course: course,
                        showMenu: $showMenu,
                        showPlayerSelection: $showPlayerSelection,
                        showBetCreation: $showBetCreation,
                        showLeaderboard: $showLeaderboard,
                        scores: $scores,
                        players: players
                    )
                    .frame(maxHeight: geometry.size.height * 0.15)
                    
                    // Player carousel
                    PlayerCarouselView(
                        players: sortedPlayers,
                        selectedPlayerId: $selectedPlayerId,
                        isScoreFieldFocused: isScoreFieldFocused,
                        getTeamColor: getTeamColor,
                        geometry: geometry
                    )
                    
                    // Main content
                    ScorecardMainContentView(
                        teeBox: teeBox,
                        currentPlayer: currentPlayer,
                        currentPlayerScores: currentPlayerScores,
                        updateScore: updateScore,
                        geometry: geometry
                    )
                    
                    // Footer
                    ScorecardFooterView(
                        players: players,
                        playerScores: scores,
                        teeBox: teeBox,
                        betManager: betManager,
                        isPosted: $isPosted,
                        showPostConfirmation: $showPostConfirmation,
                        showUnpostConfirmation: $showUnpostConfirmation
                    )
                    .frame(maxHeight: geometry.size.height * 0.1)
                }
            }
            .overlay(
                PostAnimationOverlay(showPostAnimation: $showPostAnimation)
            )
            .alert("Post Round", isPresented: $showPostConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Post") {
                    betManager.mergeGroupScores()
                    betManager.updateScoresAndTeeBox(scores, teeBox)
                    playerManager.postRound(betManager: betManager, scores: scores)
                    withAnimation {
                        showPostAnimation = true
                        isPosted = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showPostAnimation = false
                        }
                    }
                }
            } message: {
                Text("This will finalize the scorecard and update The Sheet. Continue?")
            }
            .alert("Unpost Round", isPresented: $showUnpostConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Unpost", role: .destructive) {
                    if playerManager.unpostRound(betManager: betManager, scores: scores) {
                        withAnimation {
                            isPosted = false
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to unpost these scores?")
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .sheet(isPresented: $showPlayerSelection) {
                PlayerSelectionView(selectedPlayers: $selectedPlayers)
                    .onDisappear {
                        for player in selectedPlayers {
                            initializeScores(for: player.id)
                        }
                    }
            }
            .sheet(isPresented: $showMenu) {
                SideMenuView(
                    isShowing: $showMenu,
                    showPlayerList: $showPlayerSelection,
                    showFourBallMatchSetup: .constant(false)
                )
            }
            .sheet(isPresented: $showLeaderboard) {
                LeaderboardView(
                    course: course,
                    teeBox: teeBox,
                    players: players,
                    playerScores: scores,
                    currentPlayerId: $selectedPlayerId,
                    onScoresImported: { importedScores, importedPlayers in
                        for (playerId, playerScores) in importedScores {
                            scores[playerId] = playerScores
                        }
                        for player in importedPlayers {
                            if !selectedPlayers.contains(where: { $0.id == player.id }) {
                                selectedPlayers.append(player)
                            }
                        }
                    }
                )
            }
            .sheet(isPresented: $showBetCreation) {
                BetCreationView()
            }
            .onAppear {
                if isNewRound {
                    betManager.clearAllBets()
                    scores.removeAll()
                    selectedPlayers.removeAll()
                    isPosted = false
                    selectedPlayerId = nil
                    hasStartedRound = false
                    elapsedTime = 0
                    isTimerRunning = false
                    playerManager.prepareForNewRound() // Clear players for new round
                } else if let savedGame = gameStateManager.currentGame,
                         savedGame.courseId == course.id,
                         savedGame.teeBoxName == teeBox.name {
                    scores = savedGame.scores
                    selectedPlayers = savedGame.players
                    isPosted = savedGame.isCompleted
                    selectedPlayerId = savedGame.selectedPlayerId
                    gameStateManager.restoreGame(to: betManager)
                    betManager.teeBox = teeBox
                    if !savedGame.scores.isEmpty {
                        hasStartedRound = true
                        isTimerRunning = true
                        startTimer()
                    }
                }
            }
            .onChange(of: scores) { _, _ in saveGameState() }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                saveGameState()
            }
        }
    }
    
    private func initializeScores(for playerId: UUID) {
        if scores[playerId] == nil {
            scores[playerId] = Array(repeating: "", count: 18)
        }
    }
    
    private func updateScore(for player: BetComponents.Player, at index: Int, with score: String) {
        var playerScores = scores[player.id] ?? Array(repeating: "", count: 18)
        playerScores[index] = score
        scores[player.id] = playerScores

        // Update group scores in BetManager
        if let groupIndex = groupManager.currentGroupIndex {
            betManager.updateGroupScores(scores, forGroup: groupIndex)
        }

        // Start timer when first score is entered
        if !hasStartedRound && !score.isEmpty {
            hasStartedRound = true
            isTimerRunning = true
            startTimer()
        }
        
        // Save game state after score update
        saveGameState()
    }
    
    private func toggleTimer() {
        isTimerRunning.toggle()
        if isTimerRunning {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if elapsedTime >= maxTimerDuration {
                stopTimer()
            } else {
                elapsedTime += 1
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func saveGameState() {
        gameStateManager.saveCurrentGame(
            course: course,
            teeBox: teeBox,
            players: players,
            scores: scores,
            betManager: betManager,
            isCompleted: isPosted,
            selectedPlayerId: selectedPlayerId
        )
    }
    
    private let teamColors: [Color] = [
        Color(red: 0.91, green: 0.3, blue: 0.24),   // Vibrant Red
        Color(red: 0.0, green: 0.48, blue: 0.8),    // Ocean Blue
        Color.teamGold,                              // Team Gold
        Color(red: 0.6, green: 0.2, blue: 0.8)      // Royal Purple
    ]
}

// MARK: - Subviews
private struct PlayerCarouselView: View {
    let players: [BetComponents.Player]
    @Binding var selectedPlayerId: UUID?
    let isScoreFieldFocused: Bool
    let getTeamColor: (BetComponents.Player, GroupManager) -> Color?
    let geometry: GeometryProxy
    @EnvironmentObject private var groupManager: GroupManager
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollView in
                HStack(spacing: 12) {
                    ForEach(players, id: \.id) { player in
                        PlayerButton(
                            player: player,
                            isSelected: selectedPlayerId == player.id,
                            teamColor: getTeamColor(player, groupManager)
                        )
                        .id(player.id)
                        .onTapGesture {
                            if !isScoreFieldFocused {
                                withAnimation {
                                    selectedPlayerId = player.id
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .onChange(of: selectedPlayerId) { _, newValue in
                    if let id = newValue {
                        withAnimation {
                            scrollView.scrollTo(id, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: geometry.size.height * 0.12)
        .background(Color.primaryGreen.opacity(0.2))
    }
}

private struct ScorecardMainContentView: View {
    let teeBox: BetComponents.TeeBox
    let currentPlayer: BetComponents.Player
    let currentPlayerScores: [String]
    let updateScore: (BetComponents.Player, Int, String) -> Void
    let geometry: GeometryProxy
    @State private var showingBackNine = false
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 8) {
            ScorecardGridView(
                holes: showingBackNine ? Array(teeBox.holes.suffix(9)) : Array(teeBox.holes.prefix(9)),
                scores: showingBackNine ? Array(currentPlayerScores.suffix(9)) : Array(currentPlayerScores.prefix(9)),
                onScoreUpdate: { index, score in
                    updateScore(currentPlayer, index + (showingBackNine ? 9 : 0), score)
                }
            )
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        if value.translation.width > threshold && showingBackNine {
                            withAnimation { showingBackNine = false }
                        } else if value.translation.width < -threshold && !showingBackNine {
                            withAnimation { showingBackNine = true }
                        }
                    }
            )
            
            ScorecarTotalsView(
                holes: teeBox.holes,
                scores: currentPlayerScores
            )
        }
        .frame(maxHeight: geometry.size.height * 0.73)
    }
}

private struct ScorecardHeaderView: View {
    let course: GolfCourse
    @Binding var showMenu: Bool
    @State private var showGroupSetup = false
    @Binding var showPlayerSelection: Bool
    @EnvironmentObject private var groupManager: GroupManager
    @EnvironmentObject private var userProfile: UserProfile
    @Binding var showBetCreation: Bool
    @Binding var showLeaderboard: Bool
    @Binding var scores: [UUID: [String]]
    let players: [BetComponents.Player]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { showMenu = true }) {
                    Image(systemName: "line.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.2))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Add test button
                Button(action: populateTestScores) {
                    Text("Test Scores")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.primaryGreen)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            VStack(spacing: 4) {
                Text(course.name)
                    .font(.custom("Avenir-Black", size: 24))
                    .foregroundColor(.white)
                
                if let currentGroup = groupManager.currentGroup,
                   let groupIndex = groupManager.currentGroupIndex {
                    HStack {
                        Text("Group \(groupIndex + 1) • \(currentGroup.count) Players")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        Button(action: { showGroupSetup = true }) {
                            Image(systemName: "pencil.circle")
                                .foregroundColor(.white)
                        }
                    }
                } else {
                    Button(action: { showGroupSetup = true }) {
                        Text("Setup Groups")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                    }
                }
            }
            
            Spacer()
            
            Button(action: { showPlayerSelection = true }) {
                Image(systemName: "person.badge.plus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.9)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        
        // Navigation Tabs
        ScorecardNavigationTabs(
            showLeaderboard: $showLeaderboard,
            showBetCreation: $showBetCreation,
            selectedGroupPlayers: groupManager.currentGroup ?? [],
            currentPlayerIndex: 0
        )
        .sheet(isPresented: $showGroupSetup) {
            NavigationView {
                GroupSetupView(groupManager: groupManager)
                    .environmentObject(groupManager)
                    .environmentObject(userProfile)
            }
        }
    }
    
    private func populateTestScores() {
        var newScores: [UUID: [String]] = [:]
        
        // Define test scores for each player
        let testScores: [String: [String]] = [
            "Nate Weant": ["4","4","5","4","5","6","4","3","3","5","4","4","4","5","3","5","4","3"],
            "Rolf Morstead": ["4","4","5","3","5","7","4","4","3","4","4","4","6","6","3","6","4","5"],
            "Chicken Man": ["5","5","4","4","3","7","4","5","4","4","5","4","4","6","4","5","4","4"],
            "Erik Hsu": ["2","5","5","4","4","6","6","4","4","4","3","4","3","6","3","4","3","4"],
            "Wade House": ["4","4","5","4","4","7","4","3","3","4","5","4","4","5","3","4","3","4"],
            "William Sparks": ["5","5","6","3","6","6","6","5","3","4","5","4","5","4","3","6","3","6"],
            "Rocky Burks": ["4","5","7","5","4","5","5","4","4","5","5","3","5","6","3","5","4","4"]
        ]
        
        // Map scores to players by matching first and last names
        for player in players {
            let fullName = "\(player.firstName) \(player.lastName)"
            if let scores = testScores[fullName] {
                newScores[player.id] = scores
            }
        }
        
        // Only update scores if we found matches
        if !newScores.isEmpty {
            scores = newScores
        }
    }
}

private struct ScorecardFooterView: View {
    let players: [BetComponents.Player]
    let playerScores: [UUID: [String]]
    let teeBox: BetComponents.TeeBox
    let betManager: BetManager
    @Binding var isPosted: Bool
    @Binding var showPostConfirmation: Bool
    @Binding var showUnpostConfirmation: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Stats row
            HStack {
                let bigWinner = Array(players.enumerated())
                    .map { (index, player) in
                        let viewModel = PlayerStatsViewModel(
                            player: player,
                            index: index,
                            playerScores: playerScores,
                            teeBox: teeBox,
                            betManager: betManager
                        )
                        return (player, viewModel.winnings)
                    }
                    .max(by: { $0.1 < $1.1 })
                
                if let winner = bigWinner {
                    Text("Current Big Winner: ")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(winner.0.firstName)
                        .font(.headline)
                        .foregroundColor(.teamGold)
                    Text(String(format: " ($%.0f)", winner.1))
                        .font(.headline)
                        .foregroundColor(.teamGold)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.primaryGreen)
            
            // Post/Unpost Buttons
            HStack(spacing: 20) {
                Button(action: { showUnpostConfirmation = true }) {
                    Text("Unpost")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.red.opacity(0.8))
                        )
                }
                .opacity(isPosted ? 1 : 0.5)
                .disabled(!isPosted)
                
                Button(action: { showPostConfirmation = true }) {
                    Text("Post")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.primaryGreen)
                        )
                }
                .opacity(isPosted ? 0.5 : 1)
                .disabled(isPosted)
            }
            .padding()
            .background(Color.white)
        }
    }
}

private struct PostAnimationOverlay: View {
    @Binding var showPostAnimation: Bool
    
    var body: some View {
        if showPostAnimation {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .overlay(
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("Round Posted!")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                )
        }
    }
}

struct ScorecardTimerView: View {
    let formattedTime: String
    let isTimerRunning: Bool
    let toggleTimer: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: "clock")
                    .font(.system(size: 18, weight: .semibold))
                Text(formattedTime)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
            }
            .foregroundColor(.white)
            
            Spacer()
            
            Button(action: toggleTimer) {
                Image(systemName: isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.primaryGreen, Color.deepNavyBlue]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}

struct ScorecardGridView: View {
    let holes: [BetComponents.HoleInfo]
    let scores: [String]
    let onScoreUpdate: (Int, String) -> Void
    @State private var focusedHoleIndex: Int?
    
    var body: some View {
        VStack(spacing: 1) {
            // Header row
            HStack {
                Group {
                    Text("Hole")
                        .frame(width: 40)
                    Text("Yards")
                        .frame(width: 60)
                    Text("Par")
                        .frame(width: 40)
                    Text("Score")
                        .frame(width: 100)
                }
                .font(.subheadline.bold())
                .foregroundColor(.white)
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.primaryGreen, Color.deepNavyBlue]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            // Hole rows
            ForEach(holes.indices, id: \.self) { index in
                HoleRowView(
                    hole: holes[index],
                    score: scores[index],
                    holeIndex: index,
                    isLastHole: index == holes.count - 1,
                    focusedHoleIndex: $focusedHoleIndex,
                    onScoreUpdate: { onScoreUpdate(index, $0) }
                )
                
                if index < holes.count - 1 {
                    Divider()
                        .background(Color.gray.opacity(0.2))
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.primaryGreen.opacity(0.1), Color.deepNavyBlue.opacity(0.1)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

private struct HoleRowView: View {
    let hole: BetComponents.HoleInfo
    let score: String
    let holeIndex: Int
    let isLastHole: Bool
    @Binding var focusedHoleIndex: Int?
    let onScoreUpdate: (String) -> Void
    
    var body: some View {
        HStack {
            Text("\(hole.number)")
                .frame(width: 40)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primaryGreen)
            
            Text("\(hole.yardage)")
                .frame(width: 60)
                .font(.system(size: 16))
                .foregroundColor(.deepNavyBlue)
            
            Text("\(hole.par)")
                .frame(width: 40)
                .font(.system(size: 16))
                .foregroundColor(.primaryGreen)
            
            ScoreDisplayView(
                score: score,
                par: hole.par,
                holeIndex: holeIndex,
                isLastHole: isLastHole,
                scoreText: Binding(
                    get: { score },
                    set: { onScoreUpdate($0) }
                ),
                focusedHoleIndex: $focusedHoleIndex
            )
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    hole.number.isMultiple(of: 2) ? Color.primaryGreen.opacity(0.05) : Color.white,
                    hole.number.isMultiple(of: 2) ? Color.deepNavyBlue.opacity(0.1) : Color.white.opacity(0.95)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}

struct ScorecarTotalsView: View {
    let holes: [BetComponents.HoleInfo]
    let scores: [String]
    
    private var frontNinePar: Int {
        holes.prefix(9).reduce(0) { $0 + $1.par }
    }
    
    private var backNinePar: Int {
        holes.suffix(9).reduce(0) { $0 + $1.par }
    }
    
    private var totalPar: Int {
        frontNinePar + backNinePar
    }
    
    private var frontNineScore: Int {
        scores.prefix(9)
            .compactMap { Int($0) }
            .reduce(0, +)
    }
    
    private var backNineScore: Int {
        scores.suffix(9)
            .compactMap { Int($0) }
            .reduce(0, +)
    }
    
    private var totalScore: Int {
        frontNineScore + backNineScore
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Front 9:")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(frontNineScore)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            HStack {
                Text("Back 9:")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(backNineScore)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(Color.white)
            
            HStack {
                Text("Total:")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(totalScore)")
                    .font(.title3.bold())
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.primaryGreen, Color.deepNavyBlue]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct KeyboardToolbarModifier: ViewModifier {
    @Binding var scoreText: String
    @FocusState.Binding var isFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if isFocused {
                        HStack {
                            Button("❌") {
                                withAnimation {
                                    scoreText = "❌"
                                }
                                isFocused = false
                            }
                            .foregroundColor(.red)
                            Spacer()
                            Button("Clear") {
                                withAnimation {
                                    scoreText = ""
                                }
                            }
                            .foregroundColor(.red)
                            Button("Done") {
                                isFocused = false
                            }
                            .foregroundColor(.primaryGreen)
                        }
                    }
                }
            }
    }
}

extension View {
    func keyboardToolbar(scoreText: Binding<String>, isFocused: FocusState<Bool>.Binding) -> some View {
        modifier(KeyboardToolbarModifier(scoreText: scoreText, isFocused: isFocused))
    }
}

struct ScoreDisplayView: View {
    let score: String
    let par: Int
    let holeIndex: Int
    let isLastHole: Bool
    @Binding var scoreText: String
    @Binding var focusedHoleIndex: Int?
    @State private var showClearButton = false
    @State private var previousScore: String = ""
    @State private var autoDismissTask: DispatchWorkItem?
    @FocusState private var isTextFieldFocused: Bool
    
    private var scoreInt: Int? {
        if scoreText == "❌" { return nil }
        return Int(scoreText)
    }
    
    private func colorForScore(_ score: Int) -> Color {
        if score == 1 { return .secondaryGold }     // Ace/Hole in One
        if score < par - 1 { return .secondaryGold } // Eagle or better
        if score == par - 1 { return .red }         // Birdie
        if score == par { return .primaryGreen }    // Par
        if score == par + 1 { return .blue }        // Bogey
        if score == par + 2 { return .purple }      // Double Bogey
        return .purple                              // Triple Bogey or worse
    }
    
    private func emojiForScore(_ score: Int) -> String? {
        if score == 1 { return "⭐️" }      // Ace
        if score == 2 { return "✌️" }      // Deuce
        if score >= par + 3 { return "💩" } // Triple bogey or worse
        return nil
    }
    
    private func startAutoDismissTimer() {
        autoDismissTask?.cancel()
        autoDismissTask = DispatchWorkItem {
            if isTextFieldFocused {
                isTextFieldFocused = false
            }
        }
        if let task = autoDismissTask {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: task)
        }
    }
    
    @ViewBuilder
    private func scoreTextField() -> some View {
        ZStack(alignment: .trailing) {
            // Score input field
            TextField("", text: $scoreText)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(width: 60)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(scoreText == "❌" ? .red : (scoreInt.map(colorForScore) ?? .primary))
                .textFieldStyle(PlainTextFieldStyle())
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(focusedHoleIndex == holeIndex ? Color.primaryGreen : Color.clear, 
                               lineWidth: focusedHoleIndex == holeIndex ? 2 : 0)
                )
                .focused($isTextFieldFocused)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        if isTextFieldFocused {
                            HStack {
                                Button("❌") {
                                    withAnimation {
                                        scoreText = "❌"
                                    }
                                }
                                .foregroundColor(.red)
                                Spacer()
                                Button("Clear") {
                                    withAnimation {
                                        scoreText = ""
                                    }
                                }
                                .foregroundColor(.red)
                                Button("Done") {
                                    isTextFieldFocused = false
                                }
                                .foregroundColor(.primaryGreen)
                            }
                        }
                    }
                }
            
            // Emoji positioned to the right
            if let score = scoreInt,
               let emoji = emojiForScore(score) {
                Text(emoji)
                    .font(.system(size: 24))
                    .opacity(0.7)
                    .offset(x: 40) // Position emoji to the right of the score box
            }
        }
        .frame(width: 100, height: 44) // Fixed frame to prevent layout shifts
        .onTapGesture {
            focusedHoleIndex = holeIndex
            isTextFieldFocused = true
            startAutoDismissTimer()
        }
    }
    
    var body: some View {
        ZStack {
            scoreTextField()
            
            if !scoreText.isEmpty {
                if let currentScore = scoreInt {
                    scoreTextField().modifier(ScoreDecorationModifier(score: currentScore, par: par))
                }
            }
        }
        .onChange(of: focusedHoleIndex) { _, newValue in
            isTextFieldFocused = newValue == holeIndex
            if isTextFieldFocused {
                startAutoDismissTimer()
            }
        }
        .onChange(of: scoreText) { oldValue, newValue in
            if (Int(newValue) != nil || newValue == "❌") && newValue != oldValue {
                startAutoDismissTimer()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if scoreText == newValue {
                        if !isLastHole {
                            focusedHoleIndex = holeIndex + 1
                            isTextFieldFocused = true // Keep the keypad open
                        } else {
                            focusedHoleIndex = nil
                            isTextFieldFocused = false
                        }
                    }
                }
            }
        }
        .onDisappear {
            autoDismissTask?.cancel()
        }
    }
}

struct PlayerSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var playerManager: PlayerManager
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    @Binding var selectedPlayers: [BetComponents.Player]
    @State private var tempSelectedPlayers: Set<UUID> = []
    @State private var showAddPlayer = false
    @State private var newPlayerFirstName = ""
    @State private var newPlayerLastName = ""
    @State private var newPlayerEmail = ""
    @State private var showDeleteAlert = false
    @State private var playerToDelete: BetComponents.Player?
    @State private var showClearAllAlert = false
    
    var availablePlayers: [BetComponents.Player] {
        // Get all historical players from playerManager
        var allPlayers = Set(playerManager.getAvailablePlayers())
        
        // Add current user if available
        if let currentUser = userProfile.currentUser {
            allPlayers.insert(currentUser)
        }
        
        // Filter out players that are already selected
        return Array(allPlayers).filter { player in
            !selectedPlayers.contains { $0.id == player.id }
        }.sorted { $0.firstName < $1.firstName }
    }
    
    var body: some View {
        VStack {
            PlayerSelectionHeader(dismiss: dismiss)
            
            PlayerSelectionContent(
                availablePlayers: availablePlayers,
                tempSelectedPlayers: $tempSelectedPlayers,
                playerToDelete: $playerToDelete,
                showDeleteAlert: $showDeleteAlert,
                userProfile: userProfile
            )
            
            PlayerSelectionFooter(
                showAddPlayer: $showAddPlayer,
                showClearAllAlert: $showClearAllAlert,
                tempSelectedPlayers: tempSelectedPlayers,
                availablePlayers: availablePlayers,
                playerManager: playerManager,
                dismiss: dismiss
            )
        }
        .background(Color.gray.opacity(0.1))
        .onAppear {
            tempSelectedPlayers.removeAll()
        }
        .sheet(isPresented: $showAddPlayer) {
            AddPlayerSheet(
                newPlayerFirstName: $newPlayerFirstName,
                newPlayerLastName: $newPlayerLastName,
                newPlayerEmail: $newPlayerEmail,
                playerManager: playerManager,
                onDismiss: {
                    // Refresh the view when a new player is added
                    tempSelectedPlayers.removeAll()
                }
            )
        }
        .alert("Delete Player", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                playerToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let player = playerToDelete {
                    // Remove from historical players
                    playerManager.removePlayerFromHistorical(player)
                }
                playerToDelete = nil
            }
        } message: {
            if let player = playerToDelete {
                Text("Are you sure you want to delete \(player.firstName) \(player.lastName)?")
            }
        }
        .alert("Clear All Players", isPresented: $showClearAllAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                playerManager.clearAllPlayers()
            }
        } message: {
            Text("Are you sure you want to remove all players? This action cannot be undone.")
        }
    }
}

private struct PlayerSelectionHeader: View {
    let dismiss: DismissAction
    
    var body: some View {
        HStack {
            Spacer()
            Text("Select Players")
                .font(.title3.bold())
                .foregroundColor(.white)
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.primaryGreen)
    }
}

private struct PlayerSelectionContent: View {
    let availablePlayers: [BetComponents.Player]
    @Binding var tempSelectedPlayers: Set<UUID>
    @Binding var playerToDelete: BetComponents.Player?
    @Binding var showDeleteAlert: Bool
    let userProfile: UserProfile
    
    var body: some View {
        if availablePlayers.isEmpty {
            VStack {
                Text("No Available Players")
                    .font(.headline)
                Text("Add players using the + button")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxHeight: .infinity)
        } else {
            List {
                ForEach(availablePlayers) { player in
                    PlayerSelectionRow(
                        player: player,
                        isSelected: tempSelectedPlayers.contains(player.id)
                    )
                    .onTapGesture {
                        if tempSelectedPlayers.contains(player.id) {
                            tempSelectedPlayers.remove(player.id)
                        } else {
                            tempSelectedPlayers.insert(player.id)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if player.id != userProfile.currentUser?.id {
                            Button(role: .destructive) {
                                playerToDelete = player
                                showDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct PlayerSelectionFooter: View {
    @Binding var showAddPlayer: Bool
    @Binding var showClearAllAlert: Bool
    let tempSelectedPlayers: Set<UUID>
    let availablePlayers: [BetComponents.Player]
    let playerManager: PlayerManager
    let dismiss: DismissAction
    
    var body: some View {
        HStack {
            Button(action: { showAddPlayer = true }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Add Player")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.primaryGreen)
                .cornerRadius(25)
            }
            
            Button(action: { showClearAllAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Clear All")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.red)
                .cornerRadius(25)
            }
            
            Button(action: {
                let newPlayers = availablePlayers.filter { tempSelectedPlayers.contains($0.id) }
                for player in newPlayers {
                    playerManager.addPlayerToCurrentRound(player)
                }
                dismiss()
            }) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.primaryGreen)
                    .cornerRadius(25)
            }
        }
        .padding()
    }
}

private struct AddPlayerSheet: View {
    @Binding var newPlayerFirstName: String
    @Binding var newPlayerLastName: String
    @Binding var newPlayerEmail: String
    let playerManager: PlayerManager
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Player")) {
                    TextField("First Name", text: $newPlayerFirstName)
                        .textInputAutocapitalization(.words)
                    TextField("Last Name", text: $newPlayerLastName)
                        .textInputAutocapitalization(.words)
                    TextField("Email (Optional)", text: $newPlayerEmail)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
            }
            .navigationTitle("Add Player")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Add") {
                    playerManager.addPlayer(
                        firstName: newPlayerFirstName,
                        lastName: newPlayerLastName,
                        email: newPlayerEmail
                    )
                    newPlayerFirstName = ""
                    newPlayerLastName = ""
                    newPlayerEmail = ""
                    onDismiss()
                    dismiss()
                }
                .disabled(newPlayerFirstName.isEmpty || newPlayerLastName.isEmpty)
            )
        }
    }
}

struct PlayerSelectionRow: View {
    let player: BetComponents.Player
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(player.firstName + " " + player.lastName)
                    .font(.headline)
                    .foregroundColor(.teamGold)
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.teamGold : Color.gray.opacity(0.3), lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.primaryGreen.opacity(0.1) : Color.white)
                )
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

struct LeaderboardView: View {
    let course: GolfCourse
    let teeBox: BetComponents.TeeBox
    let players: [BetComponents.Player]
    let playerScores: [UUID: [String]]
    @Binding var currentPlayerId: UUID?
    let onScoresImported: ([UUID: [String]], [BetComponents.Player]) -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var betManager: BetManager
    @EnvironmentObject var groupManager: GroupManager
    @State private var showMenu = false
    @State private var showQRCode = false
    @State private var showQRScanner = false
    @State private var scannedCode: String?
    @State private var showImportAlert = false
    @State private var importedScoreData: ShareableScoreData?
    @State private var expandedPlayers: Set<UUID> = []
    @State private var showPostConfirmation = false
    @State private var showUnpostConfirmation = false
    @State private var showPostAnimation = false
    @State private var isPosted = false
    
    var body: some View {
        ZStack {  // Changed to ZStack to properly layer the post animation
            VStack(spacing: 0) {
                LeaderboardHeaderView(
                    showMenu: $showMenu,
                    isGroupLeader: groupManager.isGroupLeader
                )
                
                LeaderboardContentView(
                    players: players,
                    playerScores: playerScores,
                    teeBox: teeBox,
                    betManager: betManager,
                    expandedPlayers: $expandedPlayers
                )
                
                LeaderboardFooterView(
                    players: players,
                    playerScores: playerScores,
                    teeBox: teeBox,
                    betManager: betManager,
                    isPosted: $isPosted,
                    showPostConfirmation: $showPostConfirmation,
                    showUnpostConfirmation: $showUnpostConfirmation
                )
            }
            
            if showPostAnimation {
                PostAnimationOverlay(showPostAnimation: $showPostAnimation)
            }
            
            if showMenu {
                SideMenuView(
                    isShowing: $showMenu,
                    showPlayerList: .constant(false),
                    showFourBallMatchSetup: .constant(false)
                )
            }
        }
        .alert("Post Round", isPresented: $showPostConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Post") {
                // Merge all group scores before posting
                betManager.mergeGroupScores()
                
                // Update scores and teeBox in BetManager
                betManager.updateScoresAndTeeBox(playerScores, teeBox)
                
                withAnimation {
                    isPosted = true
                    showPostAnimation = true
                }
                
                // Dismiss the animation after 1.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showPostAnimation = false
                    }
                }
            }
        } message: {
            Text("This will finalize the scorecard and update The Sheet. Continue?")
        }
        .alert("Unpost Round", isPresented: $showUnpostConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Unpost", role: .destructive) {
                // Clear scores in BetManager
                betManager.updateScoresAndTeeBox([:], teeBox)
                
                withAnimation {
                    isPosted = false
                }
            }
        } message: {
            Text("Are you sure you want to unpost these scores?")
        }
        .sheet(isPresented: $showQRCode) {
            QRCodeShareView(
                course: course,
                teeBox: teeBox,
                players: players,
                playerScores: playerScores,
                groupManager: groupManager
            )
        }
        .sheet(isPresented: $showQRScanner) {
            QRScannerView(scannedCode: $scannedCode)
                .ignoresSafeArea()
        }
        .onChange(of: scannedCode) { oldValue, newValue in
            if let code = newValue,
               let scoreData = ShareableScoreData.fromQRString(code) {
                importedScoreData = scoreData
                showImportAlert = true
            }
        }
        .alert("Import Scores", isPresented: $showImportAlert) {
            Button("Cancel", role: .cancel) {
                importedScoreData = nil
            }
            Button("Import") {
                if let scoreData = importedScoreData {
                    importScores(from: scoreData)
                }
                importedScoreData = nil
            }
        } message: {
            if let scoreData = importedScoreData {
                Text("Import scores from \(scoreData.courseName) for \(scoreData.players.count) players?")
            }
        }
    }
    
    private func importScores(from scoreData: ShareableScoreData) {
        // Verify the course and tee box match
        guard scoreData.courseId == course.id && scoreData.teeBoxName == teeBox.name else {
            return
        }
        
        var importedScores: [UUID: [String]] = [:]
        var importedPlayers: [BetComponents.Player] = []
        
        // Process imported data
        for playerData in scoreData.players {
            let player = BetComponents.Player(
                id: playerData.id,
                firstName: playerData.firstName,
                lastName: playerData.lastName,
                email: ""
            )
            importedPlayers.append(player)
            importedScores[playerData.id] = playerData.scores
        }
        
        // Notify parent view to update scores and players
        onScoresImported(importedScores, importedPlayers)
        
        // Update group scores in BetManager
        if let groupIndex = groupManager.currentGroupIndex {
            betManager.mergeGroupScores()
            betManager.updateGroupScores(importedScores, forGroup: groupIndex)
        }
    }
}

private struct LeaderboardHeaderView: View {
    @Binding var showMenu: Bool
    let isGroupLeader: Bool
    @State private var showQRCode = false
    @State private var showQRScanner = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Button(action: { showMenu = true }) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            if isGroupLeader {
                Button(action: { showQRCode = true }) {
                    Image(systemName: "qrcode")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Button(action: { showQRScanner = true }) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .standardHorizontalPadding()
        .padding(.vertical, 10)
        .background(Color.primaryGreen)
    }
}

struct QRCodeShareView: View {
    let course: GolfCourse
    let teeBox: BetComponents.TeeBox
    let players: [BetComponents.Player]
    let playerScores: [UUID: [String]]
    let groupManager: GroupManager
    @Environment(\.dismiss) private var dismiss
    
    private var qrCodeImage: UIImage? {
        guard let currentGroup = groupManager.currentGroup,
              let groupId = currentGroup.first?.id else {
            return nil
        }
        
        let scoreData = ShareableScoreData(
            groupId: groupId,
            courseId: course.id,
            courseName: course.name,
            teeBoxId: UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", teeBox.name.hashValue))") ?? UUID(),
            teeBoxName: teeBox.name,
            timestamp: Date(),
            players: players.map { player in
                ShareableScoreData.PlayerData(
                    id: player.id,
                    firstName: player.firstName,
                    lastName: player.lastName,
                    scores: playerScores[player.id] ?? Array(repeating: "", count: 18)
                )
            }
        )
        
        guard let qrString = scoreData.toQRString() else { return nil }
        return QRCodeUtils.generateQRCode(from: qrString)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Share Scores")
                .font(.title.bold())
                .foregroundColor(.primaryGreen)
            
            if let qrImage = qrCodeImage {
                QRCodeView(qrImage: qrImage)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 8)
                    )
            } else {
                Text("Unable to generate QR code")
                    .foregroundColor(.red)
            }
            
            Text("Have the group leader scan this code\nto import your scores")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.primaryGreen)
                    .cornerRadius(25)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

private struct PlayerStatsViewModel {
    let player: BetComponents.Player
    let index: Int
    let playerScores: [UUID: [String]]
    let teeBox: BetComponents.TeeBox
    let betManager: BetManager
    
    var stats: (lastHole: String, score: String, scoreColor: Color, doDas: Int, skins: Int) {
        let scores = playerScores[player.id] ?? Array(repeating: "", count: 18)
        let lastPlayedHole = scores.lastIndex(where: { !$0.isEmpty }) ?? -1
        let lastHole = lastPlayedHole >= 0 ? "\(lastPlayedHole + 1)" : "-"
        
        var totalScore = 0
        var validScores = 0
        
        for (index, score) in scores.enumerated() {
            if let scoreInt = Int(score) {
                totalScore += scoreInt - teeBox.holes[index].par
                validScores += 1
            }
        }
        
        let scoreString = validScores > 0 ? "\(totalScore >= 0 ? "+" : "")\(totalScore)" : "-"
        let scoreColor: Color = {
            if validScores == 0 { return .gray }
            if totalScore < 0 { return .red }
            if totalScore > 0 { return .black }
            return .primaryGreen
        }()
        
        let doDas = betManager.doDaBets.filter { bet in
            bet.players.contains { $0.id == player.id }
        }.flatMap { bet in
            bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox).filter { $0.key == player.id && $0.value > 0 }
        }.count

        let skins = betManager.skinsBets.filter { bet in
            bet.players.contains { $0.id == player.id }
        }.flatMap { bet in
            bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox).filter { $0.key == player.id && $0.value > 0 }
        }.count
        
        return (lastHole, scoreString, scoreColor, doDas, skins)
    }
    
    var winnings: Double {
        var total = 0.0
        
        // Individual match bets
        for bet in betManager.individualBets {
            let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
            if bet.player1.id == player.id {
                total += winnings
            } else if bet.player2.id == player.id {
                total -= winnings
            }
        }
        
        // Four-ball bets
        for bet in betManager.fourBallBets {
            let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
            if bet.team1Player1.id == player.id || bet.team1Player2.id == player.id {
                total += winnings
            } else if bet.team2Player1.id == player.id || bet.team2Player2.id == player.id {
                total -= winnings
            }
        }
        
        // Skins
        for bet in betManager.skinsBets {
            if let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
                total += winnings
            }
        }
        
        // DoDas
        for bet in betManager.doDaBets {
            if let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
                total += winnings
            }
        }
        
        // Alabama bets
        for bet in betManager.alabamaBets {
            if let teamIndex = bet.teams.firstIndex(where: { team in
                team.contains(where: { $0.id == player.id })
            }) {
                for otherTeamIndex in bet.teams.indices where otherTeamIndex != teamIndex {
                    let results = bet.calculateTeamResults(
                        playerTeamIndex: teamIndex,
                        otherTeamIndex: otherTeamIndex,
                        scores: playerScores,
                        teeBox: teeBox
                    )
                    total += results.total
                }
            }
        }
        
        return total
    }
}

private struct PlayerRowView: View {
    let player: BetComponents.Player
    let index: Int
    let lastHole: String
    let score: String
    let scoreColor: Color
    let winnings: Double
    let doDas: Int
    let skins: Int
    let isExpanded: Bool
    let betManager: BetManager
    let playerScores: [UUID: [String]]
    let teeBox: BetComponents.TeeBox
    let onExpandToggle: () -> Void
    
    var body: some View {
        Button(action: onExpandToggle) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                    
                    Text(player.firstName)
                        .lineLimit(1)
                }
                .frame(minWidth: 80, maxWidth: .infinity, alignment: .leading)
                
                Text(lastHole)
                    .frame(width: 40)
                
                Text(score)
                    .frame(width: 50)
                    .foregroundColor(scoreColor)
                
                Text(String(format: "$%.0f", winnings))
                    .frame(width: 65)
                    .foregroundColor(winnings >= 0 ? .primaryGreen : .red)
                
                Text("\(skins)")
                    .frame(width: 40)
                
                Text("\(doDas)")
                    .frame(width: 40)
            }
            .standardHorizontalPadding()
            .padding(.vertical, 10)
            .background(Color.white)
        }
        .buttonStyle(.plain)
    }
}

private struct BetDetailRow: View {
    let type: String
    let opponent: String
    let amount: Double
    
    var body: some View {
        HStack {
            Text(type)
                .frame(width: 70, alignment: .leading)
            Text("vs")
                .foregroundColor(.gray)
            Text(opponent)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(String(format: "$%.0f", amount))
                .frame(width: 65)
                .foregroundColor(amount >= 0 ? .primaryGreen : .red)
        }
        .font(.system(size: 14))
    }
}

struct SideMenuView: View {
    @Binding var isShowing: Bool
    @Binding var showPlayerList: Bool
    @Binding var showFourBallMatchSetup: Bool
    @State private var showMyAccount = false
    @State private var showMyBets = false
    @State private var showTheSheet = false
    @State private var showSideBets = false
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing = false
                }
            
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 20) {
                    MenuButton(
                        icon: "person.circle",
                        text: "My Account",
                        action: {
                            showMyAccount = true
                        }
                    )
                    
                    MenuButton(
                        icon: "dollarsign.circle",
                        text: "My Bets",
                        action: {
                            showMyBets = true
                        }
                    )
                    
                    MenuButton(
                        icon: "list.bullet.rectangle",
                        text: "The Sheet",
                        action: {
                            showTheSheet = true
                        }
                    )
                    
                    MenuButton(
                        icon: "dollarsign.circle.fill",
                        text: "Side Bets",
                        action: {
                            showSideBets = true
                        }
                    )
                    
                    MenuButton(
                        icon: "person.2",
                        text: "Players",
                        action: {
                            showPlayerList = true
                            isShowing = false
                        }
                    )
                    
                    Spacer()
                }
                .standardHorizontalPadding()
                .padding(.top, 100)
                .frame(width: min(UIScreen.main.bounds.width * 0.85, 280))
                .background(Color.primaryGreen)
                .offset(x: isShowing ? 0 : -UIScreen.main.bounds.width)
                .animation(.default, value: isShowing)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showMyAccount) {
            NavigationView {
                MyAccountView()
            }
        }
        .sheet(isPresented: $showMyBets) {
            NavigationView {
                MyBetsView()
                    .environmentObject(betManager)
                    .environmentObject(userProfile)
            }
        }
        .sheet(isPresented: $showTheSheet) {
            NavigationView {
                TheSheetView()
                    .environmentObject(betManager)
                    .environmentObject(userProfile)
            }
        }
        .sheet(isPresented: $showSideBets) {
            NavigationView {
                SideBetsView()
                    .environmentObject(betManager)
                    .environmentObject(userProfile)
            }
        }
    }
}

struct MenuButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                Text(text)
                    .font(.title3)
                Spacer()
            }
            .foregroundColor(.white)
            .standardHorizontalPadding()
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.15))
            )
        }
    }
}

struct PlayerButton: View {
    let player: BetComponents.Player
    let isSelected: Bool
    let teamColor: Color?
    @EnvironmentObject private var groupManager: GroupManager
    
    var body: some View {
        VStack(spacing: 4) {
            // Player Avatar
            ZStack {
                Circle()
                    .fill(isSelected ? Color.primaryGreen : Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(teamColor ?? .clear, lineWidth: 2)
                    )
                
                Text(String(player.firstName.prefix(1)))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isSelected ? .white : .gray)
            }
            
            // Player Name
            Text(player.firstName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.teamGold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.teamGold : Color.gray.opacity(0.3), lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.primaryGreen.opacity(0.1) : Color.white)
                )
        )
    }
}

struct ScoreDecorationModifier: ViewModifier {
    let score: Int
    let par: Int
    
    private func colorForScore(_ score: Int) -> Color {
        if score == 1 { return .secondaryGold }     // Ace/Hole in One
        if score < par - 1 { return .secondaryGold } // Eagle or better
        if score == par - 1 { return .red }         // Birdie
        if score == par { return .primaryGreen }    // Par
        if score == par + 1 { return .blue }        // Bogey
        if score == par + 2 { return .purple }      // Double Bogey
        return .purple                              // Triple Bogey or worse
    }
    
    func body(content: Content) -> some View {
        content.overlay(
            Group {
                if score < par - 1 {
                    // Double circle for eagle or better
                    ZStack {
                        Circle()
                            .stroke(colorForScore(score), lineWidth: 1.5)
                            .frame(width: 40, height: 40) // Increased size
                        Circle()
                            .stroke(colorForScore(score), lineWidth: 1.5)
                            .frame(width: 46, height: 46) // Increased size
                    }
                } else if score == par - 1 {
                    // Single circle for birdie
                    Circle()
                        .stroke(colorForScore(score), lineWidth: 1.5)
                        .frame(width: 40, height: 40) // Increased size
                } else if score == par + 1 {
                    // Single square for bogey
                    Rectangle()
                        .stroke(colorForScore(score), lineWidth: 1.5)
                        .frame(width: 40, height: 40) // Increased size
                } else if score == par + 2 {
                    // Double square for double bogey
                    ZStack {
                        Rectangle()
                            .stroke(colorForScore(score), lineWidth: 1.5)
                            .frame(width: 40, height: 40) // Increased size
                        Rectangle()
                            .stroke(colorForScore(score), lineWidth: 1.5)
                            .frame(width: 46, height: 46) // Increased size
                    }
                }
            }
        )
    }
}

struct ScoreboardRow: View {
    let playerName: String
    let amount: Double
    let showAnimation: Bool
    
    var body: some View {
        HStack {
            Text(playerName)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Spacer()
            
            Text(String(format: "$%.0f", amount))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(amount >= 0 ? .green : .red)
                .shadow(color: amount >= 0 ? .green.opacity(0.5) : .red.opacity(0.5), radius: showAnimation ? 12 : 8)
        }
        .standardHorizontalPadding()
        .padding(.vertical, 12)
        .background(Color.black)
        .overlay(
            Rectangle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        .white.opacity(showAnimation ? 0.2 : 0.1),
                        .clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
        )
        .scaleEffect(showAnimation ? 1.05 : 1.0)
        .brightness(showAnimation ? 0.1 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showAnimation)
    }
}

// Add QR code views
struct QRCodeView: View {
    let qrImage: UIImage
    
    var body: some View {
        Image(uiImage: qrImage)
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
    }
}

struct QRScannerView: View {
    @Binding var scannedCode: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Text("QR Scanner temporarily unavailable")
            .padding()
    }
}

struct LeaderboardContentView: View {
    let players: [BetComponents.Player]
    let playerScores: [UUID: [String]]
    let teeBox: BetComponents.TeeBox
    let betManager: BetManager
    @Binding var expandedPlayers: Set<UUID>
    
    private struct PlayerRow: Identifiable {
        let player: BetComponents.Player
        let index: Int
        var id: UUID { player.id }
    }
    
    private func playerRows() -> [PlayerRow] {
        Array(players.enumerated()).map { index, player in
            PlayerRow(player: player, index: index)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Column Headers
            HStack {
                Text("Player")
                    .frame(minWidth: 80, maxWidth: .infinity, alignment: .leading)
                Text("Thru")
                    .frame(width: 40)
                Text("Score")
                    .frame(width: 50)
                Text("Win/Loss")
                    .frame(width: 65)
                Text("Skins")
                    .frame(width: 40)
                Text("DoDas")
                    .frame(width: 40)
            }
            .standardHorizontalPadding()
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.1))
            
            // Player rows
            ForEach(playerRows()) { item in
                let viewModel = PlayerStatsViewModel(
                    player: item.player,
                    index: item.index,
                    playerScores: playerScores,
                    teeBox: teeBox,
                    betManager: betManager
                )
                let stats = viewModel.stats
                
                VStack(spacing: 0) {
                    PlayerRowView(
                        player: item.player,
                        index: item.index,
                        lastHole: stats.lastHole,
                        score: stats.score,
                        scoreColor: stats.scoreColor,
                        winnings: viewModel.winnings,
                        doDas: stats.doDas,
                        skins: stats.skins,
                        isExpanded: expandedPlayers.contains(item.player.id),
                        betManager: betManager,
                        playerScores: playerScores,
                        teeBox: teeBox,
                        onExpandToggle: {
                            if expandedPlayers.contains(item.player.id) {
                                expandedPlayers.remove(item.player.id)
                            } else {
                                expandedPlayers.insert(item.player.id)
                            }
                        }
                    )
                    
                    if expandedPlayers.contains(item.player.id) {
                        PlayerBetDetailsView(
                            player: item.player,
                            betManager: betManager,
                            playerScores: playerScores,
                            teeBox: teeBox
                        )
                    }
                    
                    Divider()
                }
            }
        }
    }
}

private struct LeaderboardFooterView: View {
    let players: [BetComponents.Player]
    let playerScores: [UUID: [String]]
    let teeBox: BetComponents.TeeBox
    let betManager: BetManager
    @Binding var isPosted: Bool
    @Binding var showPostConfirmation: Bool
    @Binding var showUnpostConfirmation: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Stats row
            HStack {
                let bigWinner = Array(players.enumerated())
                    .map { (index, player) in
                        let viewModel = PlayerStatsViewModel(
                            player: player,
                            index: index,
                            playerScores: playerScores,
                            teeBox: teeBox,
                            betManager: betManager
                        )
                        return (player, viewModel.winnings)
                    }
                    .max(by: { $0.1 < $1.1 })
                
                if let winner = bigWinner {
                    Text("Current Big Winner: ")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(winner.0.firstName)
                        .font(.headline)
                        .foregroundColor(.teamGold)
                    Text(String(format: " ($%.0f)", winner.1))
                        .font(.headline)
                        .foregroundColor(.teamGold)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.primaryGreen)
            
            // Post/Unpost Buttons
            HStack(spacing: 20) {
                Button(action: { showUnpostConfirmation = true }) {
                    Text("Unpost")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.red.opacity(0.8))
                        )
                }
                .opacity(isPosted ? 1 : 0.5)
                .disabled(!isPosted)
                
                Button(action: { showPostConfirmation = true }) {
                    Text("Post")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.primaryGreen)
                        )
                }
                .opacity(isPosted ? 0.5 : 1)
                .disabled(isPosted)
            }
            .padding()
            .background(Color.white)
        }
    }
}


