import Foundation
import SwiftUI
import BetComponents

class BetManager: ObservableObject {
    private var betComponentsManager = BetComponents.BetManager()
    
    @Published var currentUser: BetComponents.Player?
    @Published var selectedPlayers: [BetComponents.Player] = []
    @Published var teeBox: BetComponents.TeeBox?
    @Published var circusBets: [CircusBet] = []
    
    var puttingWithPuffBets: [BetComponents.PuttingWithPuffBet] {
        get { betComponentsManager.puttingWithPuffBets }
        set { 
            betComponentsManager.puttingWithPuffBets = newValue
            objectWillChange.send()
        }
    }
    
    var skinsBets: [BetComponents.SkinsBet] {
        get { betComponentsManager.skinsBets }
        set { betComponentsManager.skinsBets = newValue }
    }
    
    var playerScores: [UUID: [String]] {
        get { betComponentsManager.playerScores }
        set { betComponentsManager.playerScores = newValue }
    }
    
    var individualBets: [BetComponents.IndividualMatchBet] {
        get { betComponentsManager.individualBets }
        set { betComponentsManager.individualBets = newValue }
    }
    
    var fourBallBets: [BetComponents.FourBallMatchBet] {
        get { betComponentsManager.fourBallBets }
        set { betComponentsManager.fourBallBets = newValue }
    }
    
    var alabamaBets: [BetComponents.AlabamaBet] {
        get { betComponentsManager.alabamaBets }
        set { betComponentsManager.alabamaBets = newValue }
    }
    
    var doDaBets: [BetComponents.DoDaBet] {
        get { betComponentsManager.doDaBets }
        set { betComponentsManager.doDaBets = newValue }
    }
    
    var allPlayers: [BetComponents.Player] {
        var players = Set<BetComponents.Player>()
        
        // Add current user if available
        if let currentUser = currentUser {
            players.insert(currentUser)
        }
        
        // Add selected players
        players.formUnion(selectedPlayers)
        
        // Add players from all bet types
        individualBets.forEach { bet in
            players.insert(bet.player1)
            players.insert(bet.player2)
        }
        
        fourBallBets.forEach { bet in
            players.insert(bet.team1Player1)
            players.insert(bet.team1Player2)
            players.insert(bet.team2Player1)
            players.insert(bet.team2Player2)
        }
        
        alabamaBets.forEach { bet in
            bet.teams.forEach { team in
                players.formUnion(team)
            }
            if let swingMan = bet.swingMan {
                players.insert(swingMan)
            }
        }
        
        doDaBets.forEach { bet in
            players.formUnion(bet.players)
        }
        
        skinsBets.forEach { bet in
            players.formUnion(bet.players)
        }
        
        return Array(players).sorted { $0.firstName < $1.firstName }
    }
    
    func calculateTotalWinnings(player: BetComponents.Player, playerScores: [UUID: [String]], teeBox: BetComponents.TeeBox) -> Double {
        var total = 0.0
        
        // Calculate individual bet winnings
        for bet in individualBets {
            let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
            if bet.player1.id == player.id {
                total += winnings
            } else if bet.player2.id == player.id {
                total -= winnings
            }
        }
        
        // Calculate four ball bet winnings
        for bet in fourBallBets {
            let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
            if bet.team1Player1.id == player.id || bet.team1Player2.id == player.id {
                total += winnings / 2
            } else if bet.team2Player1.id == player.id || bet.team2Player2.id == player.id {
                total -= winnings / 2
            }
        }
        
        // Calculate skins bet winnings
        for bet in skinsBets {
            if let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
                total += winnings
            }
        }
        
        // Calculate Do-Da bet winnings
        for bet in doDaBets {
            if let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
                total += winnings
            }
        }
        
        // Calculate Alabama bet winnings
        for bet in alabamaBets {
            if let teamIndex = bet.teams.firstIndex(where: { team in team.contains { $0.id == player.id } }) {
                for otherTeamIndex in bet.teams.indices where otherTeamIndex != teamIndex {
                    let results = bet.calculateTeamResults(
                        playerTeamIndex: teamIndex,
                        otherTeamIndex: otherTeamIndex,
                        scores: playerScores,
                        teeBox: teeBox
                    )
                    total += results.total
                }
            }
        }
        
        return total
    }
    
    func addSkinsBet(amount: Double, players: [BetComponents.Player]) {
        betComponentsManager.addSkinsBet(amount: amount, players: players)
    }
    
    func deleteSkinsBet(_ bet: BetComponents.SkinsBet) {
        betComponentsManager.deleteSkinsBet(bet)
    }
    
    func addIndividualBet(player1: BetComponents.Player, player2: BetComponents.Player, perHoleAmount: Double, perBirdieAmount: Double, pressOn9and18: Bool) {
        betComponentsManager.addIndividualBet(
            player1: player1,
            player2: player2,
            perHoleAmount: perHoleAmount,
            perBirdieAmount: perBirdieAmount,
            pressOn9and18: pressOn9and18
        )
    }
    
    func deleteIndividualBet(_ bet: BetComponents.IndividualMatchBet) {
        betComponentsManager.deleteIndividualBet(bet)
    }
    
    func addFourBallBet(team1Player1: BetComponents.Player, team1Player2: BetComponents.Player, team2Player1: BetComponents.Player, team2Player2: BetComponents.Player, perHoleAmount: Double, perBirdieAmount: Double, pressOn9and18: Bool) {
        betComponentsManager.addFourBallBet(
            team1Player1: team1Player1,
            team1Player2: team1Player2,
            team2Player1: team2Player1,
            team2Player2: team2Player2,
            perHoleAmount: perHoleAmount,
            perBirdieAmount: perBirdieAmount,
            pressOn9and18: pressOn9and18
        )
    }
    
    func deleteFourBallBet(_ bet: BetComponents.FourBallMatchBet) {
        betComponentsManager.deleteFourBallBet(bet)
    }
    
    func addAlabamaBet(teams: [[BetComponents.Player]], swingMan: BetComponents.Player?, swingManTeamIndex: Int?, countingScores: Int, frontNineAmount: Double, backNineAmount: Double, lowBallAmount: Double, perBirdieAmount: Double) {
        betComponentsManager.addAlabamaBet(
            teams: teams,
            swingMan: swingMan,
            swingManTeamIndex: swingManTeamIndex,
            countingScores: countingScores,
            frontNineAmount: frontNineAmount,
            backNineAmount: backNineAmount,
            lowBallAmount: lowBallAmount,
            perBirdieAmount: perBirdieAmount
        )
    }
    
    func deleteAlabamaBet(_ bet: BetComponents.AlabamaBet) {
        betComponentsManager.deleteAlabamaBet(bet)
    }
    
    func addDoDaBet(isPool: Bool, amount: Double, players: [BetComponents.Player]) {
        betComponentsManager.addDoDaBet(
            isPool: isPool,
            amount: amount,
            players: players
        )
    }
    
    func deleteDoDaBet(_ bet: BetComponents.DoDaBet) {
        betComponentsManager.deleteDoDaBet(bet)
    }
    
    func updatePuttingWithPuffBet(_ bet: BetComponents.PuttingWithPuffBet) {
        betComponentsManager.updatePuttingWithPuffBet(bet)
        objectWillChange.send()
    }
    
    func importScores(from scoreData: ShareableScoreData, course: GolfCourse, teeBox: BetComponents.TeeBox) -> Bool {
        // Verify the course and tee box match
        guard scoreData.courseId == course.id, scoreData.teeBoxName == teeBox.name else {
            return false
        }
        
        // Add players if they're not already in the selected players list
        for playerData in scoreData.players {
            let player = BetComponents.Player(
                id: playerData.id,
                firstName: playerData.firstName,
                lastName: playerData.lastName,
                email: ""  // Email not included in shared data for privacy
            )
            
            if !selectedPlayers.contains(where: { $0.id == player.id }) {
                selectedPlayers.append(player)
            }
            
            // Update scores
            betComponentsManager.playerScores[playerData.id] = playerData.scores
        }
        
        objectWillChange.send()
        return true
    }
    
    func mergeGroupScores() {
        betComponentsManager.mergeGroupScores()
    }
    
    func updateGroupScores(_ scores: [UUID: [String]], forGroup groupIndex: Int) {
        betComponentsManager.updateGroupScores(scores, forGroup: groupIndex)
    }
    
    func updateScoresAndTeeBox(_ scores: [UUID: [String]], _ newTeeBox: BetComponents.TeeBox) {
        playerScores = scores
        teeBox = newTeeBox
        objectWillChange.send()
    }
    
    func addPuttingWithPuffBet(players: Set<BetComponents.Player>, betAmount: Double) {
        let bet = BetComponents.PuttingWithPuffBet(players: players, betAmount: betAmount)
        betComponentsManager.puttingWithPuffBets.append(bet)
        objectWillChange.send()
    }
    
    // Calculate winnings for side bets only
    func calculateSideBetWinnings(player: BetComponents.Player, playerScores: [UUID: [String]], teeBox: BetComponents.TeeBox) -> Double {
        var totalSideBetWinnings = 0.0
        
        // Calculate circus bet winnings
        for bet in circusBets where bet.players.contains(where: { $0.id == player.id }) {
            if let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
                totalSideBetWinnings += winnings
            }
        }
        
        // Calculate putting with puff winnings
        for bet in puttingWithPuffBets where bet.players.contains(where: { $0.id == player.id }) {
            if let winnings = bet.playerTotals[player.id] {
                totalSideBetWinnings += winnings
            }
        }
        
        return totalSideBetWinnings
    }
    
    func clearAllBets() {
        betComponentsManager.individualBets.removeAll()
        betComponentsManager.fourBallBets.removeAll()
        betComponentsManager.alabamaBets.removeAll()
        betComponentsManager.doDaBets.removeAll()
        betComponentsManager.skinsBets.removeAll()
        betComponentsManager.playerScores.removeAll()
        teeBox = nil
        objectWillChange.send()
    }
    
    func restoreGameState(from gameState: GameState) {
        // Restore all bets
        betComponentsManager.individualBets = gameState.bets.individualBets
        betComponentsManager.fourBallBets = gameState.bets.fourBallBets
        betComponentsManager.alabamaBets = gameState.bets.alabamaBets
        betComponentsManager.doDaBets = gameState.bets.doDaBets
        betComponentsManager.skinsBets = gameState.bets.skinsBets
        
        // Restore scores and players
        betComponentsManager.playerScores = gameState.scores
        selectedPlayers = gameState.players
        
        objectWillChange.send()
    }
    
    init() {
        // Initialize any required properties here
    }
} 