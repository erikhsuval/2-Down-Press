import Foundation
import SwiftUI

public struct IndividualMatchBet: Identifiable {
    public let id: UUID
    public let player1: Player
    public let player2: Player
    public let perHoleAmount: Double
    public let perBirdieAmount: Double
    public let pressOn9and18: Bool
    public var playerScores: [UUID: [String]]?
    public var teeBox: TeeBox?
    
    public init(id: UUID, player1: Player, player2: Player, perHoleAmount: Double, perBirdieAmount: Double, pressOn9and18: Bool) {
        self.id = id
        self.player1 = player1
        self.player2 = player2
        self.perHoleAmount = perHoleAmount
        self.perBirdieAmount = perBirdieAmount
        self.pressOn9and18 = pressOn9and18
    }
    
    public func calculateWinnings(playerScores: [UUID: [String]], teeBox: TeeBox) -> Double {
        guard let player1Scores = playerScores[player1.id],
              let player2Scores = playerScores[player2.id] else {
            return 0
        }
        
        var totalWinnings = 0.0
        
        // Calculate hole-by-hole winnings
        for (index, (p1Score, p2Score)) in zip(player1Scores, player2Scores).enumerated() {
            guard let score1 = Int(p1Score), let score2 = Int(p2Score) else { continue }
            if score1 < score2 {
                totalWinnings += perHoleAmount
            } else if score2 < score1 {
                totalWinnings -= perHoleAmount
            }
            
            // Add birdie bonus
            if score1 < teeBox.holes[index].par {
                totalWinnings += perBirdieAmount
            }
            if score2 < teeBox.holes[index].par {
                totalWinnings -= perBirdieAmount
            }
        }
        
        return totalWinnings
    }
}

public struct FourBallMatchBet: Identifiable {
    public let id: UUID
    public let team1Player1: Player
    public let team1Player2: Player
    public let team2Player1: Player
    public let team2Player2: Player
    public let perHoleAmount: Double
    public let perBirdieAmount: Double
    public let pressOn9and18: Bool
    public var playerScores: [UUID: [String]]?
    public var teeBox: TeeBox?
    
    public init(id: UUID, team1Player1: Player, team1Player2: Player, team2Player1: Player, team2Player2: Player, perHoleAmount: Double, perBirdieAmount: Double, pressOn9and18: Bool) {
        self.id = id
        self.team1Player1 = team1Player1
        self.team1Player2 = team1Player2
        self.team2Player1 = team2Player1
        self.team2Player2 = team2Player2
        self.perHoleAmount = perHoleAmount
        self.perBirdieAmount = perBirdieAmount
        self.pressOn9and18 = pressOn9and18
    }
    
    public func calculateWinnings(playerScores: [UUID: [String]], teeBox: TeeBox) -> Double {
        guard let team1Player1Scores = playerScores[team1Player1.id],
              let team1Player2Scores = playerScores[team1Player2.id],
              let team2Player1Scores = playerScores[team2Player1.id],
              let team2Player2Scores = playerScores[team2Player2.id] else {
            return 0
        }
        
        var totalWinnings = 0.0
        
        // Calculate hole-by-hole winnings
        for holeIndex in 0..<18 {
            // Get valid scores for this hole
            guard let score1p1 = Int(team1Player1Scores[holeIndex]),
                  let score1p2 = Int(team1Player2Scores[holeIndex]),
                  let score2p1 = Int(team2Player1Scores[holeIndex]),
                  let score2p2 = Int(team2Player2Scores[holeIndex]) else {
                continue
            }
            
            // Get best score for each team
            let team1BestScore = min(score1p1, score1p2)
            let team2BestScore = min(score2p1, score2p2)
            
            // Calculate hole winner
            if team1BestScore < team2BestScore {
                totalWinnings += perHoleAmount
            } else if team2BestScore < team1BestScore {
                totalWinnings -= perHoleAmount
            }
            
            // Add birdie bonuses for team 1
            if score1p1 < teeBox.holes[holeIndex].par {
                totalWinnings += perBirdieAmount
            }
            if score1p2 < teeBox.holes[holeIndex].par {
                totalWinnings += perBirdieAmount
            }
            
            // Subtract birdie bonuses for team 2
            if score2p1 < teeBox.holes[holeIndex].par {
                totalWinnings -= perBirdieAmount
            }
            if score2p2 < teeBox.holes[holeIndex].par {
                totalWinnings -= perBirdieAmount
            }
        }
        
        return totalWinnings
    }
}

public struct AlabamaBet: Identifiable {
    public let id: UUID
    public let teams: [[Player]]
    public let swingMan: Player?
    public let countingScores: Int
    public let frontNineAmount: Double
    public let backNineAmount: Double
    public let lowBallAmount: Double
    public let perBirdieAmount: Double
    public var playerScores: [UUID: [String]]?
    public var teeBox: TeeBox?
    
    public init(teams: [[Player]], swingMan: Player? = nil, countingScores: Int, frontNineAmount: Double, backNineAmount: Double, lowBallAmount: Double, perBirdieAmount: Double) {
        self.id = UUID()
        self.teams = teams
        self.swingMan = swingMan
        self.countingScores = countingScores
        self.frontNineAmount = frontNineAmount
        self.backNineAmount = backNineAmount
        self.lowBallAmount = lowBallAmount
        self.perBirdieAmount = perBirdieAmount
    }
}

public struct DoDaBet: Identifiable {
    public let id: UUID
    public let isPool: Bool
    public let amount: Double
    public let players: [Player]
    public var playerScores: [UUID: [String]]?
    public var teeBox: TeeBox?
    
    public init(id: UUID, isPool: Bool, amount: Double, players: [Player]) {
        self.id = id
        self.isPool = isPool
        self.amount = amount
        self.players = players
    }
}

public struct SkinsBet: Identifiable {
    public let id: UUID
    public let amount: Double
    public let players: [Player]
    public var playerScores: [UUID: [String]]?
    public var teeBox: TeeBox?
    
    public init(id: UUID, amount: Double, players: [Player]) {
        self.id = id
        self.amount = amount
        self.players = players
    }
    
    public func calculateWinnings(playerScores: [UUID: [String]], teeBox: TeeBox) -> [UUID: Double] {
        var winnings: [UUID: Double] = Dictionary(uniqueKeysWithValues: players.map { ($0.id, 0.0) })
        var skinsWon: [UUID: Int] = Dictionary(uniqueKeysWithValues: players.map { ($0.id, 0) })
        
        for holeIndex in 0..<18 {
            let scores = players.compactMap { player -> (UUID, Int)? in
                guard let scoreStr = playerScores[player.id]?[holeIndex],
                      let score = Int(scoreStr) else { return nil }
                return (player.id, score)
            }
            guard scores.count == players.count else { continue }
            
            let lowestScore = scores.min { $0.1 < $1.1 }?.1
            let playersWithLowest = scores.filter { $0.1 == lowestScore }
            
            if playersWithLowest.count == 1 {
                skinsWon[playersWithLowest[0].0, default: 0] += 1
            }
        }
        
        let totalSkins = skinsWon.values.reduce(0, +)
        if totalSkins > 0 {
            let potPerSkin = Double(players.count) * amount / Double(totalSkins)
            for (playerId, skins) in skinsWon {
                winnings[playerId] = Double(skins) * potPerSkin
            }
        }
        
        return winnings
    }
}

public struct AcesBet: Identifiable {
    public let id: UUID
    public let amount: Double
    public let players: [Player]
    public var playerScores: [UUID: [String]]?
    public var teeBox: TeeBox?
    
    public init(id: UUID, amount: Double, players: [Player]) {
        self.id = id
        self.amount = amount
        self.players = players
    }
} 