import SwiftUI
import BetComponents

struct PuttingWithPuffSetupView: View {
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    @EnvironmentObject private var playerManager: PlayerManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlayers: Set<UUID> = []
    @State private var showPuttingSession = false
    
    private var allAvailablePlayers: [BetComponents.Player] {
        var players = playerManager.currentRoundPlayers
        if let currentUser = userProfile.currentUser,
           !players.contains(where: { $0.id == currentUser.id }) {
            players.insert(currentUser, at: 0)
        }
        return players
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.deepNavyBlue,
                        Color.deepNavyBlue.opacity(0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("Select Players")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.primaryGreen)
                    
                    // Player Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(allAvailablePlayers) { player in
                            CompactPlayerButton(
                                player: player,
                                isSelected: selectedPlayers.contains(player.id),
                                action: {
                                    if selectedPlayers.contains(player.id) {
                                        selectedPlayers.remove(player.id)
                                    } else {
                                        selectedPlayers.insert(player.id)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Go Putt Button
                    if selectedPlayers.count >= 2 {
                        Button(action: {
                            let players = Set(allAvailablePlayers.filter { selectedPlayers.contains($0.id) })
                            betManager.addPuttingWithPuffBet(
                                players: players,
                                betAmount: 20.0
                            )
                            showPuttingSession = true
                        }) {
                            HStack {
                                Image(systemName: "figure.golf")
                                Text("Go Putt")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
                        }
                        .padding()
                    }
                }
                .navigationBarHidden(true)
            }
        }
        .fullScreenCover(isPresented: $showPuttingSession) {
            if let bet = betManager.puttingWithPuffBets.last {
                PuttingSessionView(bet: bet)
            }
        }
    }
}

private struct CompactPlayerButton: View {
    let player: BetComponents.Player
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    // Main circle with gradient
                    Circle()
                        .fill(
                            isSelected ?
                            LinearGradient(
                                gradient: Gradient(colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [.white, .white.opacity(0.9)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
                    
                    if isSelected {
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 40, height: 40)
                    }
                    
                    Text(player.firstName.prefix(1))
                        .font(.headline.bold())
                        .foregroundColor(isSelected ? .white : .primaryGreen)
                }
                
                Text(player.firstName)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, 8)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.primaryGreen.opacity(0.5) : Color.white.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: isSelected ? Color.primaryGreen.opacity(0.3) : Color.black.opacity(0.1),
                radius: isSelected ? 8 : 4,
                y: 2
            )
        }
    }
} 