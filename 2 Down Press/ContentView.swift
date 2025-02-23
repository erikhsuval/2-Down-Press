//
//  ContentView.swift
//  2 Down Press
//
//  Created by Erik Hsu on 1/11/25.
//

import SwiftUI
import CoreLocation

// Then LocationManager
class LocationManager: NSObject, ObservableObject {
    private let golfService: any GolfCourseServiceProtocol
    
    @Published var courses: [GolfCourse] = []
    @Published var isLoading = false
    
    init(golfService: some GolfCourseServiceProtocol = GolfCourseService()) {
        self.golfService = golfService
        super.init()
        // Load Bayou DeSiard immediately
        courses = [golfService.getGolfCourse()]
    }
    
    func startUpdatingLocation() {
        // No-op since we're not using location services
    }
}

class UserProfile: ObservableObject {
    @Published var currentUser: Player?
    private let userDefaults = UserDefaults.standard
        
    init() {
        loadUser()
    }
    
    func saveUser(_ player: Player) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(player) {
            userDefaults.set(encoded, forKey: "currentUser")
            currentUser = player
        }
    }
    
    private func loadUser() {
        if let userData = userDefaults.data(forKey: "currentUser"),
           let player = try? JSONDecoder().decode(Player.self, from: userData) {
            currentUser = player
        }
    }
}

struct Hole: Identifiable {
    let id: UUID
    let number: Int
    let yardage: Int
    let par: Int
    let handicap: Int
}

struct PlayerDetailsView: View {
    @EnvironmentObject private var userProfile: UserProfile
    @EnvironmentObject private var betManager: BetManager
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var navigateToGolfCourse = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Edit Player")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryGreen)
                
                VStack(spacing: 20) {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .textInputAutocapitalization(.words)
                    
                    HStack {
                        TextField("Scorecard Name", text: .constant(scorecardName))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(true)
                        
                        Text("*3 Letters")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .padding(.horizontal)
                    
                    TextField("Email (Optional)", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding(.horizontal)
                }
                .padding(.top, 30)
                
                Spacer()
                
                Button(action: {
                    let player = Player(id: UUID(),
                                      firstName: firstName,
                                      lastName: lastName,
                                      email: email)
                    userProfile.saveUser(player)
                    navigateToGolfCourse = true
                }) {
                    Text("Done")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.primaryGreen)
                        .cornerRadius(25)
                }
                .padding(.bottom, 30)
                .disabled(firstName.isEmpty || lastName.isEmpty)
            }
            .navigationDestination(isPresented: $navigateToGolfCourse) {
                GolfCourseSelectionView(locationManager: LocationManager(golfService: GolfCourseService()))
                    .environmentObject(betManager)
            }
        }
    }
    
    var scorecardName: String {
        if firstName.isEmpty { return "" }
        return String(firstName.prefix(4).uppercased())
    }
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager(golfService: GolfCourseService())
    @StateObject private var userProfile = UserProfile()
    @StateObject private var betManager = BetManager()
    @State private var showMenu = false
    @State private var showPlayerList = false
    @State private var showMyAccount = false
    @State private var showMyBets = false
    @State private var showTheSheet = false
    @State private var showFourBallMatchSetup = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Image
                Image("golf-background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        Color.black.opacity(0.3)
                    )
                
                VStack(spacing: 30) {
                    // Logo and Title
                    VStack(spacing: 15) {
                        Text("2 Down Press")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Golf Group Bets Made Easy")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Main Navigation Buttons
                    VStack(spacing: 20) {
                        NavigationLink {
                            PlayerDetailsView()
                                .environmentObject(userProfile)
                                .environmentObject(betManager)
                        } label: {
                            ButtonView(title: "Play", systemImage: "figure.golf")
                        }
                        
                        Button(action: { showMenu.toggle() }) {
                            ButtonView(title: "Menu", systemImage: "line.3.horizontal")
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .sheet(isPresented: $showMenu) {
            MenuView()
                .environmentObject(betManager)
                .environmentObject(userProfile)
        }
        .environmentObject(userProfile)
        .environmentObject(betManager)
    }
}

struct ButtonView: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title2)
            Text(title)
                .font(.title2.bold())
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.8))
        )
        .padding(.horizontal, 30)
    }
}

struct GolfCourseSelectionView: View {
    @ObservedObject private var locationManager: LocationManager
    @EnvironmentObject private var userProfile: UserProfile
    @EnvironmentObject private var betManager: BetManager
    
    init(locationManager: LocationManager) {
        self._locationManager = ObservedObject(wrappedValue: locationManager)
    }
    
    var body: some View {
        VStack {
            if locationManager.isLoading {
                ProgressView("Loading courses...")
            } else {
                List {
                    ForEach(locationManager.courses) { course in
                        NavigationLink(destination: TeeTimeSelectionView(course: course, locationManager: locationManager)
                            .environmentObject(userProfile)
                            .environmentObject(betManager)) {
                            CourseRow(course: course)
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Course")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search courses...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct CourseRow: View {
    let course: GolfCourse
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(course.name)
                .font(.headline)
        }
        .padding(.vertical, 8)
    }
}

struct CoursePlaceholderRow: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Loading course...")
                .font(.headline)
            Text("Calculating distance...")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

// Single preview for ContentView
#Preview {
        ContentView()
}

struct TeeTimeSelectionView: View {
    let course: GolfCourse
    @ObservedObject private var locationManager: LocationManager
    @EnvironmentObject private var userProfile: UserProfile
    @EnvironmentObject private var betManager: BetManager
    @State private var selectedTeeBox: TeeBox?
    
    init(course: GolfCourse, locationManager: LocationManager) {
        self.course = course
        self._locationManager = ObservedObject(wrappedValue: locationManager)
    }
    
    var body: some View {
        VStack {
            if locationManager.isLoading {
                ProgressView("Loading tee boxes...")
            } else {
                List {
                ForEach(course.teeBoxes) { teeBox in
                        NavigationLink(destination: ScorecardView(course: course, teeBox: teeBox)
                            .environmentObject(userProfile)
                            .environmentObject(betManager)) {
                            TeeBoxRow(teeBox: teeBox)
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Tee Box")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TeeBoxRow: View {
    let teeBox: TeeBox
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(teeBox.name)
                .font(.headline)
            Text("Rating: \(teeBox.rating) / Slope: \(teeBox.slope)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

struct LoadingView: View {
    let completion: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // You can replace this with a custom golf swing animation
                Image(systemName: "figure.golf")
                    .font(.system(size: 100))
                    .foregroundColor(.primaryGreen)
                
                Text("Enjoy your round!")
                    .font(.title.bold())
                    .foregroundColor(.primaryGreen)
            }
        }
        .onAppear {
            // Dismiss after 2 seconds and trigger navigation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
                completion()
            }
        }
    }
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

struct PlayerListView: View {
    var body: some View {
        NavigationView {
            List {
                // Placeholder for player list
                Text("Player List Coming Soon")
            }
            .navigationTitle("Players")
        }
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
        NavigationView {
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
            .fullScreenCover(isPresented: $showMyAccount) {
                NavigationView {
                    MyAccountView()
                }
            }
            .fullScreenCover(isPresented: $showMyBets) {
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
            .fullScreenCover(isPresented: $showTheSheet) {
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

struct ScorecardView: View {
    let course: GolfCourse
    let teeBox: TeeBox
    @EnvironmentObject private var userProfile: UserProfile
    @StateObject private var betManager = BetManager()
    @State private var showMenu = false
    @State private var showPlayerList = false
    @State private var showFourBallMatchSetup = false
    @State private var showAlabamaSetup = false
    @State private var selectedGroupPlayers: [Player] = []
    @State private var currentPlayerIndex = 0
    @State private var playerScores: [UUID: [String]] = [:]
    @State private var tempSelectedPlayers: [Player] = []
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isTimerRunning = false
    @State private var hasStartedRound = false
    @State private var showLeaderboard = false
    @State private var showBetCreation = false
    @State private var showTestScoresButton = true  // Set to false before removing test code
    
    private let maxTimerDuration: TimeInterval = 6 * 60 * 60 // 6 hours in seconds
    
    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var body: some View {
        ZStack {
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
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        tempSelectedPlayers = []
                        showPlayerList = true
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Add Player")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.2))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 1)
                        )
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "xmark")
                            .font(.title2)
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.primaryGreen)
                
                navigationTabs
                
                // Scorecard content
                if selectedGroupPlayers.isEmpty {
                    if let currentUser = userProfile.currentUser {
                        ScorecardGridView(
                            player: currentUser,
                            teeBox: teeBox,
                            scores: binding(for: currentUser.id)
                        )
                    }
                } else {
                    TabView(selection: $currentPlayerIndex) {
                        ForEach(0..<(selectedGroupPlayers.count * 3), id: \.self) { index in
                            let player = selectedGroupPlayers[index % selectedGroupPlayers.count]
                            ScorecardGridView(
                                player: player,
                                teeBox: teeBox,
                                scores: binding(for: player.id)
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                
                // Footer with timer
                VStack(spacing: 8) {
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "info.circle")
                                .font(.title2)
                        }
                        
                        Spacer()
                        
                        Text(formattedTime)
                            .font(.title3)
                            .monospacedDigit()
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "location.circle")
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
            .onAppear {
                if let currentUser = userProfile.currentUser {
                    selectedGroupPlayers = [currentUser]
                    initializeScores(for: currentUser.id)
                    currentPlayerIndex = 1 // Start in middle section
                }
            }
            .onDisappear {
                stopTimer()
            }
            
            // Side Menu
            if showMenu {
                SideMenuView(isShowing: $showMenu, showPlayerList: $showPlayerList, showFourBallMatchSetup: $showFourBallMatchSetup)
                    .environmentObject(userProfile)
                    .environmentObject(betManager)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPlayerList) {
            PlayerSelectionView(selectedPlayers: $tempSelectedPlayers)
                .environmentObject(userProfile)
                .onDisappear {
                    if !tempSelectedPlayers.isEmpty {
                        selectedGroupPlayers.append(contentsOf: tempSelectedPlayers)
                        for player in tempSelectedPlayers {
                            initializeScores(for: player.id)
                        }
                        currentPlayerIndex = selectedGroupPlayers.count * 2 - 1
                        MockData.removeSelectedPlayers(tempSelectedPlayers)
                    }
                }
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView(
                course: course,
                teeBox: teeBox,
                players: selectedGroupPlayers,
                playerScores: playerScores,
                currentPlayerIndex: $currentPlayerIndex
            )
            .environmentObject(betManager)
            .environmentObject(userProfile)
        }
        .sheet(isPresented: $showBetCreation) {
            BetCreationView(selectedPlayers: selectedGroupPlayers)
                .environmentObject(userProfile)
                .environmentObject(betManager)
        }
        .sheet(isPresented: $showFourBallMatchSetup) {
            FourBallMatchSetupView()
                .environmentObject(userProfile)
                .environmentObject(betManager)
        }
        .sheet(isPresented: $showAlabamaSetup) {
            AlabamaSetupView()
                .environmentObject(userProfile)
                .environmentObject(betManager)
        }
        .environmentObject(betManager)
    }
    
    private func initializeScores(for playerId: UUID) {
        if playerScores[playerId] == nil {
            playerScores[playerId] = Array(repeating: "", count: 18)
        }
    }
    
    private func binding(for playerId: UUID) -> Binding<[String]> {
        return Binding(
            get: { self.playerScores[playerId] ?? Array(repeating: "", count: 18) },
            set: { newScores in
                self.playerScores[playerId] = newScores
                // Start timer when first score is entered
                if !hasStartedRound && newScores.contains(where: { !$0.isEmpty }) {
                    hasStartedRound = true
                    isTimerRunning = true
                    startTimer()
                }
            }
        )
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
                resetTimer()
            } else {
                elapsedTime += 1
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        elapsedTime = 0
        isTimerRunning = false
    }
    
    @ViewBuilder
    private var navigationTabs: some View {
        ScorecardNavigationTabs(
            showLeaderboard: $showLeaderboard,
            showBetCreation: $showBetCreation,
            selectedGroupPlayers: selectedGroupPlayers,
            currentPlayerIndex: currentPlayerIndex
        )
    }
    
    private func populateTestScores() {
        for player in selectedGroupPlayers {
            if let testScores = TestScoreData.scores[player.firstName] {
                playerScores[player.id] = testScores
            }
        }
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
        .foregroundColor(.white)
        .background(Color.primaryGreen)
    }
}

struct ScorecardGridView: View {
    let player: Player
    let teeBox: TeeBox
    @Binding var scores: [String]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Column Headers
                HStack(spacing: 0) {
                    Text("Hole")
                        .frame(width: 60)
                        .fontWeight(.bold)
                    Divider()
                    Text(teeBox.name)
                        .frame(width: 80)
                        .fontWeight(.bold)
                    Divider()
                    Text("Hcp")
                        .frame(width: 60)
                        .fontWeight(.bold)
                    Divider()
                    Text("Par")
                        .frame(width: 60)
                        .fontWeight(.bold)
                    Divider()
                    Text("Score")
                        .frame(width: 100)
                        .fontWeight(.bold)
                }
                .font(.system(size: 16))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white)
                Divider()
                    
                // Holes 1-9
                ForEach(teeBox.holes.indices.prefix(9), id: \.self) { index in
                    let hole = teeBox.holes[index]
                    HoleRow(
                        hole: hole,
                        score: scores[index],
                        scoreText: $scores[index],
                        isEvenRow: index % 2 == 0
                    )
                    Divider()
                }
                    
                // IN Total (First 9 holes)
                let firstNine = teeBox.holes.prefix(9)
                TotalRow(
                    label: "OUT",
                    yardage: firstNine.reduce(0) { $0 + $1.yardage },
                    par: firstNine.reduce(0) { $0 + $1.par },
                    total: scores.prefix(9).compactMap { Int($0) }.reduce(0, +),
                    isHighlighted: true
                )
                Divider()
                
                // Holes 10-18
                ForEach(teeBox.holes.indices.dropFirst(9), id: \.self) { index in
                    let hole = teeBox.holes[index]
                    HoleRow(
                        hole: hole,
                        score: scores[index],
                        scoreText: $scores[index],
                        isEvenRow: index % 2 == 0
                    )
                    Divider()
                }
                
                // OUT Total (Last 9 holes)
                let lastNine = teeBox.holes.suffix(9)
                TotalRow(
                    label: "IN",
                    yardage: lastNine.reduce(0) { $0 + $1.yardage },
                    par: lastNine.reduce(0) { $0 + $1.par },
                    total: scores.suffix(9).compactMap { Int($0) }.reduce(0, +),
                    isHighlighted: true
                )
                Divider()
                
                // TOTAL Row
                TotalRow(
                    label: "TOTAL",
                    yardage: teeBox.holes.reduce(0) { $0 + $1.yardage },
                    par: teeBox.holes.reduce(0) { $0 + $1.par },
                    total: scores.compactMap { Int($0) }.reduce(0, +),
                    isHighlighted: true
                )
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
            .padding(.horizontal)
        }
    }
}

struct HoleRow: View {
    let hole: HoleInfo
    let score: String
    @Binding var scoreText: String
    let isEvenRow: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Text("\(hole.number)")
                .frame(width: 60)
            Divider()
            Text("\(hole.yardage)")
                .frame(width: 80)
            Divider()
            Text("\(hole.handicap)")
                .frame(width: 60)
            Divider()
            Text("\(hole.par)")
                .frame(width: 60)
            Divider()
            ScoreDisplayView(score: score, par: hole.par, scoreText: $scoreText)
                .frame(width: 100)
        }
        .frame(height: 56)
        .background(isEvenRow ? Color.white : Color.green.opacity(0.05))
    }
}

struct TotalRow: View {
    let label: String
    let yardage: Int
    let par: Int
    let total: Int
    let isHighlighted: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .frame(width: 60)
                .fontWeight(.bold)
            Divider()
            Text("\(yardage)")
                .frame(width: 80)
                .fontWeight(.bold)
            Divider()
            Text("")
                .frame(width: 60)
            Divider()
            Text("\(par)")
                .frame(width: 60)
                .fontWeight(.bold)
            Divider()
            Text("\(total)")
                .frame(width: 100)
                .fontWeight(.bold)
        }
        .frame(height: 56)
        .background(isHighlighted ? Color.green.opacity(0.1) : Color.white)
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
                Text("Tee: Blue, Handicap: 12") // Replace with actual data
                    .font(.subheadline)
                    .foregroundColor(.gray)
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

// Update MockData with 15 players
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
        Player(id: UUID(), firstName: "Ron", lastName: "Shimwell", email: "ron@example.com", nickname: "Puff"),
        Player(id: UUID(), firstName: "Clay", lastName: "Shimwell", email: "clay@example.com"),
        Player(id: UUID(), firstName: "Nick", lastName: "Ellison", email: "nick@example.com"),
        Player(id: UUID(), firstName: "Ryan", lastName: "Nelson", email: "ryan@example.com"),
        Player(id: UUID(), firstName: "Shelby", lastName: "Sims", email: "shelby@example.com"),
        Player(id: UUID(), firstName: "William", lastName: "Sparks", email: "william@example.com"),
        Player(id: UUID(), firstName: "Zack", lastName: "Antly", email: "zack@example.com", nickname: "Chicken")
    ]
    
    static private(set) var availablePlayers = allPlayers

    static func removeSelectedPlayers(_ players: [Player]) {
        availablePlayers.removeAll(where: { player in
            players.contains(where: { $0.id == player.id })
        })
    }
    
    static let defaultTeeBox = TeeBox(
        id: UUID(),
        name: "Blue",
        rating: 71.5,
        slope: 122,
        holes: Array(repeating: HoleInfo(id: UUID(), number: 1, par: 4, yardage: 400, handicap: 1), count: 18)
    )
}

struct AddPlayersView: View {
    let course: GolfCourse
    let teeBox: TeeBox?
    
    var body: some View {
        VStack {
            if let teeBox = teeBox {
                Text("Course: \(course.name)")
                Text("Tee Box: \(teeBox.name)")
                Text("Rating/Slope: \(teeBox.rating)/\(teeBox.slope)")
                // Add player input fields here
            } else {
                Text("Please select a tee box")
            }
        }
    }
}

struct MyAccountView: View {
    @StateObject private var userProfile = UserProfile()
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Personal Information")) {
                        TextField("First Name", text: $firstName)
                        TextField("Last Name", text: $lastName)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        Text("Scorecard Name: \(String(firstName.prefix(4).uppercased()))")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("My Account")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    let player = Player(id: userProfile.currentUser?.id ?? UUID(),
                                      firstName: firstName,
                                      lastName: lastName,
                                      email: email)
                    userProfile.saveUser(player)
                    dismiss()
                }
            )
            .onAppear {
                if let user = userProfile.currentUser {
                    firstName = user.firstName
                    lastName = user.lastName
                    email = user.email
                }
            }
        }
    }
}

extension Color {
    static let primaryGreen = Color(red: 0.2, green: 0.5, blue: 0.3)
    static let secondaryGold = Color(red: 0.85, green: 0.75, blue: 0.45)
    static let backgroundGray = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let textDark = Color(red: 0.2, green: 0.2, blue: 0.2)
}

// Add before LeaderboardView
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
                // Store scores and teeBox in all bets for this round
                for index in betManager.individualBets.indices {
                    betManager.individualBets[index].playerScores = playerScores
                    betManager.individualBets[index].teeBox = teeBox
                }
                
                for index in betManager.fourBallBets.indices {
                    betManager.fourBallBets[index].playerScores = playerScores
                    betManager.fourBallBets[index].teeBox = teeBox
                }
                
                for index in betManager.alabamaBets.indices {
                    betManager.alabamaBets[index].playerScores = playerScores
                    betManager.alabamaBets[index].teeBox = teeBox
                }
                
                for index in betManager.doDaBets.indices {
                    betManager.doDaBets[index].playerScores = playerScores
                    betManager.doDaBets[index].teeBox = teeBox
                }
                
                for index in betManager.skinsBets.indices {
                    betManager.skinsBets[index].playerScores = playerScores
                    betManager.skinsBets[index].teeBox = teeBox
                }
                
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

// Add PlayerRowView before LeaderboardView
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

// Remove these structs
// struct PlayerBetDetailsView: View { ... }
// struct IndividualBetRow: View { ... }
// struct FourBallBetRow: View { ... }

// Add BetType enum
enum BetType: String, CaseIterable, Identifiable {
    case individualMatch = "Individual Match"
    case fourBallMatch = "Four-Ball Match"
    case alabama = "Alabama"
    case wolf = "Wolf"
    case skins = "Skins"
    case doDas = "Do-Das"
    case hundredAces = "$100 Aces"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .individualMatch: return "Head to head match play between two players"
        case .fourBallMatch: return "Two teams of two players in match play format"
        case .alabama: return "Take the best 3 out of 4 scores and low ball team game"
        case .wolf: return "Each hole one player picks their partner"
        case .skins: return "Individual hole-by-hole competition"
        case .doDas: return "Bonus for scoring a 2 on any hole"
        case .hundredAces: return "Bonus for scoring a hole-in-one"
        }
    }
    
    var emoji: String {
        switch self {
        case .individualMatch: return "🤼"
        case .fourBallMatch: return "👥"
        case .alabama: return "🏌️‍♂️"
        case .wolf: return "🐺"
        case .skins: return "💰"
        case .doDas: return "✌️"
        case .hundredAces: return "🎯"
        }
    }
}

struct BetCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var betManager: BetManager
    let selectedPlayers: [Player]
    @State private var selectedBetType: BetType?
    @State private var showAnimation = false
    @State private var animationOffset: CGFloat = 0
    @State private var showIndividualMatchSetup = false
    @State private var showFourBallMatchSetup = false
    @State private var showAlabamaSetup = false
    @State private var showDoDaSetup = false
    @State private var showSkinsSetup = false
    @State private var showMenu = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Menu Button
                HStack {
                    Button(action: { showMenu = true }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Select Game Type")
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
                
                // Bet Type Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(BetType.allCases) { betType in
                            Button(action: {
                                handleBetSelection(betType)
                            }) {
                                BetTypeCard(betType: betType)
                            }
                        }
                    }
                }
                .padding()
            }
            .overlay {
                if showMenu {
                    SideMenuView(isShowing: $showMenu, showPlayerList: .constant(false), showFourBallMatchSetup: .constant(false))
                }
            }
        }
        .sheet(isPresented: $showIndividualMatchSetup) {
            IndividualMatchSetupView()
                .environmentObject(userProfile)
                .environmentObject(betManager)
        }
        .sheet(isPresented: $showFourBallMatchSetup) {
            FourBallMatchSetupView()
                .environmentObject(userProfile)
                .environmentObject(betManager)
        }
        .sheet(isPresented: $showAlabamaSetup) {
            AlabamaSetupView()
                .environmentObject(userProfile)
                .environmentObject(betManager)
        }
        .sheet(isPresented: $showDoDaSetup) {
            DoDaSetupView()
                .environmentObject(userProfile)
                .environmentObject(betManager)
        }
        .sheet(isPresented: $showSkinsSetup) {
            NavigationView {
                SkinsSetupView(players: selectedPlayers)
                    .environmentObject(userProfile)
                    .environmentObject(betManager)
            }
        }
    }
    
    private func handleBetSelection(_ betType: BetType) {
        print("Selected bet type: \(betType.rawValue)") // Debug print
        selectedBetType = betType
        
        // Trigger money emoji animation
        showAnimation = true
        withAnimation(.easeOut(duration: 0.5)) {
            animationOffset = -100
        }
        
        // After animation, show appropriate setup view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showAnimation = false
            animationOffset = 0
            
            switch betType {
            case .individualMatch:
                showIndividualMatchSetup = true
            case .fourBallMatch:
                showFourBallMatchSetup = true
            case .alabama:
                showAlabamaSetup = true
            case .doDas:
                showDoDaSetup = true
            case .skins:
                print("Showing skins setup") // Debug print
                showSkinsSetup = true
            default:
                break // Other bet types not implemented yet
            }
        }
    }
}

struct BetTypeCard: View {
    let betType: BetType
    
    var body: some View {
        HStack {
            Text(betType.emoji)
                .font(.title2)
                .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(betType.rawValue)
                    .font(.headline)
                Text(betType.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primaryGreen, lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primaryGreen.opacity(0.1))
                )
        )
    }
}
