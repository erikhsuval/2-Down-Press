//
//  ContentView.swift
//  2 Down Press
//
//  Created by Erik Hsu on 1/11/25.
//

import SwiftUI
import CoreLocation
import BetComponents
import os

// Then LocationManager
class LocationManager: NSObject, ObservableObject {
    private let golfService: GolfCourseServiceProtocol
    private let logger = Logger(subsystem: "com.2downpress", category: "LocationManager")
    
    @Published var courses: [GolfCourse] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    init(golfService: GolfCourseServiceProtocol = GolfCourseService()) {
        self.golfService = golfService
        super.init()
        loadCourses()
    }
    
    private func loadCourses() {
        isLoading = true
        logger.debug("Loading courses...")
        
        let course = golfService.getGolfCourse()
        logger.debug("Loaded course: \(course.name) with \(course.teeBoxes.count) tee boxes")
        courses = [course]
        isLoading = false
        
        if courses.isEmpty {
            logger.error("No courses loaded")
            self.error = NSError(domain: "com.2downpress", code: -1, userInfo: [NSLocalizedDescriptionKey: "No courses available"])
        }
    }
    
    func startUpdatingLocation() {
        // No-op since we're not using location services
        // But reload courses just in case
        loadCourses()
    }
}

class UserProfile: ObservableObject {
    @Published var currentUser: BetComponents.Player?
    private let userDefaults = UserDefaults.standard
    private let logger = Logger(subsystem: "com.2downpress", category: "UserProfile")
        
    init() {
        loadUser()
    }
    
    func saveUser(_ player: BetComponents.Player) {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(player)
            userDefaults.set(encoded, forKey: "currentUser")
            currentUser = player
            logger.debug("Saved user: \(player.firstName) \(player.lastName)")
        } catch {
            logger.error("Failed to save user: \(error.localizedDescription)")
        }
    }
    
    private func loadUser() {
        if let userData = userDefaults.data(forKey: "currentUser") {
            do {
                let player = try JSONDecoder().decode(BetComponents.Player.self, from: userData)
                currentUser = player
                logger.debug("Loaded user: \(player.firstName) \(player.lastName)")
            } catch {
                logger.error("Failed to load user: \(error.localizedDescription)")
            }
        }
    }
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
                    let player = BetComponents.Player(id: UUID(),
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

struct MainMenuButtonView: View {
    let title: String
    let subtitle: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 24))
                Text(title)
                    .font(.title3)
            }
            
            Text(subtitle)
                .font(.subheadline)
        }
        .frame(width: UIScreen.main.bounds.width * 0.75) // 75% of screen width
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.2)) // Transparent white
        .foregroundColor(.white)
        .cornerRadius(16)
    }
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager(golfService: GolfCourseService())
    @StateObject private var userProfile = UserProfile()
    @StateObject private var betManager = BetManager()
    @StateObject private var gameStateManager = GameStateManager()
    @State private var showMenu = false
    @State private var showPlayerList = false
    @State private var showMyAccount = false
    @State private var showMyBets = false
    @State private var showTheSheet = false
    @State private var showFourBallMatchSetup = false
    @State private var showContinueAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Image
                Image("golf-background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(Color.black.opacity(0.3))
                
                VStack {
                    // Logo and Title
                    VStack(spacing: 8) {
                        Text("2 Down Press")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2)
                        
                        Text("Golf Group Bets Made Easy")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                    
                    // Main Navigation Buttons
                    VStack(spacing: 20) {
                        if let currentGame = gameStateManager.currentGame {
                            Button {
                                // Restore the game state before navigating
                                gameStateManager.restoreGame(to: betManager)
                                if let course = locationManager.courses.first(where: { $0.id == currentGame.courseId }),
                                   let teeBox = course.teeBoxes.first(where: { $0.name == currentGame.teeBoxName }) {
                                    // Update the betManager with the course and tee box
                                    betManager.teeBox = teeBox
                                    showPlayerList = true
                                }
                            } label: {
                                MainMenuButtonView(
                                    title: "Continue Round",
                                    subtitle: "\(currentGame.courseName) • \(currentGame.players.count) Players",
                                    systemImage: "arrow.forward.circle.fill"
                                )
                            }
                            
                            Button {
                                gameStateManager.clearCurrentGame()
                                if userProfile.currentUser == nil {
                                    showMyAccount = true
                                } else {
                                    showPlayerList = true
                                }
                            } label: {
                                MainMenuButtonView(
                                    title: "New Round",
                                    subtitle: "Start fresh round",
                                    systemImage: "plus.circle.fill"
                                )
                            }
                        } else {
                            Button {
                                if userProfile.currentUser == nil {
                                    showMyAccount = true
                                } else {
                                    showPlayerList = true
                                }
                            } label: {
                                MainMenuButtonView(
                                    title: "Start Round",
                                    subtitle: "Begin new round",
                                    systemImage: "figure.golf"
                                )
                            }
                        }
                        
                        Button {
                            showMenu = true
                        } label: {
                            MainMenuButtonView(
                                title: "Menu",
                                subtitle: "Settings & more",
                                systemImage: "line.3.horizontal"
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showMenu) {
            MenuView()
                .environmentObject(betManager)
                .environmentObject(userProfile)
        }
        .sheet(isPresented: $showMyAccount) {
            PlayerDetailsView()
                .environmentObject(userProfile)
                .environmentObject(betManager)
        }
        .sheet(isPresented: $showPlayerList) {
            if let currentGame = gameStateManager.currentGame {
                // If continuing a game, go directly to scorecard
                if let course = locationManager.courses.first(where: { $0.id == currentGame.courseId }),
                   let teeBox = course.teeBoxes.first(where: { $0.name == currentGame.teeBoxName }) {
                    ScorecardView(course: course, teeBox: teeBox)
                        .environmentObject(betManager)
                        .environmentObject(userProfile)
                }
            } else {
                // Otherwise show course selection
                GolfCourseSelectionView(locationManager: locationManager)
                    .environmentObject(betManager)
                    .environmentObject(userProfile)
            }
        }
        .environmentObject(userProfile)
        .environmentObject(betManager)
        .environmentObject(gameStateManager)
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
        NavigationStack {
            List {
                if locationManager.isLoading {
                    ProgressView("Loading courses...")
                } else {
                    ForEach(locationManager.courses) { course in
                        NavigationLink(destination: TeeBoxSelectionView(course: course)
                            .environmentObject(userProfile)
                            .environmentObject(betManager)) {
                            Text(course.name)
                                .font(.headline)
                        }
                    }
                }
            }
            .navigationTitle("Select Course")
        }
        .onAppear {
            locationManager.startUpdatingLocation()
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
    }
}

// Single preview for ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 