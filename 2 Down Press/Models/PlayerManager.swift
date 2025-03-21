import Foundation
import BetComponents
import os

class PlayerManager: ObservableObject {
    @Published private(set) var currentRoundPlayers: [BetComponents.Player] = []
    @Published private(set) var historicalPlayers: [BetComponents.Player] = []
    private var lastPostedState: PostedState?
    private let logger = Logger(subsystem: "com.2downpress", category: "PlayerManager")
    
    // Structure to store complete state when posting
    private struct PostedState: Codable {
        let players: [BetComponents.Player]
        let scores: [UUID: [String]]
    }
    
    init() {
        loadHistoricalPlayers()
    }
    
    private func loadHistoricalPlayers() {
        // Load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "historicalPlayers"),
           let players = try? JSONDecoder().decode([BetComponents.Player].self, from: data) {
            self.historicalPlayers = players
            logger.debug("Loaded \(players.count) historical players")
        }
    }
    
    private func saveHistoricalPlayers() {
        // Save to UserDefaults
        if let data = try? JSONEncoder().encode(self.historicalPlayers) {
            UserDefaults.standard.set(data, forKey: "historicalPlayers")
            logger.debug("Saved \(self.historicalPlayers.count) historical players")
        }
    }
    
    func addPlayer(firstName: String, lastName: String, email: String = "") {
        let player = BetComponents.Player(
            id: UUID(),
            firstName: firstName,
            lastName: lastName,
            email: email
        )
        
        // Add to historical players if not already present
        if !self.historicalPlayers.contains(where: { $0.id == player.id }) {
            self.historicalPlayers.append(player)
            saveHistoricalPlayers()
            logger.debug("Added new player to historical players: \(player.firstName) \(player.lastName)")
        }
    }
    
    func addPlayerToCurrentRound(_ player: BetComponents.Player) {
        // Only add to current round if not already present
        if !self.currentRoundPlayers.contains(where: { $0.id == player.id }) {
            self.currentRoundPlayers.append(player)
            logger.debug("Added player to current round: \(player.firstName) \(player.lastName)")
        }
    }
    
    func removePlayerFromCurrentRound(_ player: BetComponents.Player) {
        // Only remove from current players
        self.currentRoundPlayers.removeAll { $0.id == player.id }
        logger.debug("Removed player from current round: \(player.firstName) \(player.lastName)")
    }
    
    func clearCurrentRoundPlayers() {
        // Clear current players
        self.currentRoundPlayers.removeAll()
        logger.debug("Cleared current round players")
    }
    
    func prepareForNewRound() {
        // Clear current players but keep historical
        self.currentRoundPlayers.removeAll()
        self.lastPostedState = nil
        logger.debug("Prepared for new round by clearing current players")
    }
    
    func postRound(betManager: BetManager, scores: [UUID: [String]]) {
        // Save current state before clearing
        let postedState = PostedState(
            players: self.currentRoundPlayers,
            scores: scores
        )
        self.lastPostedState = postedState
        
        // Clear current players
        self.currentRoundPlayers.removeAll()
        logger.debug("Posted round and saved state")
    }
    
    func unpostRound(betManager: BetManager, scores: [UUID: [String]]) -> Bool {
        // Restore last posted state
        if let lastState = self.lastPostedState {
            // Restore players
            self.currentRoundPlayers = lastState.players
            
            // Restore scores in BetManager
            if let teeBox = betManager.teeBox {
                betManager.updateScoresAndTeeBox(lastState.scores, teeBox)
            }
            
            self.lastPostedState = nil
            logger.debug("Unposted round and restored previous state")
            return true
        }
        return false
    }
    
    func getPlayer(byId id: UUID) -> BetComponents.Player? {
        self.currentRoundPlayers.first { $0.id == id }
    }
    
    func getPlayer(byName firstName: String, lastName: String) -> BetComponents.Player? {
        self.currentRoundPlayers.first { $0.firstName == firstName && $0.lastName == lastName }
    }
    
    // Get all available players for selection (historical only)
    func getAvailablePlayers() -> [BetComponents.Player] {
        // Return only historical players that aren't in current round
        return self.historicalPlayers.filter { player in
            !self.currentRoundPlayers.contains { $0.id == player.id }
        }.sorted { $0.firstName < $1.firstName }
    }
    
    // Get only current round's players
    func getCurrentRoundPlayers() -> [BetComponents.Player] {
        return self.currentRoundPlayers
    }
    
    func removePlayerFromHistorical(_ player: BetComponents.Player) {
        // Remove from historical players
        self.historicalPlayers.removeAll { $0.id == player.id }
        saveHistoricalPlayers()
        logger.debug("Removed player from historical players: \(player.firstName) \(player.lastName)")
    }
    
    func clearAllPlayers() {
        // Clear both current and historical players
        self.currentRoundPlayers.removeAll()
        self.historicalPlayers.removeAll()
        saveHistoricalPlayers()
        logger.debug("Cleared all players")
    }
} 