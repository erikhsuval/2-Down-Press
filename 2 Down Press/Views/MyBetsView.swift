import SwiftUI
import BetComponents

struct MyBetsView: View {
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    @State private var showEditIndividualBet = false
    @State private var showEditFourBallBet = false
    @State private var showEditAlabamaBet = false
    @State private var showEditDoDaBet = false
    @State private var showEditSkinsBet = false
    @State private var showNewSkinsBet = false
    @State private var showNewIndividualBet = false
    @State private var showNewFourBallBet = false
    @State private var showNewAlabamaBet = false
    @State private var showNewDoDaBet = false
    @State private var betToEdit: Any? = nil
    @State private var showBetCreation = false
    
    var allPlayers: [BetComponents.Player] {
        var players = Set<BetComponents.Player>()
        
        // Add players from individual bets
        for bet in betManager.individualBets {
            players.insert(bet.player1)
            players.insert(bet.player2)
        }
        
        // Add players from four ball bets
        for bet in betManager.fourBallBets {
            players.insert(bet.team1Player1)
            players.insert(bet.team1Player2)
            players.insert(bet.team2Player1)
            players.insert(bet.team2Player2)
        }
        
        // Add players from alabama bets
        for bet in betManager.alabamaBets {
            for team in bet.teams {
                players.formUnion(team)
            }
            if let swingMan = bet.swingMan {
                players.insert(swingMan)
            }
        }
        
        // Add players from do-da bets
        for bet in betManager.doDaBets {
            players.formUnion(bet.players)
        }
        
        // Add players from skins bets
        for bet in betManager.skinsBets {
            players.formUnion(bet.players)
        }
        
        // Always include current user if available
        if let user = userProfile.currentUser {
            players.insert(user)
        }
        
        return Array(players)
    }
    
    var myIndividualBets: [IndividualMatchBet] {
        guard let user = userProfile.currentUser else { return [] }
        return betManager.individualBets.filter { bet in
            bet.player1.id == user.id || bet.player2.id == user.id
        }
    }
    
    var myFourBallBets: [FourBallMatchBet] {
        guard let user = userProfile.currentUser else { return [] }
        return betManager.fourBallBets.filter { bet in
            bet.team1Player1.id == user.id || 
            bet.team1Player2.id == user.id ||
            bet.team2Player1.id == user.id || 
            bet.team2Player2.id == user.id
        }
    }
    
    var myAlabamaBets: [AlabamaBet] {
        guard let user = userProfile.currentUser else { return [] }
        return betManager.alabamaBets.filter { bet in
            bet.teams.contains { team in
                team.contains { player in
                    player.id == user.id
                }
            }
        }
    }
    
    var myDoDaBets: [DoDaBet] {
        guard let user = userProfile.currentUser else { return [] }
        return betManager.doDaBets.filter { bet in
            bet.players.contains { $0.id == user.id }
        }
    }
    
    var mySkinsBets: [SkinsBet] {
        guard let user = userProfile.currentUser else { return [] }
        return betManager.skinsBets.filter { bet in
            bet.players.contains { $0.id == user.id }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                IndividualBetsSection(
                    bets: myIndividualBets,
                    onDelete: { bet in
                        betManager.deleteIndividualBet(bet)
                    },
                    onEdit: { bet in
                        betToEdit = bet
                        showEditIndividualBet = true
                    }
                )
                
                FourBallBetsSection(
                    bets: myFourBallBets,
                    onDelete: { bet in
                        betManager.deleteFourBallBet(bet)
                    },
                    onEdit: { bet in
                        betToEdit = bet
                        showEditFourBallBet = true
                    }
                )
                
                AlabamaBetsSection(
                    bets: myAlabamaBets,
                    onDelete: { bet in
                        betManager.deleteAlabamaBet(bet)
                    },
                    onEdit: { bet in
                        betToEdit = bet
                        showEditAlabamaBet = true
                    }
                )
                
                SkinsBetsSection(
                    bets: mySkinsBets,
                    onDelete: { bet in
                        betManager.deleteSkinsBet(bet)
                    },
                    onEdit: { bet in
                        betToEdit = bet
                        showEditSkinsBet = true
                    }
                )
                
                DoDaBetsSection(
                    bets: myDoDaBets,
                    onDelete: { bet in
                        betManager.deleteDoDaBet(bet)
                    },
                    onEdit: { bet in
                        betToEdit = bet
                        showEditDoDaBet = true
                    }
                )
            }
            .navigationTitle("My Bets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showNewSkinsBet = false  // Reset this state
                        showBetCreation = true   // Show bet creation instead
                    }) {
                        Image(systemName: "dollarsign.circle")
                    }
                }
            }
            .sheet(isPresented: $showBetCreation) {
                BetCreationView()
                    .environmentObject(betManager)
                    .environmentObject(userProfile)
            }
            .sheet(isPresented: $showNewIndividualBet) {
                IndividualMatchSetupView(editingBet: nil, selectedPlayers: allPlayers, betManager: betManager)
                    .environmentObject(userProfile)
            }
            .sheet(isPresented: $showNewFourBallBet) {
                NavigationView {
                    FourBallMatchSetupView(editingBet: nil, selectedPlayers: allPlayers, betManager: betManager)
                        .environmentObject(betManager)
                        .environmentObject(userProfile)
                }
            }
            .sheet(isPresented: $showNewAlabamaBet) {
                NavigationView {
                    AlabamaSetupView(editingBet: nil, allPlayers: allPlayers, betManager: betManager)
                        .environmentObject(betManager)
                        .environmentObject(userProfile)
                }
            }
            .sheet(isPresented: $showNewDoDaBet) {
                NavigationView {
                    DoDaSetupView(editingBet: nil, selectedPlayers: allPlayers, betManager: betManager)
                        .environmentObject(betManager)
                        .environmentObject(userProfile)
                }
            }
            .sheet(isPresented: $showEditIndividualBet) {
                if let bet = betToEdit as? IndividualMatchBet {
                    IndividualMatchSetupView(editingBet: bet, selectedPlayers: allPlayers, betManager: betManager)
                        .environmentObject(userProfile)
                }
            }
            .sheet(isPresented: $showEditFourBallBet) {
                if let bet = betToEdit as? FourBallMatchBet {
                    NavigationView {
                        FourBallMatchSetupView(editingBet: bet, selectedPlayers: allPlayers, betManager: betManager)
                            .environmentObject(betManager)
                            .environmentObject(userProfile)
                    }
                }
            }
            .sheet(isPresented: $showEditAlabamaBet) {
                if let bet = betToEdit as? AlabamaBet {
                    NavigationView {
                        AlabamaSetupView(editingBet: bet, allPlayers: allPlayers, betManager: betManager)
                            .environmentObject(betManager)
                            .environmentObject(userProfile)
                    }
                }
            }
            .sheet(isPresented: $showEditSkinsBet) {
                if let bet = betToEdit as? SkinsBet {
                    NavigationView {
                        SkinsSetupView(editingBet: bet, players: allPlayers, betManager: betManager)
                            .environmentObject(betManager)
                            .environmentObject(userProfile)
                    }
                }
            }
            .sheet(isPresented: $showEditDoDaBet) {
                if let bet = betToEdit as? DoDaBet {
                    NavigationView {
                        DoDaSetupView(editingBet: bet, selectedPlayers: allPlayers, betManager: betManager)
                            .environmentObject(betManager)
                            .environmentObject(userProfile)
                    }
                }
            }
        }
    }
} 