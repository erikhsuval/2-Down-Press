import Foundation
import BetComponents
import os

class PlayerManager: ObservableObject {
    @Published private(set) var allPlayers: [BetComponents.Player] = []
    private let userDefaults = UserDefaults.standard
    private let currentRoundPlayersKey = "currentRoundPlayers"
    private let logger = Logger(subsystem: "com.2downpress", category: "PlayerManager")
    
    init() {
        loadCurrentRoundPlayers()
    }
    
    private func loadCurrentRoundPlayers() {
        if let data = userDefaults.data(forKey: currentRoundPlayersKey),
           let players = try? JSONDecoder().decode([BetComponents.Player].self, from: data) {
            allPlayers = players
        }
    }
    
    func addPlayer(firstName: String, lastName: String, email: String = "") {
        let player = BetComponents.Player(
            id: UUID(),
            firstName: firstName,
            lastName: lastName,
            email: email
        )
        allPlayers.append(player)
        saveCurrentRoundPlayers()
        logger.debug("Added player: \(player.firstName) \(player.lastName)")
    }
    
    func removePlayer(_ player: BetComponents.Player) {
        allPlayers.removeAll { $0.id == player.id }
        saveCurrentRoundPlayers()
        logger.debug("Removed player: \(player.firstName) \(player.lastName)")
    }
    
    func clearAllPlayers() {
        allPlayers.removeAll()
        saveCurrentRoundPlayers()
    }
    
    private func saveCurrentRoundPlayers() {
        if let data = try? JSONEncoder().encode(allPlayers) {
            userDefaults.set(data, forKey: currentRoundPlayersKey)
        }
    }
    
    func getPlayer(byId id: UUID) -> BetComponents.Player? {
        allPlayers.first { $0.id == id }
    }
    
    func getPlayer(byName firstName: String, lastName: String) -> BetComponents.Player? {
        allPlayers.first { $0.firstName == firstName && $0.lastName == lastName }
    }
} 