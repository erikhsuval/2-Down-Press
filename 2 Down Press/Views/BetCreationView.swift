import SwiftUI
import BetComponents

struct BetCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var betManager: BetManager
    @State private var selectedBetType: BetType?
    @State private var showAnimation = false
    @State private var animationOffset: CGFloat = 0
    @State private var showIndividualMatchSetup = false
    @State private var showFourBallMatchSetup = false
    @State private var showAlabamaSetup = false
    @State private var showDoDaSetup = false
    @State private var showSkinsSetup = false
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
            
        case .wolf:
            // Not implemented yet
            break
            
        case nil:
            // No bet type selected yet
            break
        }
        
        // Start with all players
        var availablePlayers = MockData.allPlayers
        
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