import SwiftUI
import BetComponents

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
    @State private var showTestScoresButton = true  // Set to false before release
    @EnvironmentObject private var userProfile: UserProfile
    @EnvironmentObject private var betManager: BetManager
    @GestureState private var dragOffset: CGFloat = 0
    @State private var selectedPlayers: [BetComponents.Player] = []
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            ScorecardHeaderView(
                course: course,
                showMenu: $showMenu,
                showPlayerSelection: $showPlayerSelection,
                showTestScoresButton: showTestScoresButton,
                populateTestScores: populateTestScores
            )
            
            ScorecardNavigationTabs(
                showLeaderboard: $showLeaderboard,
                showBetCreation: $showBetCreation,
                selectedGroupPlayers: players,
                currentPlayerIndex: selectedPlayerIndex
            )
            
            ScorecardContentView(
                players: players,
                selectedPlayerIndex: $selectedPlayerIndex,
                scores: $scores,
                teeBox: teeBox,
                dragOffset: _dragOffset,
                updateScore: updateScore
            )
            
            ScorecardTimerView(
                formattedTime: formattedTime,
                isTimerRunning: isTimerRunning,
                toggleTimer: toggleTimer
            )
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
                currentPlayerIndex: $selectedPlayerIndex
            )
        }
        .sheet(isPresented: $showBetCreation) {
            BetCreationView()
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
        selectedPlayerIndex = 0  // Reset to first player
    }
    
    private let teamColors: [Color] = [
        Color(red: 0.91, green: 0.3, blue: 0.24),   // Vibrant Red
        Color(red: 0.0, green: 0.48, blue: 0.8),    // Ocean Blue
        Color.teamGold,                              // Team Gold
        Color(red: 0.6, green: 0.2, blue: 0.8)      // Royal Purple
    ]
}

struct ScorecardHeaderView: View {
    let course: GolfCourse
    @Binding var showMenu: Bool
    @Binding var showPlayerSelection: Bool
    let showTestScoresButton: Bool
    let populateTestScores: () -> Void
    
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
                    
                    Text("Playing from: Black/Blue")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
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
            
            if showTestScoresButton {
                Button(action: populateTestScores) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Load Test Scores")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.8))
                    .clipShape(Capsule())
                }
                .padding(.vertical, 8)
                .background(Color.primaryGreen.opacity(0.9))
            }
        }
    }
}

struct ScorecardContentView: View {
    let players: [BetComponents.Player]
    @Binding var selectedPlayerIndex: Int
    @Binding var scores: [UUID: [String]]
    let teeBox: BetComponents.TeeBox
    let dragOffset: GestureState<CGFloat>
    let updateScore: (BetComponents.Player, Int, String) -> Void
    @EnvironmentObject private var betManager: BetManager
    
    var orderedPlayers: [BetComponents.Player] {
        // First, try to get players from Alabama bets
        if let alabamaBet = betManager.alabamaBets.first {
            var orderedPlayers: [BetComponents.Player] = []
            
            // Add players team by team
            for team in alabamaBet.teams {
                orderedPlayers.append(contentsOf: team)
            }
            
            // Add swing man if present
            if let swingMan = alabamaBet.swingMan {
                orderedPlayers.append(swingMan)
            }
            
            // Add any remaining players not in Alabama teams
            let remainingPlayers = players.filter { player in
                !orderedPlayers.contains { $0.id == player.id }
            }
            orderedPlayers.append(contentsOf: remainingPlayers)
            
            return orderedPlayers
        }
        
        // If no Alabama bets, return original order
        return players
    }
    
    var body: some View {
        if !players.isEmpty {
            ScrollView {
                VStack(spacing: 16) {
                    // Player carousel
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(orderedPlayers, id: \.id) { player in
                                PlayerButton(
                                    player: player,
                                    isSelected: orderedPlayers[selectedPlayerIndex].id == player.id,
                                    teamColor: getTeamColor(for: player)
                                )
                                .onTapGesture {
                                    if let index = orderedPlayers.firstIndex(where: { $0.id == player.id }) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedPlayerIndex = index
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(Color.primaryGreen.opacity(0.2))
                    .gesture(
                        DragGesture()
                            .updating(dragOffset) { value, state, _ in
                                state = value.translation.width
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                if value.translation.width > threshold && orderedPlayers.count > 1 {
                                    withAnimation(.easeInOut) {
                                        selectedPlayerIndex = (selectedPlayerIndex - 1 + orderedPlayers.count) % orderedPlayers.count
                                    }
                                } else if value.translation.width < -threshold && orderedPlayers.count > 1 {
                                    withAnimation(.easeInOut) {
                                        selectedPlayerIndex = (selectedPlayerIndex + 1) % orderedPlayers.count
                                    }
                                }
                            }
                    )
                    
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
                            scores: scores[orderedPlayers[selectedPlayerIndex].id] ?? Array(repeating: "", count: 18)
                        ) { index, score in
                            updateScore(orderedPlayers[selectedPlayerIndex], index, score)
                        }
                        
                        // Back 9
                        ScorecardGridView(
                            holes: Array(teeBox.holes.suffix(9)),
                            scores: scores[orderedPlayers[selectedPlayerIndex].id]?.suffix(9).map { String($0) } ?? Array(repeating: "", count: 9)
                        ) { index, score in
                            updateScore(orderedPlayers[selectedPlayerIndex], index + 9, score)
                        }
                        
                        // Totals
                        ScorecarTotalsView(
                            holes: teeBox.holes,
                            scores: scores[orderedPlayers[selectedPlayerIndex].id] ?? Array(repeating: "", count: 18)
                        )
                    }
                    .padding(.bottom)
                }
            }
            .onChange(of: selectedPlayerIndex) { oldValue, newValue in
                // Dismiss keyboard when switching players
                DispatchQueue.main.async {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        } else {
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
    }
    
    private func getTeamColor(for player: BetComponents.Player) -> Color? {
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
        return nil
    }
    
    private let teamColors: [Color] = [
        Color(red: 0.91, green: 0.3, blue: 0.24),   // Vibrant Red
        Color(red: 0.0, green: 0.48, blue: 0.8),    // Ocean Blue
        Color.teamGold,                              // Team Gold
        Color(red: 0.6, green: 0.2, blue: 0.8)      // Royal Purple
    ]
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
        "Nick": ["4","4","4","3","4","5","5","4","3","4","4","3","4","5","3","6","3","4"],
        "Ryan": ["4","4","4","3","4","4","4","3","3","4","4","3","4","5","3","4","3","4"]
    ]
}

struct CustomNumberPad: View {
    @Binding var text: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Number grid
            ForEach(0..<3) { row in
                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { number in
                        numberButton(String(row * 3 + number))
                    }
                }
            }
            HStack(spacing: 8) {
                numberButton("0")
                Button(action: {
                    text = "X"
                }) {
                    Text("X")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(8)
                }
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "delete.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            Button(action: onDismiss) {
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
    }
    
    private func numberButton(_ number: String) -> some View {
        Button(action: {
            text = number
        }) {
            Text(number)
                .font(.title2)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
        }
    }
}

struct ScoreDisplayView: View {
    let score: String
    let par: Int
    @Binding var scoreText: String
    @State private var showCustomKeypad = false
    
    var scoreInt: Int? {
        if score == "X" {
            return par + 4  // X is treated as par + 4
        }
        return Int(score)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                showCustomKeypad = true
            }) {
                if scoreText.isEmpty {
                    Text("")
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.95))
                } else if score == "X" {
                    Text("X")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.95))
                } else if let currentScore = Int(score) {
                    Text("\(currentScore)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(colorForScore(currentScore))
                        .frame(maxWidth: .infinity)
                        .modifier(ScoreDecorationModifier(score: currentScore, par: par))
                        .background(Color.white.opacity(0.95))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.white.opacity(0.95))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primaryGreen.opacity(0.6), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            .padding(.horizontal, 4)
            
            if score == "X" {
                HStack {
                    Spacer()
                    Text("🚫")
                        .font(.system(size: 16))
                    Spacer()
                }
                .frame(height: 20)
            } else if let currentScore = Int(score) {
                HStack {
                    Spacer()
                    if currentScore == 1 {
                        Text("⭐️")
                            .font(.system(size: 16))
                            .shadow(color: .yellow.opacity(0.8), radius: 2)
                    } else if currentScore == 2 {
                        Text("✌️")
                            .font(.system(size: 16))
                            .shadow(color: .green.opacity(0.8), radius: 2)
                    } else if currentScore > par + 2 {
                        Text("💩")
                            .font(.system(size: 16))
                    }
                    Spacer()
                }
                .frame(height: 20)
            }
        }
        .frame(width: 60)
        .sheet(isPresented: $showCustomKeypad) {
            CustomNumberPad(text: $scoreText) {
                showCustomKeypad = false
            }
            .presentationDetents([.height(300)])
        }
    }
    
    private func colorForScore(_ score: Int) -> Color {
        if score == 1 { return .yellow }
        if score < par - 1 { return .orange }
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
        if score == 1 || score < par - 1 { return .teamGold }
        if score == par - 1 { return .red }
        if score == par { return .primaryGreen }
        return .blue
    }
}

struct ScorecardGridView: View {
    let holes: [BetComponents.HoleInfo]
    let scores: [String]
    let onScoreUpdate: (Int, String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 1) {
                // Header row
                HStack(spacing: 0) {
                    Text("Hole")
                        .frame(width: 60)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    
                    ForEach(holes) { hole in
                        Text("\(hole.number)")
                            .frame(width: 60)
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
                HStack(spacing: 0) {
                    Text("Par")
                        .frame(width: 60)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    
                    ForEach(holes) { hole in
                        Text("\(hole.par)")
                            .frame(width: 60)
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
                HStack(spacing: 0) {
                    Text("Yards")
                        .frame(width: 60)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    
                    ForEach(holes) { hole in
                        Text("\(hole.yardage)")
                            .frame(width: 60)
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
                HStack(spacing: 0) {
                    Text("Score")
                        .frame(width: 60)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    
                    ForEach(Array(holes.enumerated()), id: \.element.id) { index, hole in
                        ScoreDisplayView(
                            score: scores[index],
                            par: hole.par,
                            scoreText: Binding(
                                get: { scores[index] },
                                set: { onScoreUpdate(index, $0) }
                            )
                        )
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
        VStack(spacing: 8) {
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
        .padding()
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

struct PlayerSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPlayers: [BetComponents.Player]
    @State private var tempSelectedPlayers: Set<UUID> = []
    @State private var availablePlayers: [BetComponents.Player] = []
    
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
                let newPlayers = availablePlayers.filter { tempSelectedPlayers.contains($0.id) }
                selectedPlayers.append(contentsOf: newPlayers)
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
        .background(Color.gray.opacity(0.1))
        .onAppear {
            availablePlayers = MockData.allPlayers.filter { player in
                !selectedPlayers.contains { $0.id == player.id }
            }
            tempSelectedPlayers.removeAll()
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
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var betManager: BetManager
    @State private var isPosted = false
    @State private var showMenu = false
    @State private var showPostConfirmation = false
    @State private var showUnpostConfirmation = false
    @State private var showPostAnimation = false
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
                        .font(.custom("Avenir-Black", size: 28))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                    
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
                    Text("Player")
                        .frame(width: 100, alignment: .leading)
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
                    Text("Skins")
                        .frame(width: 50)
                    Spacer()
                    Text("DO DAs")
                        .frame(width: 50)
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
                                skins: stats.skins,
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
                betManager.updateScoresAndTeeBox(playerScores, teeBox)
                
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
    let player: BetComponents.Player
    let index: Int
    let playerScores: [UUID: [String]]
    let teeBox: BetComponents.TeeBox
    let betManager: BetManager
    
    init(player: BetComponents.Player, index: Int, playerScores: [UUID: [String]], teeBox: BetComponents.TeeBox, betManager: BetManager) {
        self.player = player
        self.index = index
        self.playerScores = playerScores
        self.teeBox = teeBox
        self.betManager = betManager
    }
    
    var stats: (lastHole: Int, score: String, scoreColor: Color, doDas: Int, skins: Int) {
        let scores = playerScores[player.id] ?? []
        var lastHolePlayed = 0
        var totalScore = 0
        var doDaCount = 0
        var skinsCount = 0
        
        // Count skins from skins bets
        for skinsBet in betManager.skinsBets {
            if skinsBet.players.contains(where: { $0.id == player.id }) {
                // Only include players who have scores
                let activePlayers = skinsBet.players.filter { playerScores.keys.contains($0.id) }
                
                // For each hole
                for holeIndex in 0..<18 {
                    // Get valid scores for this hole
                    var holeScores: [(playerId: UUID, score: Int)] = []
                    for betPlayer in activePlayers {
                        let scoreStr = playerScores[betPlayer.id]?[holeIndex] ?? ""
                        if scoreStr == "X" {
                            holeScores.append((betPlayer.id, teeBox.holes[holeIndex].par + 4))
                        } else if let score = Int(scoreStr) {
                            holeScores.append((betPlayer.id, score))
                        }
                    }
                    
                    // Skip hole if not all players have scores
                    guard holeScores.count == activePlayers.count else { continue }
                    
                    // Find lowest score for the hole
                    let lowestScore = holeScores.min { $0.score < $1.score }?.score
                    guard let lowestScore = lowestScore else { continue }
                    
                    // Count how many players have the lowest score
                    let playersWithLowestScore = holeScores.filter { $0.score == lowestScore }
                    
                    // If only one player has the lowest score and it's our player, they won this skin
                    if playersWithLowestScore.count == 1 && playersWithLowestScore[0].playerId == player.id {
                        skinsCount += 1
                    }
                }
            }
        }

        for (index, scoreStr) in scores.enumerated() {
            if !scoreStr.isEmpty {
                lastHolePlayed = index + 1
                if scoreStr == "X" {
                    totalScore += 4  // X adds 4 to the relative to par score
                } else if let score = Int(scoreStr) {
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
        
        return (lastHolePlayed, scoreString, scoreColor, doDaCount, skinsCount)
    }
    
    var winnings: Double {
        betManager.calculateTotalWinnings(
            player: player,
            playerScores: playerScores,
            teeBox: teeBox
        )
    }
}

struct PlayerRowView: View {
    let player: BetComponents.Player
    let index: Int
    let lastHole: Int
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
        VStack(spacing: 0) {
            // Main player row
            Button(action: onExpandToggle) {
                HStack {
                    Text(player.firstName)
                        .frame(width: 100, alignment: .leading)
                    Spacer()
                    Text("\(lastHole)")
                        .frame(width: 50)
                    Spacer()
                    Text(score)
                        .foregroundColor(scoreColor)
                        .frame(width: 60)
                    Spacer()
                    Text(String(format: "$%.0f", winnings))
                        .foregroundColor(winnings >= 0 ? .primaryGreen : .red)
                        .frame(width: 70)
                    Spacer()
                    Text("\(skins)")
                        .frame(width: 50)
                    Spacer()
                    Text("\(doDas)")
                        .frame(width: 50)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(index % 2 == 0 ? Color.white : Color.primaryGreen.opacity(0.1))
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
        BetComponents.Player(id: UUID(), firstName: "Jody", lastName: "Moss", email: "jody@example.com"),
        BetComponents.Player(id: UUID(), firstName: "Bryan", lastName: "Crowder", email: "bryan@example.com"),
        BetComponents.Player(id: UUID(), firstName: "Wade", lastName: "House", email: "wade@example.com"),
        BetComponents.Player(id: UUID(), firstName: "Hardy", lastName: "Gordon", email: "hardy@example.com"),
        BetComponents.Player(id: UUID(), firstName: "Rolf", lastName: "Morestead", email: "rolf@example.com"),
        BetComponents.Player(id: UUID(), firstName: "Jim", lastName: "Tonore", email: "jim@example.com"),
        BetComponents.Player(id: UUID(), firstName: "Chad", lastName: "Hill", email: "chad@example.com"),
        BetComponents.Player(id: UUID(), firstName: "Nate", lastName: "Weant", email: "nate@example.com"),
        BetComponents.Player(id: UUID(), firstName: "Mark", lastName: "Sutton", email: "mark@example.com"),
        BetComponents.Player(id: UUID(), firstName: "Darren", lastName: "Sutton", email: "darren@example.com"),
        BetComponents.Player(id: UUID(), firstName: "Justin", lastName: "Tarver", email: "justin@example.com"),
        BetComponents.Player(id: UUID(), firstName: "Ron", lastName: "Shimwell", email: "ron@example.com"),
        BetComponents.Player(id: UUID(), firstName: "Clay", lastName: "Shimwell", email: "clay@example.com"),
        BetComponents.Player(id: UUID(), firstName: "Nick", lastName: "Ellison", email: "nick@example.com"),
        BetComponents.Player(id: UUID(), firstName: "Ryan", lastName: "Nelson", email: "ryan@example.com")
    ]
    
    static private(set) var availablePlayers = allPlayers
    
    static func removeSelectedPlayers(_ players: [BetComponents.Player]) {
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

struct PlayerButton: View {
    let player: BetComponents.Player
    let isSelected: Bool
    let teamColor: Color?
    
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

