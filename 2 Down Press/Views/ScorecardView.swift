import SwiftUI
import BetComponents

struct ScorecardView: View {
    let course: GolfCourse
    let teeBox: TeeBox
    @State private var showMenu = false
    @State private var showBetCreation = false
    @State private var showPlayerSelection = false
    @EnvironmentObject private var userProfile: UserProfile
    @EnvironmentObject private var betManager: BetManager
    
    var body: some View {
        VStack(spacing: 0) {
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
                    
                    // Placeholder for scorecard grid
                    Text("Scorecard Content")
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            
            // Bottom action buttons
            HStack(spacing: 20) {
                Button(action: { /* Show round status */ }) {
                    VStack {
                        Image(systemName: "flag.filled")
                            .foregroundColor(.primaryGreen)
                        Text("Round")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                
                Button(action: { showBetCreation = true }) {
                    VStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.primaryGreen)
                        Text("Games")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .shadow(radius: 2, y: -2)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showMenu) {
            MenuView()
                .environmentObject(betManager)
                .environmentObject(userProfile)
        }
        .sheet(isPresented: $showBetCreation) {
            BetCreationView(selectedPlayers: []) // TODO: Pass actual selected players
                .environmentObject(betManager)
                .environmentObject(userProfile)
        }
    }
} 