import SwiftUI
import BetComponents

enum BetType: String, CaseIterable, Identifiable {
    case individualMatch = "Individual Match"
    case fourBallMatch = "Four-Ball Match"
    case alabama = "Alabama"
    case doDas = "Do-Da's"
    case skins = "Skins"
    case wolf = "Wolf"
    case circus = "Circus"
    case puttingWithPuff = "Putting with Puff"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .individualMatch:
            return "One-on-one match with optional presses"
        case .fourBallMatch:
            return "Two vs two better ball match"
        case .alabama:
            return "Team vs team with multiple scoring options"
        case .doDas:
            return "Pool or per-hole bet for making a 2"
        case .skins:
            return "Win holes outright to claim skins"
        case .wolf:
            return "Dynamic team selection each hole"
        case .circus:
            return "Various side bets and challenges"
        case .puttingWithPuff:
            return "Practice green putting games"
        }
    }
    
    var emoji: String {
        switch self {
        case .individualMatch: return "👥"
        case .fourBallMatch: return "👥"
        case .alabama: return "🏌️"
        case .doDas: return "✌️"
        case .skins: return "💰"
        case .wolf: return "🐺"
        case .circus: return "🎪"
        case .puttingWithPuff: return "💉"
        }
    }
}

struct BetCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var betManager: BetManager
    @EnvironmentObject var playerManager: PlayerManager
    @State private var selectedBetType: BetType?
    @State private var showAnimation = false
    @State private var animationOffset: CGFloat = 0
    @State private var showIndividualMatchSetup = false
    @State private var showFourBallMatchSetup = false
    @State private var showAlabamaSetup = false
    @State private var showDoDaSetup = false
    @State private var showSkinsSetup = false
    @State private var showPuttingWithPuffSetup = false
    @State private var showMenu = false
    
    // Use all available players instead of just selected ones
    private var availablePlayers: [BetComponents.Player] {
        // Get all players in current bets of the same type
        var playersInBets = Set<UUID>()
        
        switch selectedBetType {
        case .individualMatch, .fourBallMatch:
            // For individual and fourball matches, don't filter out any players
            // since they can participate in multiple bets
            break
            
        case .alabama:
            betManager.alabamaBets.forEach { bet in
                bet.teams.forEach { team in
                    team.forEach { player in
                        playersInBets.insert(player.id)
                    }
                }
            }
            
        case .doDas:
            betManager.doDaBets.forEach { bet in
                bet.players.forEach { player in
                    playersInBets.insert(player.id)
                }
            }
            
        case .skins:
            betManager.skinsBets.forEach { bet in
                bet.players.forEach { player in
                    playersInBets.insert(player.id)
                }
            }
            
        case .wolf, .circus, .puttingWithPuff:
            // Not implemented yet
            break
            
        case nil:
            // No bet type selected yet
            break
        }
        
        // Start with all players from PlayerManager
        var availablePlayers = playerManager.allPlayers
        
        // Always include current user if available
        if let currentUser = userProfile.currentUser,
           !availablePlayers.contains(where: { $0.id == currentUser.id }) {
            availablePlayers.insert(currentUser, at: 0)
        }
        
        // Only filter out players if a bet type is selected and it's not individual or fourball
        if let betType = selectedBetType,
           betType != .individualMatch && betType != .fourBallMatch {
            availablePlayers = availablePlayers.filter { player in
                !playersInBets.contains(player.id)
            }
        }
        
        return availablePlayers
    }
    
    var body: some View {
        ZStack {
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
                        
                        Text("Create Your Bet")
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
                                BetTypeCard(
                                    title: betType.rawValue,
                                    description: betType.description,
                                    imageName: betType.emoji,
                                    action: { handleBetSelection(betType) }
                                )
                            }
                        }
                    }
                    .padding()
                }
                .navigationBarHidden(true)
            }
            
            // Side Menu
            if showMenu {
                SideMenuView(
                    isShowing: $showMenu,
                    showPlayerList: .constant(false),
                    showFourBallMatchSetup: .constant(false)
                )
            }
        }
        .sheet(isPresented: $showIndividualMatchSetup) {
            IndividualMatchSetupView(selectedPlayers: availablePlayers, betManager: betManager)
                .environmentObject(userProfile)
        }
        .sheet(isPresented: $showFourBallMatchSetup) {
            NavigationView {
                FourBallMatchSetupView(selectedPlayers: availablePlayers, betManager: betManager)
                    .environmentObject(userProfile)
                    .environmentObject(betManager)
            }
        }
        .sheet(isPresented: $showAlabamaSetup) {
            NavigationView {
                AlabamaSetupView(allPlayers: availablePlayers, betManager: betManager)
                    .environmentObject(userProfile)
                    .environmentObject(betManager)
            }
        }
        .sheet(isPresented: $showDoDaSetup) {
            DoDaSetupView(selectedPlayers: availablePlayers, betManager: betManager)
                .environmentObject(userProfile)
                .environmentObject(betManager)
        }
        .sheet(isPresented: $showSkinsSetup) {
            NavigationView {
                SkinsSetupView(players: availablePlayers, betManager: betManager)
                    .environmentObject(userProfile)
                    .environmentObject(betManager)
            }
        }
        .sheet(isPresented: $showPuttingWithPuffSetup) {
            PuttingWithPuffSetupView()
                .environmentObject(userProfile)
                .environmentObject(betManager)
        }
    }
    
    private func handleBetSelection(_ betType: BetType) {
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
                showSkinsSetup = true
            case .puttingWithPuff:
                showPuttingWithPuffSetup = true
            default:
                break // Other bet types not implemented yet
            }
        }
    }
}

struct BetTypeCard: View {
    let title: String
    let description: String
    let imageName: String
    let action: () -> Void
    
    var isImplemented: Bool {
        // Return false for unimplemented bet types
        !["Wolf", "Circus"].contains(title)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(imageName)
                    .font(.system(size: 30))
                    .foregroundColor(isImplemented ? .primaryGreen : .gray)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(isImplemented ? .primary : .gray)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(isImplemented ? .gray : .gray.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
                
                if !isImplemented {
                    Text("Coming Soon!")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray)
                        )
                }
            }
            .frame(height: 160)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 5)
            )
        }
        .disabled(!isImplemented)
    }
} 