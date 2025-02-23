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