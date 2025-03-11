import SwiftUI
import BetComponents
import AVFoundation
import CoreImage.CIFilterBuiltins
import CodeScanner

private extension View {
    func standardHorizontalPadding() -> some View {
        self.padding(.horizontal, 16)
    }
}

struct ScorecardView: View {
    let course: GolfCourse
    let teeBox: BetComponents.TeeBox
    @State private var showMenu = false
    @State private var showBetCreation = false
    @State private var showPlayerSelection = false
    @State private var selectedPlayerIndex = 0
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
    @GestureState private var dragOffset: CGFloat = 0
    @State private var selectedPlayers: [BetComponents.Player] = []
    @State private var expandedPlayers: Set<UUID> = []
    @State private var showPostConfirmation = false
    @State private var showUnpostConfirmation = false
    @State private var showPostAnimation = false
    @State private var isPosted = false
    
    private let maxTimerDuration: TimeInterval = 6 * 60 * 60 // 6 hours in seconds
    
    private var players: [BetComponents.Player] {
        var allPlayers = Set<BetComponents.Player>()
        
        // Add selected players
        allPlayers.formUnion(selectedPlayers)
        
        // Add current user if available
        if let currentUser = userProfile.currentUser {
            allPlayers.insert(currentUser)
        }
        
        // Add players from bets
        betManager.individualBets.forEach { bet in
            allPlayers.insert(bet.player1)
            allPlayers.insert(bet.player2)
        }
        
        betManager.fourBallBets.forEach { bet in
            allPlayers.insert(bet.team1Player1)
            allPlayers.insert(bet.team1Player2)
            allPlayers.insert(bet.team2Player1)
            allPlayers.insert(bet.team2Player2)
        }
        
        betManager.alabamaBets.forEach { bet in
            bet.teams.forEach { team in
                allPlayers.formUnion(team)
            }
        }
        
        betManager.doDaBets.forEach { bet in
            allPlayers.formUnion(bet.players)
        }
        
        betManager.skinsBets.forEach { bet in
            allPlayers.formUnion(bet.players)
        }
        
        return Array(allPlayers)
    }
    
    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScorecardHeaderView(
                    course: course,
                    showMenu: $showMenu,
                    showPlayerSelection: $showPlayerSelection,
                    showBetCreation: $showBetCreation,
                    showLeaderboard: $showLeaderboard
                )
                ScorecardContentView(
                    players: players,
                    expandedPlayers: $expandedPlayers,
                    playerScores: scores,
                    teeBox: teeBox,
                    betManager: betManager,
                    updateScore: updateScore
                )
                ScorecardFooterView(
                    players: players,
                    playerScores: scores,
                    teeBox: teeBox,
                    betManager: betManager,
                    isPosted: $isPosted,
                    showPostConfirmation: $showPostConfirmation,
                    showUnpostConfirmation: $showUnpostConfirmation
                )
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .overlay(PostAnimationOverlay(showPostAnimation: $showPostAnimation))
        .alert("Post Round", isPresented: $showPostConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Post") {
                // Merge all group scores before posting
                betManager.mergeGroupScores()
                
                // Update scores and teeBox in BetManager
                betManager.updateScoresAndTeeBox(scores, teeBox)
                
                withAnimation {
                    showPostAnimation = true
                    showPostConfirmation = false
                }
                // Dismiss the animation after 1.5 seconds and return to scorecard
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showPostAnimation = false
                        showPostConfirmation = false
                    }
                }
            }
        } message: {
            Text("This will finalize the scorecard and update The Sheet. Continue?")
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .sheet(isPresented: $showPlayerSelection) {
            PlayerSelectionView(selectedPlayers: $selectedPlayers)
                .onDisappear {
                    // Initialize scores for newly added players
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
                currentPlayerIndex: $selectedPlayerIndex,
                onScoresImported: { importedScores, importedPlayers in
                    // Update local scores with imported scores
                    for (playerId, playerScores) in importedScores {
                        scores[playerId] = playerScores
                    }
                    
                    // Add any new players
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
            // If there's a saved game, restore it
            if let savedGame = gameStateManager.currentGame,
               savedGame.courseId == course.id,
               savedGame.teeBoxName == teeBox.name {
                scores = savedGame.scores
                selectedPlayers = savedGame.players
                betManager.playerScores = savedGame.scores
                isPosted = savedGame.isCompleted
            }
        }
        .onChange(of: scores) { oldValue, newValue in
            // Save game state whenever scores change
            saveGameState()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            // Save game state when app goes to background
            saveGameState()
        }
    }
    
    private func initializeScores(for playerId: UUID) {
        if scores[playerId] == nil {
            scores[playerId] = Array(repeating: "", count: 18)
        }
    }
    
    private func updateScore(for player: BetComponents.Player, at index: Int, with score: String) {
        // Only allow score updates if the player is in the current group
        guard let currentGroup = groupManager.currentGroup,
              let currentUser = userProfile.currentUser,
              currentGroup.contains(where: { $0.id == currentUser.id }) else {
            return
        }

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
            isCompleted: isPosted
        )
    }
    
    private let teamColors: [Color] = [
        Color(red: 0.91, green: 0.3, blue: 0.24),   // Vibrant Red
        Color(red: 0.0, green: 0.48, blue: 0.8),    // Ocean Blue
        Color.teamGold,                              // Team Gold
        Color(red: 0.6, green: 0.2, blue: 0.8)      // Royal Purple
    ]
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
            .padding()
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
        }
        .sheet(isPresented: $showGroupSetup) {
            NavigationView {
                GroupSetupView(groupManager: groupManager)
                    .environmentObject(groupManager)
                    .environmentObject(userProfile)
            }
        }
    }
}

private struct ScorecardContentView: View {
    let players: [BetComponents.Player]
    @Binding var expandedPlayers: Set<UUID>
    let playerScores: [UUID: [String]]
    let teeBox: BetComponents.TeeBox
    let betManager: BetManager
    @EnvironmentObject private var groupManager: GroupManager
    @State private var selectedPlayerIndex = 0
    let updateScore: (BetComponents.Player, Int, String) -> Void
    
    func playerRows() -> [(player: BetComponents.Player, index: Int)] {
        Array(players.enumerated()).map { (index, player) in
            (player: player, index: index)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Player carousel
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                        PlayerButton(
                            player: player,
                            isSelected: selectedPlayerIndex == index,
                            teamColor: getTeamColor(for: player, groupManager: groupManager)
                        )
                        .onTapGesture {
                            selectedPlayerIndex = index
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color.primaryGreen.opacity(0.2))
            
            // Tee box info
            HStack {
                Text("Playing from:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(teeBox.name)
                    .font(.headline)
                    .foregroundColor(.primaryGreen)
                Spacer()
            }
            .padding(.horizontal)
            
            // Scorecard content
            VStack(spacing: 16) {
                // Front 9
                ScorecardGridView(
                    holes: Array(teeBox.holes.prefix(9)),
                    scores: playerScores[players[selectedPlayerIndex].id] ?? Array(repeating: "", count: 18),
                    onScoreUpdate: { index, score in
                        updateScore(players[selectedPlayerIndex], index, score)
                    }
                )
                
                // Back 9
                ScorecardGridView(
                    holes: Array(teeBox.holes.suffix(9)),
                    scores: playerScores[players[selectedPlayerIndex].id]?.suffix(9).map { String($0) } ?? Array(repeating: "", count: 9),
                    onScoreUpdate: { index, score in
                        updateScore(players[selectedPlayerIndex], index + 9, score)
                    }
                )
                
                // Totals
                ScorecarTotalsView(
                    holes: teeBox.holes,
                    scores: playerScores[players[selectedPlayerIndex].id] ?? Array(repeating: "", count: 18)
                )
            }
            .padding(.bottom)
        }
        .onChange(of: selectedPlayerIndex) { oldValue, newValue in
            // Dismiss keyboard when switching players
            DispatchQueue.main.async {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
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
    
    private let teamColors: [Color] = [
        Color(red: 0.91, green: 0.3, blue: 0.24),   // Vibrant Red
        Color(red: 0.0, green: 0.48, blue: 0.8),    // Ocean Blue
        Color.teamGold,                              // Team Gold
        Color(red: 0.6, green: 0.2, blue: 0.8)      // Royal Purple
    ]
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
    @State private var selectedHoleIndex: Int = 0
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 1) {
                // Header row
                HStack(spacing: 1) {
                    Text("Hole")
                        .frame(width: 80)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    
                    ForEach(holes) { hole in
                        Text("\(hole.number)")
                            .frame(width: 80)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.primaryGreen.opacity(0.95), Color.primaryGreen]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Par row
                HStack(spacing: 1) {
                    Text("Par")
                        .frame(width: 80)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    
                    ForEach(holes) { hole in
                        Text("\(hole.par)")
                            .frame(width: 80)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.deepNavyBlue.opacity(0.95), Color.deepNavyBlue]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Yardage row
                HStack(spacing: 1) {
                    Text("Yards")
                        .frame(width: 80)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    
                    ForEach(holes) { hole in
                        Text("\(hole.yardage)")
                            .frame(width: 80)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.primaryGreen.opacity(0.8), Color.primaryGreen.opacity(0.9)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Score row
                HStack(spacing: 1) {
                    Text("Score")
                        .frame(width: 80)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    
                    ForEach(Array(holes.indices), id: \.self) { index in
                        let score = scores[index]
                        ScoreDisplayView(
                            score: score,
                            par: holes[index].par,
                            scoreText: Binding(
                                get: { score },
                                set: { onScoreUpdate(index, $0) }
                            ),
                            onNext: {
                                if index < holes.count - 1 {
                                    selectedHoleIndex = index + 1
                                }
                            },
                            onPrevious: {
                                if index > 0 {
                                    selectedHoleIndex = index - 1
                                }
                            }
                        )
                        .frame(width: 80)
                    }
                }
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.deepNavyBlue.opacity(0.7), Color.deepNavyBlue.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
        }
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

struct ScoreDisplayView: View {
    let score: String
    let par: Int
    @Binding var scoreText: String
    @State private var showKeypad = false
    @State private var tempScore: String
    let onNext: () -> Void
    let onPrevious: () -> Void
    
    init(score: String, par: Int, scoreText: Binding<String>, onNext: @escaping () -> Void, onPrevious: @escaping () -> Void) {
        self.score = score
        self.par = par
        self._scoreText = scoreText
        self._tempScore = State(initialValue: score)
        self.onNext = onNext
        self.onPrevious = onPrevious
    }
    
    private var scoreInt: Int? {
        Int(tempScore)
    }
    
    private func colorForScore(_ score: Int) -> Color {
        if score == 1 || score < par - 1 { return .secondaryGold }
        if score == par - 1 { return .red }
        if score == par { return .primaryGreen }
        return .blue
    }
    
    var body: some View {
        Button(action: {
            tempScore = score  // Initialize with current score
            showKeypad = true
        }) {
            VStack(spacing: 4) {
                // Score box with decorations
                ZStack {
                    // Base score box
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .frame(width: 80, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    ZStack {
                        // Score display
                        if !tempScore.isEmpty {
                            Text(tempScore)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(scoreInt.map(colorForScore) ?? .primary)
                            
                            // Decorative shapes
                            if let currentScore = scoreInt {
                                if currentScore < par - 1 {
                                    // Double circle for eagle or better
                                    ZStack {
                                        Circle()
                                            .stroke(colorForScore(currentScore), lineWidth: 1.5)
                                            .frame(width: 36, height: 36)
                                        Circle()
                                            .stroke(colorForScore(currentScore), lineWidth: 1.5)
                                            .frame(width: 42, height: 42)
                                    }
                                } else if currentScore == par - 1 {
                                    // Single circle for birdie
                                    Circle()
                                        .stroke(colorForScore(currentScore), lineWidth: 1.5)
                                        .frame(width: 36, height: 36)
                                } else if currentScore == par + 1 {
                                    // Single square for bogey
                                    Rectangle()
                                        .stroke(colorForScore(currentScore), lineWidth: 1.5)
                                        .frame(width: 36, height: 36)
                                } else if currentScore == par + 2 {
                                    // Double square for double bogey
                                    ZStack {
                                        Rectangle()
                                            .stroke(colorForScore(currentScore), lineWidth: 1.5)
                                            .frame(width: 36, height: 36)
                                        Rectangle()
                                            .stroke(colorForScore(currentScore), lineWidth: 1.5)
                                            .frame(width: 42, height: 42)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Emoji indicators below the score
                if let currentScore = scoreInt {
                    if currentScore == 1 {
                        Text("⭐️")
                            .font(.caption)
                    } else if currentScore == 2 {
                        Text("✌️")
                            .font(.caption)
                    } else if currentScore > par + 2 {
                        Text("💩")
                            .font(.caption)
                    }
                }
            }
        }
        .sheet(isPresented: $showKeypad) {
            CustomNumberKeypad(
                text: Binding(
                    get: { tempScore },
                    set: { newValue in
                        tempScore = newValue
                        scoreText = newValue  // Update the parent's binding
                    }
                ),
                onNext: {
                    onNext()
                    showKeypad = false
                },
                onPrevious: {
                    onPrevious()
                    showKeypad = false
                }
            )
            .presentationDetents([.height(320)])  // Reduced height
            .presentationBackground(.clear)  // Clear background for sheet
        }
        .onChange(of: score) { oldValue, newValue in
            tempScore = newValue
        }
    }
}

struct CustomNumberKeypad: View {
    @Binding var text: String
    let onNext: () -> Void
    let onPrevious: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var inactivityTimer: Timer?
    
    var body: some View {
        VStack(spacing: 12) {  // Reduced spacing
            HStack(spacing: 20) {  // Reduced spacing
                ForEach(1...3, id: \.self) { number in
                    numberButton(String(number))
                }
            }
            HStack(spacing: 20) {  // Reduced spacing
                ForEach(4...6, id: \.self) { number in
                    numberButton(String(number))
                }
            }
            HStack(spacing: 20) {  // Reduced spacing
                ForEach(7...9, id: \.self) { number in
                    numberButton(String(number))
                }
            }
            HStack(spacing: 20) {  // Reduced spacing
                Button(action: {
                    onPrevious()
                    resetTimer()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .frame(width: 44, height: 44)  // Slightly smaller buttons
                        .foregroundColor(.white)
                        .background(Color.primaryGreen)
                        .clipShape(Circle())
                }
                numberButton("0")
                Button(action: {
                    onNext()
                    resetTimer()
                }) {
                    Image(systemName: "arrow.right")
                        .font(.title2)
                        .frame(width: 44, height: 44)  // Slightly smaller buttons
                        .foregroundColor(.white)
                        .background(Color.primaryGreen)
                        .clipShape(Circle())
                }
            }
            HStack(spacing: 20) {  // Reduced spacing
                numberButton("X")
            }
        }
        .padding(16)  // Reduced padding
        .background(Color.white.opacity(0.95))  // Semi-transparent background
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 5, y: 2)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            inactivityTimer?.invalidate()
        }
    }
    
    private func numberButton(_ number: String) -> some View {
        Button(action: {
            text = number
            resetTimer()
            if number != "X" {
                // Auto-dismiss after 0.5 seconds for number entries
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }) {
            Text(number)
                .font(.title2.bold())  // Slightly smaller font
                .frame(width: 44, height: 44)  // Slightly smaller buttons
                .foregroundColor(number == "X" ? .red : .primary)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
        }
    }
    
    private func startTimer() {
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            dismiss()
        }
    }
    
    private func resetTimer() {
        inactivityTimer?.invalidate()
        startTimer()
    }
}

struct PlayerSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var playerManager: PlayerManager
    @Binding var selectedPlayers: [BetComponents.Player]
    @State private var tempSelectedPlayers: Set<UUID> = []
    @State private var showAddPlayer = false
    @State private var newPlayerFirstName = ""
    @State private var newPlayerLastName = ""
    @State private var newPlayerEmail = ""
    
    var availablePlayers: [BetComponents.Player] {
        playerManager.allPlayers.filter { player in
            !selectedPlayers.contains { $0.id == player.id }
        }
    }
    
    var body: some View {
        VStack {
            // Custom header
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
                ScrollView {
                    LazyVStack(spacing: 0) {
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
                        }
                    }
                    .padding(.vertical)
                }
            }
            
            HStack {
                Button(action: {
                    showAddPlayer = true
                }) {
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
                
                Button(action: {
                    let newPlayers = availablePlayers.filter { tempSelectedPlayers.contains($0.id) }
                    selectedPlayers.append(contentsOf: newPlayers)
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
        .background(Color.gray.opacity(0.1))
        .onAppear {
            tempSelectedPlayers.removeAll()
        }
        .sheet(isPresented: $showAddPlayer) {
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
                        showAddPlayer = false
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
                        showAddPlayer = false
                    }
                    .disabled(newPlayerFirstName.isEmpty || newPlayerLastName.isEmpty)
                )
            }
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
    @Binding var currentPlayerIndex: Int
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
    @State private var showUnpostConfirmation = false
    @State private var showPostConfirmation = false
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
            betManager.updateGroupScores(playerScores, forGroup: groupIndex)
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
        if score == 1 || score < par - 1 { return .secondaryGold }
        if score == par - 1 { return .red }
        if score == par { return .primaryGreen }
        return .blue
    }
    
    func body(content: Content) -> some View {
        content.overlay(
            Group {
                if score < par - 1 {
                    // Double circle for eagle or better
                    ZStack {
                        Circle()
                            .stroke(colorForScore(score), lineWidth: 1.5)
                            .frame(width: 30, height: 30)
                        Circle()
                            .stroke(colorForScore(score), lineWidth: 1.5)
                            .frame(width: 36, height: 36)
                    }
                } else if score == par - 1 {
                    // Single circle for birdie
                    Circle()
                        .stroke(colorForScore(score), lineWidth: 1.5)
                        .frame(width: 30, height: 30)
                } else if score == par + 1 {
                    // Single square for bogey
                    Rectangle()
                        .stroke(colorForScore(score), lineWidth: 1.5)
                        .frame(width: 30, height: 30)
                } else if score == par + 2 {
                    // Double square for double bogey
                    ZStack {
                        Rectangle()
                            .stroke(colorForScore(score), lineWidth: 1.5)
                            .frame(width: 30, height: 30)
                        Rectangle()
                            .stroke(colorForScore(score), lineWidth: 1.5)
                            .frame(width: 36, height: 36)
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
        CodeScannerView(
            codeTypes: [.qr],
            scanMode: .once,
            showViewfinder: true,
            simulatedData: "SIMULATED",
            completion: handleScan
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let result):
            scannedCode = result.string
            dismiss()
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
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

