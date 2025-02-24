import SwiftUI
import BetComponents

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
                .background(Color(red: 0.2, green: 0.5, blue: 0.3))
                
                // Bet Type Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(BetType.allCases) { betType in
                            let systemImage = switch betType {
                            case .individualMatch: "person.2"
                            case .fourBallMatch: "person.3"
                            case .alabama: "person.3.sequence"
                            case .doDas: "2.circle"
                            case .skins: "dollarsign.circle"
                            case .wolf: "person.2.circle"
                            }
                            
                            BetTypeCard(
                                title: betType.rawValue,
                                description: betType.description,
                                imageName: systemImage,
                                action: { handleBetSelection(betType) }
                            )
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showIndividualMatchSetup) {
            IndividualMatchSetupView(selectedPlayers: selectedPlayers)
                .environmentObject(userProfile)
                .environmentObject(betManager)
        }
        .sheet(isPresented: $showFourBallMatchSetup) {
            FourBallMatchSetupView(selectedPlayers: selectedPlayers)
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