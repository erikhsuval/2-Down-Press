import SwiftUI
import BetComponents

struct ScorecardView: View {
    let course: GolfCourse
    let teeBox: TeeBox
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
    @State private var showTestScoresButton = true  // Set to false before release
    @EnvironmentObject private var userProfile: UserProfile
    @EnvironmentObject private var betManager: BetManager
    
    private let maxTimerDuration: TimeInterval = 6 * 60 * 60 // 6 hours in seconds
    
    private var players: [Player] {
        var allPlayers = Set<Player>()
        
        // Add current user if available
        if let currentUser = userProfile.currentUser {
            allPlayers.insert(currentUser)
        }
        
        // Add players from bets
        for bet in betManager.individualBets {
            allPlayers.insert(bet.player1)
            allPlayers.insert(bet.player2)
        }
        
        for bet in betManager.fourBallBets {
            allPlayers.insert(bet.team1Player1)
            allPlayers.insert(bet.team1Player2)
            allPlayers.insert(bet.team2Player1)
            allPlayers.insert(bet.team2Player2)
        }
        
        for bet in betManager.alabamaBets {
            for team in bet.teams {
                allPlayers.formUnion(team)
            }
        }
        
        for bet in betManager.doDaBets {
            allPlayers.formUnion(bet.players)
        }
        
        for bet in betManager.skinsBets {
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Add the test scores button at the top
            if showTestScoresButton {
                Button(action: populateTestScores) {
                    Text("Load Test Scores")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.vertical, 8)
            }
            
            // Header
            HStack {
                Button(action: { showMenu = true }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(course.name)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showPlayerSelection = true }) {
                    Image(systemName: "person.badge.plus")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.primaryGreen)
            
            // Navigation tabs
            ScorecardNavigationTabs(
                showLeaderboard: $showLeaderboard,
                showBetCreation: $showBetCreation,
                selectedGroupPlayers: players,
                currentPlayerIndex: selectedPlayerIndex
            )
            
            if !players.isEmpty {
                // Player name and navigation
                HStack {
                    Button(action: { 
                        withAnimation {
                            selectedPlayerIndex = (selectedPlayerIndex - 1 + players.count) % players.count
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primaryGreen)
                    }
                    .disabled(players.count <= 1)
                    
                    Spacer()
                    
                    Text(players[selectedPlayerIndex].firstName)
                        .font(.title2.bold())
                    
                    Spacer()
                    
                    Button(action: { 
                        withAnimation {
                            selectedPlayerIndex = (selectedPlayerIndex + 1) % players.count
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primaryGreen)
                    }
                    .disabled(players.count <= 1)
                }
                .padding()
                
                // Scorecard content
                ScrollView {
                    VStack(spacing: 16) {
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
                        
                        // Front 9
                        ScorecardGridView(
                            holes: Array(teeBox.holes.prefix(9)),
                            scores: scores[players[selectedPlayerIndex].id] ?? Array(repeating: "", count: 18)
                        ) { index, score in
                            updateScore(for: players[selectedPlayerIndex], at: index, with: score)
                        }
                        
                        // Back 9
                        ScorecardGridView(
                            holes: Array(teeBox.holes.suffix(9)),
                            scores: scores[players[selectedPlayerIndex].id]?.suffix(9).map { String($0) } ?? Array(repeating: "", count: 9)
                        ) { index, score in
                            updateScore(for: players[selectedPlayerIndex], at: index + 9, with: score)
                        }
                        
                        // Totals
                        ScorecarTotalsView(
                            holes: teeBox.holes,
                            scores: scores[players[selectedPlayerIndex].id] ?? Array(repeating: "", count: 18)
                        )
                    }
                    .padding(.vertical)
                }
            } else {
                // No players view
                VStack {
                    Text("No Players Added")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Tap the + button to add players")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Footer with timer and action buttons
            VStack(spacing: 8) {
                HStack {
                    Button(action: { showLeaderboard = true }) {
                        Image(systemName: "flag.filled")
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text(formattedTime)
                        .font(.title3)
                        .monospacedDigit()
                    
                    Spacer()
                    
                    Button(action: { showBetCreation = true }) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.title2)
                    }
                }
                
                if hasStartedRound {
                    Button(action: toggleTimer) {
                        Text(isTimerRunning ? "Stop Round" : "Start Round")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isTimerRunning ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
                            )
                    }
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.primaryGreen)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showMenu) {
            MenuView()
                .environmentObject(betManager)
                .environmentObject(userProfile)
        }
        .sheet(isPresented: $showBetCreation) {
            BetCreationView(selectedPlayers: players)
                .environmentObject(betManager)
                .environmentObject(userProfile)
        }
        .sheet(isPresented: $showPlayerSelection) {
            PlayerSelectionView(selectedPlayers: .constant([]))
                .environmentObject(userProfile)
                .onDisappear {
                    // Initialize scores for any newly added players
                    for player in players {
                        initializeScores(for: player.id)
                    }
                }
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView(
                course: course,
                teeBox: teeBox,
                players: players,
                playerScores: scores,
                currentPlayerIndex: $selectedPlayerIndex
            )
            .environmentObject(betManager)
            .environmentObject(userProfile)
        }
        .onAppear {
            if let currentUser = userProfile.currentUser {
                initializeScores(for: currentUser.id)
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func initializeScores(for playerId: UUID) {
        if scores[playerId] == nil {
            scores[playerId] = Array(repeating: "", count: 18)
        }
    }
    
    private func updateScore(for player: Player, at index: Int, with score: String) {
        var playerScores = scores[player.id] ?? Array(repeating: "", count: 18)
        playerScores[index] = score
        scores[player.id] = playerScores
        
        // Start timer when first score is entered
        if !hasStartedRound && !score.isEmpty {
            hasStartedRound = true
            isTimerRunning = true
            startTimer()
        }
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
    
    private func populateTestScores() {
        for player in players {
            if let testScores = TestScoreData.scores[player.firstName] {
                scores[player.id] = testScores
            }
        }
    }
}

// Test score data for development
struct TestScoreData {
    static let scores: [String: [String]] = [
        "Erik": ["4","4","4","3","4","4","4","4","3","3","4","3","4","5","3","4","3","4"],
        "Jody": ["4","4","5","3","4","5","4","4","3","4","4","4","4","5","3","5","3","4"],
        "Bryan": ["4","4","5","3","4","4","4","4","4","4","4","4","4","5","3","4","3","5"],
        "Wade": ["4","4","5","3","4","5","4","3","2","4","4","4","4","5","3","5","2","3"],
        "Hardy": ["4","4","5","3","4","5","4","4","3","4","4","4","4","4","3","5","3","4"],
        "Rolf": ["5","5","5","3","4","5","3","4","3","5","5","4","4","5","3","4","3","4"],
        "Jim": ["4","4","5","3","4","4","5","4","4","4","4","4","4","5","2","6","3","5"],
        "Chad": ["5","4","5","4","3","5","4","4","3","5","4","4","5","4","3","5","3","4"],
        "Nate": ["3","5","4","3","5","5","4","4","4","3","5","3","4","6","3","5","3","5"],
        "Mark": ["4","4","5","3","4","5","4","4","3","4","4","4","4","5","3","5","3","4"],
        "Darren": ["5","5","6","2","4","4","4","4","3","5","5","5","3","5","2","5","3","4"],
        "Justin": ["4","6","5","3","5","6","4","6","3","4","6","4","4","6","4","5","5","4"],
        "Ron": ["4","4","4","3","4","5","5","4","3","4","4","3","4","5","3","6","3","4"],
        "Clay": ["5","4","5","4","4","5","4","5","5","5","4","4","5","5","3","5","4","4"],
        "Nick": ["4","4","4","3","4","5","5","4","3","4","4","3","4","5","3","6","3","4"]
    ]
}

struct ScoreDisplayView: View {
    let score: String
    let par: Int
    @Binding var scoreText: String
    
    var scoreInt: Int? {
        Int(score)
    }
    
    var body: some View {
        ZStack {
            // Score input and display
            ZStack {
                TextField("", text: $scoreText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                if let currentScore = scoreInt {
                    Text("\(currentScore)")
                        .foregroundColor(colorForScore(currentScore))
                        .frame(maxWidth: .infinity)
                        .modifier(ScoreDecorationModifier(score: currentScore, par: par))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            // Overlay decorations to the right
            if let currentScore = scoreInt {
                HStack {
                    Spacer()
                    if currentScore == 1 {
                        Text("⭐️")
                            .font(.caption)
                    } else if currentScore == 2 {
                        Text("DO DA")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else if currentScore > par + 2 {
                        Text("💩")
                            .font(.caption)
                    }
                }
                .padding(.trailing, 4)
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func colorForScore(_ score: Int) -> Color {
        if score == 1 || score < par - 1 { return .secondaryGold }
        if score == par - 1 { return .red }
        if score == par { return .primaryGreen }
        return .blue
    }
}

struct ScoreDecorationModifier: ViewModifier {
    let score: Int
    let par: Int
    
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
    
    private func colorForScore(_ score: Int) -> Color {
        if score == 1 || score < par - 1 { return .secondaryGold }
        if score == par - 1 { return .red }
        if score == par { return .primaryGreen }
        return .blue
    }
}

struct ScorecardGridView: View {
    let holes: [HoleInfo]
    let scores: [String]
    let onScoreUpdate: (Int, String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack(spacing: 0) {
                Text("Hole")
                    .frame(width: 60)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                ForEach(holes) { hole in
                    Text("\(hole.number)")
                        .frame(width: 40)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 4)
            .background(Color.backgroundGray)
            
            // Par row
            HStack(spacing: 0) {
                Text("Par")
                    .frame(width: 60)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                ForEach(holes) { hole in
                    Text("\(hole.par)")
                        .frame(width: 40)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 4)
            
            // Yardage row
            HStack(spacing: 0) {
                Text("Yards")
                    .frame(width: 60)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                ForEach(holes) { hole in
                    Text("\(hole.yardage)")
                        .frame(width: 40)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 4)
            .background(Color.backgroundGray)
            
            // Score row
            HStack(spacing: 0) {
                Text("Score")
                    .frame(width: 60)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                ForEach(Array(holes.enumerated()), id: \.element.id) { index, hole in
                    ScoreDisplayView(
                        score: scores[index],
                        par: hole.par,
                        scoreText: Binding(
                            get: { scores[index] },
                            set: { onScoreUpdate(index, $0) }
                        )
                    )
                    .frame(width: 40)
                }
            }
            .padding(.vertical, 4)
        }
        .padding(.horizontal)
    }
}

struct ScorecarTotalsView: View {
    let holes: [HoleInfo]
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
        VStack(spacing: 8) {
            HStack {
                Text("Front 9:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(frontNineScore)")
                    .font(.headline)
            }
            
            HStack {
                Text("Back 9:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(backNineScore)")
                    .font(.headline)
            }
            
            Divider()
            
            HStack {
                Text("Total:")
                    .font(.headline)
                Spacer()
                Text("\(totalScore)")
                    .font(.title3.bold())
            }
        }
        .padding()
        .background(Color.backgroundGray)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct ScorecardNavigationTabs: View {
    @Binding var showLeaderboard: Bool
    @Binding var showBetCreation: Bool
    let selectedGroupPlayers: [Player]
    let currentPlayerIndex: Int
    
    var body: some View {
        HStack {
            Button {
                withAnimation {
                    showLeaderboard.toggle()
                }
            } label: {
                Text("Round")
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                    )
            }
            
            Spacer()
            
            if !selectedGroupPlayers.isEmpty {
                Text(selectedGroupPlayers[currentPlayerIndex % selectedGroupPlayers.count].firstName)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button {
                withAnimation {
                    showBetCreation.toggle()
                }
            } label: {
                Text("Games")
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                    )
            }
        }
        .padding()
        .background(Color.primaryGreen)
    }
}

struct PlayerSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPlayers: [Player]
    @State private var tempSelectedPlayers: Set<UUID> = []
    @State private var availablePlayers: [Player] = []
    
    var body: some View {
        NavigationView {
            VStack {
                if availablePlayers.isEmpty {
                    VStack {
                        Text("No Available Players")
                            .font(.headline)
                        Text("All players have been added to groups")
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
                
                Button(action: {
                    selectedPlayers = availablePlayers.filter { tempSelectedPlayers.contains($0.id) }
                    dismiss()
                }) {
                    Text("Done")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.primaryGreen)
                        .cornerRadius(25)
                }
                .padding()
            }
            .navigationTitle("Select Players")
        }
        .onAppear {
            availablePlayers = MockData.availablePlayers
            tempSelectedPlayers.removeAll()
        }
    }
}

struct PlayerSelectionRow: View {
    let player: Player
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(player.firstName + " " + player.lastName)
                    .font(.headline)
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.primaryGreen : Color.gray.opacity(0.3), lineWidth: 2)
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
    let teeBox: TeeBox
    let players: [Player]
    let playerScores: [UUID: [String]]
    @Binding var currentPlayerIndex: Int
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var betManager: BetManager
    @State private var isPosted = false
    @State private var showPostConfirmation = false
    @State private var showUnpostConfirmation = false
    @State private var showPostAnimation = false
    @State private var showMenu = false
    @State private var expandedPlayers: Set<UUID> = []
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header with Menu Button
                HStack {
                    Button(action: { showMenu = true }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Leaderboard")
                        .font(.title2.bold())
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
                
                // Column Headers
                HStack {
                    Text("Name")
                        .frame(width: 120, alignment: .leading)
                    Spacer()
                    Text("Thru")
                        .frame(width: 50)
                    Spacer()
                    Text("Score")
                        .frame(width: 60)
                    Spacer()
                    Text("Win/Loss")
                        .frame(width: 70)
                    Spacer()
                    Text("DO DAs")
                        .frame(width: 60)
                }
                .font(.subheadline.bold())
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.1))
                
                // Player Rows
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                            let viewModel = PlayerStatsViewModel(
                                player: player,
                                index: index,
                                playerScores: playerScores,
                                teeBox: teeBox,
                                betManager: betManager
                            )
                            let stats = viewModel.stats
                            let isExpanded = expandedPlayers.contains(player.id)
                            
                            PlayerRowView(
                                player: player,
                                index: index,
                                lastHole: stats.lastHole,
                                score: stats.score,
                                scoreColor: stats.scoreColor,
                                winnings: viewModel.winnings,
                                doDas: stats.doDas,
                                isExpanded: isExpanded,
                                betManager: betManager,
                                playerScores: playerScores,
                                teeBox: teeBox,
                                onExpandToggle: {
                                    if isExpanded {
                                        expandedPlayers.remove(player.id)
                                    } else {
                                        expandedPlayers.insert(player.id)
                                    }
                                }
                            )
                        }
                    }
                }
                
                // Stats row
                HStack {
                    Text("FWY -")
                    Text("Putts 12")
                    Text("Penalty -")
                    Text("GIR 100%")
                }
                .font(.footnote)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.primaryGreen)
                .foregroundColor(.white)
                
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
            
            // Side Menu
            if showMenu {
                SideMenuView(isShowing: $showMenu, showPlayerList: .constant(false), showFourBallMatchSetup: .constant(false))
            }
        }
        .overlay {
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
        .alert("Post Round", isPresented: $showPostConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Post") {
                // Update scores and teeBox in BetManager
                betManager.updateScoresAndTeeBox(scores: playerScores, teeBox: teeBox)
                
                withAnimation {
                    showPostAnimation = true
                    isPosted = true
                }
                // Dismiss the animation after 1.5 seconds and return to scorecard
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showPostAnimation = false
                        dismiss() // Return to scorecard view
                    }
                }
            }
        } message: {
            Text("This will finalize the scorecard and update The Sheet. Continue?")
        }
        .alert("Unpost Round", isPresented: $showUnpostConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Unpost", role: .destructive) {
                isPosted = false
            }
        } message: {
            Text("This will allow you to make edits to the scorecard. Any changes will update The Sheet when posted again.")
        }
    }
}

class PlayerStatsViewModel {
    let player: Player
    let index: Int
    let playerScores: [UUID: [String]]
    let teeBox: TeeBox
    let betManager: BetManager
    
    init(player: Player, index: Int, playerScores: [UUID: [String]], teeBox: TeeBox, betManager: BetManager) {
        self.player = player
        self.index = index
        self.playerScores = playerScores
        self.teeBox = teeBox
        self.betManager = betManager
    }
    
    var stats: (lastHole: Int, score: String, scoreColor: Color, doDas: Int) {
        let scores = playerScores[player.id] ?? []
        var lastHolePlayed = 0
        var totalScore = 0
        var doDaCount = 0
        
        for (index, scoreStr) in scores.enumerated() {
            if !scoreStr.isEmpty {
                lastHolePlayed = index + 1
                if let score = Int(scoreStr) {
                    totalScore += score - teeBox.holes[index].par
                    if score == 2 {
                        doDaCount += 1
                    }
                }
            }
        }
        
        let scoreString = totalScore == 0 ? "E" : (totalScore > 0 ? "+\(totalScore)" : "\(totalScore)")
        let scoreColor: Color = {
            if totalScore == 0 { return .primaryGreen }
            if totalScore > 0 { return .blue }
            return .red
        }()
        
        return (lastHolePlayed, scoreString, scoreColor, doDaCount)
    }
    
    var winnings: Double {
        betManager.calculateRoundWinnings(
            player: player,
            playerScores: playerScores,
            teeBox: teeBox
        )
    }
}

struct PlayerRowView: View {
    let player: Player
    let index: Int
    let lastHole: Int
    let score: String
    let scoreColor: Color
    let winnings: Double
    let doDas: Int
    let isExpanded: Bool
    let betManager: BetManager
    let playerScores: [UUID: [String]]
    let teeBox: TeeBox
    let onExpandToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Main player row
            Button(action: onExpandToggle) {
                HStack {
                    Text(player.firstName + " " + player.lastName)
                        .frame(width: 120, alignment: .leading)
                    Spacer()
                    Text("\(lastHole)")
                        .frame(width: 50)
                    Spacer()
                    Text(score)
                        .foregroundColor(scoreColor)
                        .frame(width: 60)
                    Spacer()
                    Text(String(format: "$%.0f", winnings))
                        .foregroundColor(winnings >= 0 ? .green : .red)
                        .frame(width: 70)
                    Spacer()
                    Text("\(doDas)")
                        .frame(width: 60)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(index % 2 == 0 ? Color.white : Color.green.opacity(0.1))
            }
            .foregroundColor(.primary)
            
            if isExpanded {
                PlayerBetDetailsView(
                    player: player,
                    betManager: betManager,
                    playerScores: playerScores,
                    teeBox: teeBox
                )
            }
            
            Divider()
        }
    }
}

// Add before PlayerSelectionView
enum MockData {
    static let allPlayers = [
        Player(id: UUID(), firstName: "Jody", lastName: "Moss", email: "jody@example.com"),
        Player(id: UUID(), firstName: "Bryan", lastName: "Crowder", email: "bryan@example.com"),
        Player(id: UUID(), firstName: "Wade", lastName: "House", email: "wade@example.com"),
        Player(id: UUID(), firstName: "Hardy", lastName: "Gordon", email: "hardy@example.com"),
        Player(id: UUID(), firstName: "Rolf", lastName: "Morestead", email: "rolf@example.com"),
        Player(id: UUID(), firstName: "Jim", lastName: "Tonore", email: "jim@example.com"),
        Player(id: UUID(), firstName: "Chad", lastName: "Hill", email: "chad@example.com"),
        Player(id: UUID(), firstName: "Nate", lastName: "Weant", email: "nate@example.com"),
        Player(id: UUID(), firstName: "Mark", lastName: "Sutton", email: "mark@example.com"),
        Player(id: UUID(), firstName: "Darren", lastName: "Sutton", email: "darren@example.com"),
        Player(id: UUID(), firstName: "Justin", lastName: "Tarver", email: "justin@example.com"),
        Player(id: UUID(), firstName: "Ron", lastName: "Shimwell", email: "ron@example.com"),
        Player(id: UUID(), firstName: "Clay", lastName: "Shimwell", email: "clay@example.com"),
        Player(id: UUID(), firstName: "Nick", lastName: "Ellison", email: "nick@example.com"),
        Player(id: UUID(), firstName: "Ryan", lastName: "Nelson", email: "ryan@example.com")
    ]
    
    static private(set) var availablePlayers = allPlayers
    
    static func removeSelectedPlayers(_ players: [Player]) {
        availablePlayers.removeAll(where: { player in
            players.contains(where: { $0.id == player.id })
        })
    }
}

struct SideMenuView: View {
    @Binding var isShowing: Bool
    @Binding var showPlayerList: Bool
    @Binding var showFourBallMatchSetup: Bool
    @State private var showMyAccount = false
    @State private var showMyBets = false
    @State private var showTheSheet = false
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing = false
                }
            
            HStack {
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
                        icon: "person.2",
                        text: "Players",
                        action: {
                            showPlayerList = true
                            isShowing = false
                        }
                    )
                    
                    Spacer()
                }
                .padding(.top, 100)
                .padding(.horizontal, 20)
                .frame(width: 280)
                .background(Color.primaryGreen)
                .offset(x: isShowing ? 0 : -280)
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
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Close") {
                                showMyBets = false
                                isShowing = false
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showTheSheet) {
            NavigationView {
                TheSheetView()
                    .environmentObject(betManager)
                    .environmentObject(userProfile)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Close") {
                                showTheSheet = false
                                isShowing = false
                            }
                        }
                    }
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
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
        }
    }
} 