//
//  ContentView.swift
//  2 Down Press
//
//  Created by Erik Hsu on 1/11/25.
//

import SwiftUI
import CoreLocation
import BetComponents

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
    @Published var currentUser: BetComponents.Player?
    private let userDefaults = UserDefaults.standard
        
    init() {
        loadUser()
    }
    
    func saveUser(_ player: BetComponents.Player) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(player) {
            userDefaults.set(encoded, forKey: "currentUser")
            currentUser = player
        }
    }
    
    private func loadUser() {
        if let userData = userDefaults.data(forKey: "currentUser"),
           let player = try? JSONDecoder().decode(BetComponents.Player.self, from: userData) {
            currentUser = player
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
                            MainMenuButtonView(title: "Play", systemImage: "figure.golf")
                        }
                        
                        Button(action: { showMenu.toggle() }) {
                            MainMenuButtonView(title: "Menu", systemImage: "line.3.horizontal")
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

struct MainMenuButtonView: View {
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
                .fill(Color.primaryGreen.opacity(0.8))
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
                        NavigationLink(destination: TeeBoxSelectionView(course: course)
                            .environmentObject(userProfile)
                            .environmentObject(betManager)) {
                            VStack(alignment: .leading) {
                                Text(course.name)
                                    .font(.headline)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Course")
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