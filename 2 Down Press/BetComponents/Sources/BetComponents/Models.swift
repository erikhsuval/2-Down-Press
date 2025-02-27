import Foundation
import SwiftUI

public struct Player: Identifiable, Hashable, Codable {
    public let id: UUID
    public var firstName: String
    public var lastName: String
    public var email: String
    public var nickname: String?
    
    public var scorecardName: String {
        if let nickname = nickname {
            return "\"" + nickname + "\""
        }
        return firstName.uppercased()
    }
    
    public init(id: UUID = UUID(), firstName: String, lastName: String, email: String, nickname: String? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.nickname = nickname
    }
    
    public static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct HoleInfo: Identifiable {
    public let id: UUID
    public let number: Int
    public let par: Int
    public let yardage: Int
    public let handicap: Int
    
    public init(id: UUID = UUID(), number: Int, par: Int, yardage: Int, handicap: Int) {
        self.id = id
        self.number = number
        self.par = par
        self.yardage = yardage
        self.handicap = handicap
    }
}

public enum TeeBox: String, CaseIterable {
    case championship = "Championship"
    case black = "Black"
    case blackBlue = "Black/Blue"
    case blue = "Blue"
    case blueGold = "Blue/Gold"
    case gold = "Gold"
    case white = "White"
    case green = "Green"
    
    public var color: String {
        switch self {
        case .championship: return "Championship"
        case .black: return "Black"
        case .blackBlue: return "Black/Blue"
        case .blue: return "Blue"
        case .blueGold: return "Blue/Gold"
        case .gold: return "Gold"
        case .white: return "White"
        case .green: return "Green"
        }
    }

    public var name: String { rawValue }
    
    public var holes: [HoleInfo] {
        switch self {
        case .championship:
            return Self.championshipHoles
        case .black:
            return Self.blackHoles
        case .blackBlue:
            return Self.blackBlueHoles
        case .blue:
            return Self.blueHoles
        case .blueGold:
            return Self.blueGoldHoles
        case .gold:
            return Self.goldHoles
        case .white:
            return Self.whiteHoles
        case .green:
            return Self.greenHoles
        }
    }
    
    // Championship tee holes data
    private static let championshipHoles: [HoleInfo] = [
        HoleInfo(number: 1, par: 4, yardage: 376, handicap: 7),
        HoleInfo(number: 2, par: 4, yardage: 388, handicap: 3),
        HoleInfo(number: 3, par: 5, yardage: 554, handicap: 11),
        HoleInfo(number: 4, par: 3, yardage: 200, handicap: 1),
        HoleInfo(number: 5, par: 4, yardage: 416, handicap: 9),
        HoleInfo(number: 6, par: 5, yardage: 544, handicap: 17),
        HoleInfo(number: 7, par: 4, yardage: 406, handicap: 13),
        HoleInfo(number: 8, par: 4, yardage: 458, handicap: 5),
        HoleInfo(number: 9, par: 3, yardage: 174, handicap: 15),
        HoleInfo(number: 10, par: 4, yardage: 415, handicap: 6),
        HoleInfo(number: 11, par: 4, yardage: 414, handicap: 8),
        HoleInfo(number: 12, par: 4, yardage: 390, handicap: 14),
        HoleInfo(number: 13, par: 4, yardage: 434, handicap: 4),
        HoleInfo(number: 14, par: 5, yardage: 597, handicap: 10),
        HoleInfo(number: 15, par: 3, yardage: 129, handicap: 16),
        HoleInfo(number: 16, par: 5, yardage: 553, handicap: 18),
        HoleInfo(number: 17, par: 3, yardage: 208, handicap: 12),
        HoleInfo(number: 18, par: 4, yardage: 436, handicap: 2)
    ]
    
    // Black tee holes data
    private static let blackHoles: [HoleInfo] = [
        HoleInfo(number: 1, par: 4, yardage: 376, handicap: 7),
        HoleInfo(number: 2, par: 4, yardage: 388, handicap: 3),
        HoleInfo(number: 3, par: 5, yardage: 517, handicap: 11),
        HoleInfo(number: 4, par: 3, yardage: 200, handicap: 1),
        HoleInfo(number: 5, par: 4, yardage: 377, handicap: 9),
        HoleInfo(number: 6, par: 5, yardage: 544, handicap: 17),
        HoleInfo(number: 7, par: 4, yardage: 406, handicap: 13),
        HoleInfo(number: 8, par: 4, yardage: 416, handicap: 5),
        HoleInfo(number: 9, par: 3, yardage: 174, handicap: 15),
        HoleInfo(number: 10, par: 4, yardage: 415, handicap: 6),
        HoleInfo(number: 11, par: 4, yardage: 414, handicap: 8),
        HoleInfo(number: 12, par: 4, yardage: 390, handicap: 14),
        HoleInfo(number: 13, par: 4, yardage: 406, handicap: 4),
        HoleInfo(number: 14, par: 5, yardage: 563, handicap: 10),
        HoleInfo(number: 15, par: 3, yardage: 123, handicap: 16),
        HoleInfo(number: 16, par: 5, yardage: 553, handicap: 18),
        HoleInfo(number: 17, par: 3, yardage: 208, handicap: 12),
        HoleInfo(number: 18, par: 4, yardage: 436, handicap: 2)
    ]
    
    // Black/Blue tee holes data
    private static let blackBlueHoles: [HoleInfo] = [
        HoleInfo(number: 1, par: 4, yardage: 376, handicap: 7),
        HoleInfo(number: 2, par: 4, yardage: 388, handicap: 3),
        HoleInfo(number: 3, par: 5, yardage: 497, handicap: 11),
        HoleInfo(number: 4, par: 3, yardage: 174, handicap: 1),
        HoleInfo(number: 5, par: 4, yardage: 360, handicap: 9),
        HoleInfo(number: 6, par: 5, yardage: 544, handicap: 17),
        HoleInfo(number: 7, par: 4, yardage: 406, handicap: 13),
        HoleInfo(number: 8, par: 4, yardage: 378, handicap: 5),
        HoleInfo(number: 9, par: 3, yardage: 174, handicap: 15),
        HoleInfo(number: 10, par: 4, yardage: 394, handicap: 6),
        HoleInfo(number: 11, par: 4, yardage: 414, handicap: 8),
        HoleInfo(number: 12, par: 4, yardage: 350, handicap: 14),
        HoleInfo(number: 13, par: 4, yardage: 392, handicap: 4),
        HoleInfo(number: 14, par: 5, yardage: 524, handicap: 10),
        HoleInfo(number: 15, par: 3, yardage: 123, handicap: 16),
        HoleInfo(number: 16, par: 5, yardage: 553, handicap: 18),
        HoleInfo(number: 17, par: 3, yardage: 175, handicap: 12),
        HoleInfo(number: 18, par: 4, yardage: 408, handicap: 2)
    ]
    
    // Blue tee holes data
    private static let blueHoles: [HoleInfo] = [
        HoleInfo(number: 1, par: 4, yardage: 359, handicap: 7),
        HoleInfo(number: 2, par: 4, yardage: 366, handicap: 3),
        HoleInfo(number: 3, par: 5, yardage: 497, handicap: 11),
        HoleInfo(number: 4, par: 3, yardage: 174, handicap: 1),
        HoleInfo(number: 5, par: 4, yardage: 360, handicap: 9),
        HoleInfo(number: 6, par: 5, yardage: 499, handicap: 17),
        HoleInfo(number: 7, par: 4, yardage: 369, handicap: 13),
        HoleInfo(number: 8, par: 4, yardage: 378, handicap: 5),
        HoleInfo(number: 9, par: 3, yardage: 155, handicap: 15),
        HoleInfo(number: 10, par: 4, yardage: 394, handicap: 6),
        HoleInfo(number: 11, par: 4, yardage: 396, handicap: 8),
        HoleInfo(number: 12, par: 4, yardage: 350, handicap: 14),
        HoleInfo(number: 13, par: 4, yardage: 392, handicap: 4),
        HoleInfo(number: 14, par: 5, yardage: 524, handicap: 10),
        HoleInfo(number: 15, par: 3, yardage: 109, handicap: 16),
        HoleInfo(number: 16, par: 5, yardage: 522, handicap: 18),
        HoleInfo(number: 17, par: 3, yardage: 175, handicap: 12),
        HoleInfo(number: 18, par: 4, yardage: 408, handicap: 2)
    ]
    
    // Blue/Gold tee holes data
    private static let blueGoldHoles: [HoleInfo] = [
        HoleInfo(number: 1, par: 4, yardage: 343, handicap: 7),
        HoleInfo(number: 2, par: 4, yardage: 354, handicap: 3),
        HoleInfo(number: 3, par: 5, yardage: 482, handicap: 11),
        HoleInfo(number: 4, par: 3, yardage: 174, handicap: 1),
        HoleInfo(number: 5, par: 4, yardage: 316, handicap: 9),
        HoleInfo(number: 6, par: 5, yardage: 499, handicap: 17),
        HoleInfo(number: 7, par: 4, yardage: 346, handicap: 13),
        HoleInfo(number: 8, par: 4, yardage: 342, handicap: 5),
        HoleInfo(number: 9, par: 3, yardage: 155, handicap: 15),
        HoleInfo(number: 10, par: 4, yardage: 394, handicap: 6),
        HoleInfo(number: 11, par: 4, yardage: 327, handicap: 8),
        HoleInfo(number: 12, par: 4, yardage: 339, handicap: 14),
        HoleInfo(number: 13, par: 4, yardage: 327, handicap: 4),
        HoleInfo(number: 14, par: 5, yardage: 475, handicap: 10),
        HoleInfo(number: 15, par: 3, yardage: 109, handicap: 16),
        HoleInfo(number: 16, par: 5, yardage: 480, handicap: 18),
        HoleInfo(number: 17, par: 3, yardage: 175, handicap: 12),
        HoleInfo(number: 18, par: 4, yardage: 349, handicap: 2)
    ]
    
    // Gold tee holes data
    private static let goldHoles: [HoleInfo] = [
        HoleInfo(number: 1, par: 4, yardage: 343, handicap: 7),
        HoleInfo(number: 2, par: 4, yardage: 354, handicap: 3),
        HoleInfo(number: 3, par: 5, yardage: 482, handicap: 11),
        HoleInfo(number: 4, par: 3, yardage: 136, handicap: 1),
        HoleInfo(number: 5, par: 4, yardage: 316, handicap: 9),
        HoleInfo(number: 6, par: 5, yardage: 467, handicap: 17),
        HoleInfo(number: 7, par: 4, yardage: 346, handicap: 13),
        HoleInfo(number: 8, par: 4, yardage: 342, handicap: 5),
        HoleInfo(number: 9, par: 3, yardage: 145, handicap: 15),
        HoleInfo(number: 10, par: 4, yardage: 358, handicap: 6),
        HoleInfo(number: 11, par: 4, yardage: 327, handicap: 8),
        HoleInfo(number: 12, par: 4, yardage: 339, handicap: 14),
        HoleInfo(number: 13, par: 4, yardage: 327, handicap: 4),
        HoleInfo(number: 14, par: 5, yardage: 475, handicap: 10),
        HoleInfo(number: 15, par: 3, yardage: 101, handicap: 16),
        HoleInfo(number: 16, par: 5, yardage: 480, handicap: 18),
        HoleInfo(number: 17, par: 3, yardage: 141, handicap: 12),
        HoleInfo(number: 18, par: 4, yardage: 349, handicap: 2)
    ]
    
    // White tee holes data
    private static let whiteHoles: [HoleInfo] = [
        HoleInfo(number: 1, par: 4, yardage: 318, handicap: 7),
        HoleInfo(number: 2, par: 4, yardage: 321, handicap: 3),
        HoleInfo(number: 3, par: 5, yardage: 430, handicap: 11),
        HoleInfo(number: 4, par: 3, yardage: 129, handicap: 1),
        HoleInfo(number: 5, par: 4, yardage: 283, handicap: 9),
        HoleInfo(number: 6, par: 5, yardage: 436, handicap: 17),
        HoleInfo(number: 7, par: 4, yardage: 315, handicap: 13),
        HoleInfo(number: 8, par: 4, yardage: 336, handicap: 5),
        HoleInfo(number: 9, par: 3, yardage: 100, handicap: 15),
        HoleInfo(number: 10, par: 4, yardage: 353, handicap: 6),
        HoleInfo(number: 11, par: 4, yardage: 301, handicap: 8),
        HoleInfo(number: 12, par: 4, yardage: 309, handicap: 14),
        HoleInfo(number: 13, par: 4, yardage: 286, handicap: 4),
        HoleInfo(number: 14, par: 5, yardage: 470, handicap: 10),
        HoleInfo(number: 15, par: 3, yardage: 73, handicap: 16),
        HoleInfo(number: 16, par: 5, yardage: 445, handicap: 18),
        HoleInfo(number: 17, par: 3, yardage: 116, handicap: 12),
        HoleInfo(number: 18, par: 4, yardage: 316, handicap: 2)
    ]
    
    // Green tee holes data
    private static let greenHoles: [HoleInfo] = [
        HoleInfo(number: 1, par: 4, yardage: 262, handicap: 7),
        HoleInfo(number: 2, par: 4, yardage: 255, handicap: 3),
        HoleInfo(number: 3, par: 5, yardage: 364, handicap: 11),
        HoleInfo(number: 4, par: 3, yardage: 129, handicap: 1),
        HoleInfo(number: 5, par: 4, yardage: 229, handicap: 9),
        HoleInfo(number: 6, par: 5, yardage: 376, handicap: 17),
        HoleInfo(number: 7, par: 4, yardage: 250, handicap: 13),
        HoleInfo(number: 8, par: 4, yardage: 259, handicap: 5),
        HoleInfo(number: 9, par: 3, yardage: 100, handicap: 15),
        HoleInfo(number: 10, par: 4, yardage: 282, handicap: 6),
        HoleInfo(number: 11, par: 4, yardage: 259, handicap: 8),
        HoleInfo(number: 12, par: 4, yardage: 223, handicap: 14),
        HoleInfo(number: 13, par: 4, yardage: 220, handicap: 4),
        HoleInfo(number: 14, par: 5, yardage: 394, handicap: 10),
        HoleInfo(number: 15, par: 3, yardage: 73, handicap: 16),
        HoleInfo(number: 16, par: 5, yardage: 360, handicap: 18),
        HoleInfo(number: 17, par: 3, yardage: 116, handicap: 12),
        HoleInfo(number: 18, par: 4, yardage: 268, handicap: 2)
    ]
}

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
        let scores = self.playerScores ?? playerScores
        let teeBoxToUse = self.teeBox ?? teeBox
        
        let player1Scores = scores[player1.id] ?? Array(repeating: "", count: 18)
        let player2Scores = scores[player2.id] ?? Array(repeating: "", count: 18)
        
        var frontNineWinnings = 0.0
        var backNineWinnings = 0.0
        var frontNineBirdies1 = 0
        var frontNineBirdies2 = 0
        var backNineBirdies1 = 0
        var backNineBirdies2 = 0
        
        // Calculate front nine results through hole 8
        for holeIndex in 0..<8 {
            guard let score1 = Int(player1Scores[holeIndex]),
                  let score2 = Int(player2Scores[holeIndex]) else {
                continue
            }
            
            // Calculate hole winner
            let holeDiff = score1 - score2
            let holeWinnings = holeDiff < 0 ? perHoleAmount : (holeDiff > 0 ? -perHoleAmount : 0)
            frontNineWinnings += holeWinnings
            
            // Count birdies
            let par = teeBoxToUse.holes[holeIndex].par
            if score1 < par { frontNineBirdies1 += 1 }
            if score2 < par { frontNineBirdies2 += 1 }
        }
        
        // Calculate front nine birdie differential through hole 8
        let frontNineBirdieDiff = frontNineBirdies1 - frontNineBirdies2
        let frontNineBirdieWinnings = Double(frontNineBirdieDiff) * perBirdieAmount
        let frontNineTotalThrough8 = frontNineWinnings + frontNineBirdieWinnings
        
        // Handle hole 9 press if applicable
        var finalFrontNineTotal = frontNineTotalThrough8
        if pressOn9and18,
           let score1 = Int(player1Scores[8]),
           let score2 = Int(player2Scores[8]) {
            let hole9Diff = score1 - score2
            if hole9Diff < 0 { // Player 1 wins hole 9
                finalFrontNineTotal = frontNineTotalThrough8 * 2
            } else if hole9Diff > 0 { // Player 2 wins hole 9
                finalFrontNineTotal = 0
            }
            // If tied, keep original total
        }
        
        // Calculate back nine results through hole 17
        for holeIndex in 9..<17 {
            guard let score1 = Int(player1Scores[holeIndex]),
                  let score2 = Int(player2Scores[holeIndex]) else {
                continue
            }
            
            let holeDiff = score1 - score2
            let holeWinnings = holeDiff < 0 ? perHoleAmount : (holeDiff > 0 ? -perHoleAmount : 0)
            backNineWinnings += holeWinnings
            
            let par = teeBoxToUse.holes[holeIndex].par
            if score1 < par { backNineBirdies1 += 1 }
            if score2 < par { backNineBirdies2 += 1 }
        }
        
        // Calculate back nine birdie differential through hole 17
        let backNineBirdieDiff = backNineBirdies1 - backNineBirdies2
        let backNineBirdieWinnings = Double(backNineBirdieDiff) * perBirdieAmount
        let backNineTotalThrough17 = backNineWinnings + backNineBirdieWinnings
        
        // Handle hole 18 press if applicable
        var finalBackNineTotal = backNineTotalThrough17
        if pressOn9and18,
           let score1 = Int(player1Scores[17]),
           let score2 = Int(player2Scores[17]) {
            let hole18Diff = score1 - score2
            if hole18Diff < 0 { // Player 1 wins hole 18
                finalBackNineTotal = backNineTotalThrough17 * 2
            } else if hole18Diff > 0 { // Player 2 wins hole 18
                finalBackNineTotal = 0
            }
            // If tied, keep original total
        }
        
        return finalFrontNineTotal + finalBackNineTotal
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
        let scores = self.playerScores ?? playerScores
        let teeBoxToUse = self.teeBox ?? teeBox
        
        let team1Player1Scores = scores[team1Player1.id] ?? Array(repeating: "", count: 18)
        let team1Player2Scores = scores[team1Player2.id] ?? Array(repeating: "", count: 18)
        let team2Player1Scores = scores[team2Player1.id] ?? Array(repeating: "", count: 18)
        let team2Player2Scores = scores[team2Player2.id] ?? Array(repeating: "", count: 18)
        
        var totalWinnings = 0.0
        var frontNineWinnings = 0.0
        var backNineWinnings = 0.0
        var birdiesTeam1 = 0
        var birdiesTeam2 = 0
        
        // Calculate hole-by-hole results
        for holeIndex in 0..<18 {
            // Get valid scores for each team
            let team1Scores = [
                Int(team1Player1Scores[holeIndex]),
                Int(team1Player2Scores[holeIndex])
            ].compactMap { $0 }
            
            let team2Scores = [
                Int(team2Player1Scores[holeIndex]),
                Int(team2Player2Scores[holeIndex])
            ].compactMap { $0 }
            
            // Skip hole if either team is missing scores
            guard !team1Scores.isEmpty && !team2Scores.isEmpty else { continue }
            
            // Get best score for each team
            let team1Best = team1Scores.min() ?? 0
            let team2Best = team2Scores.min() ?? 0
            
            // Calculate hole winner
            let holeDiff = team1Best - team2Best
            let holeWinnings = holeDiff < 0 ? perHoleAmount : (holeDiff > 0 ? -perHoleAmount : 0)
            
            // Add to appropriate nine
            if holeIndex < 9 {
                frontNineWinnings += holeWinnings
            } else {
                backNineWinnings += holeWinnings
            }
            
            // Count birdies
            let par = teeBoxToUse.holes[holeIndex].par
            if team1Best < par { birdiesTeam1 += 1 }
            if team2Best < par { birdiesTeam2 += 1 }
        }
        
        // Add front nine winnings
        totalWinnings += frontNineWinnings
        
        // If press is on and front nine is complete, start back nine fresh
        if pressOn9and18 && frontNineWinnings != 0 {
            totalWinnings += backNineWinnings
        } else {
            totalWinnings += backNineWinnings
        }
        
        // Calculate birdie winnings
        let birdieDiff = birdiesTeam1 - birdiesTeam2
        let birdieWinnings = Double(birdieDiff) * perBirdieAmount
        
        return totalWinnings + birdieWinnings
    }
}

public struct AlabamaBet: Identifiable {
    public let id: UUID
    public let teams: [[Player]]
    public let swingMan: Player?
    public let swingManTeamIndex: Int?  // Track which team the swing man plays with
    public let countingScores: Int
    public let frontNineAmount: Double
    public let backNineAmount: Double
    public let lowBallAmount: Double
    public let perBirdieAmount: Double
    public var playerScores: [UUID: [String]]?
    public var teeBox: TeeBox?
    
    public init(teams: [[Player]], swingMan: Player? = nil, swingManTeamIndex: Int? = nil, countingScores: Int, frontNineAmount: Double, backNineAmount: Double, lowBallAmount: Double, perBirdieAmount: Double) {
        self.id = UUID()
        self.teams = teams
        self.swingMan = swingMan
        self.swingManTeamIndex = swingManTeamIndex
        self.countingScores = countingScores
        self.frontNineAmount = frontNineAmount
        self.backNineAmount = backNineAmount
        self.lowBallAmount = lowBallAmount
        self.perBirdieAmount = perBirdieAmount
    }
    
    public func calculateWinnings(playerScores: [UUID: [String]], teeBox: TeeBox) -> [UUID: Double] {
        let scores = self.playerScores ?? playerScores
        let teeBoxToUse = self.teeBox ?? teeBox
        var winnings: [UUID: Double] = [:]
        
        // Track totals for Alabama scoring (best N scores)
        var frontNineTeamTotals: [Int] = Array(repeating: 0, count: teams.count)
        var backNineTeamTotals: [Int] = Array(repeating: 0, count: teams.count)
        var frontNineLowBallTotals: [Int] = Array(repeating: 0, count: teams.count)
        var backNineLowBallTotals: [Int] = Array(repeating: 0, count: teams.count)
        var teamBirdies: [Int] = Array(repeating: 0, count: teams.count)
        
        // Calculate hole-by-hole totals
        for holeIndex in 0..<18 {
            let isFrontNine = holeIndex < 9
            let par = teeBoxToUse.holes[holeIndex].par
            
            // Get swing man's score for this hole if available
            var swingManScore: Int?
            var swingManBirdie = false
            if let swingMan = swingMan,
               let scoreStr = scores[swingMan.id]?[holeIndex],
               let score = Int(String(scoreStr)) {
                swingManScore = score
                swingManBirdie = score < par
            }
            
            // For each team
            for (teamIndex, team) in teams.enumerated() {
                // Get valid scores for this hole
                var teamScores: [Int] = []
                for player in team {
                    if let scoreStr = scores[player.id]?[holeIndex],
                       let score = Int(String(scoreStr)) {
                        teamScores.append(score)
                        // Count birdies
                        if score < par {
                            teamBirdies[teamIndex] += 1
                        }
                    }
                }
                
                // Add swing man's score if applicable
                if let swingManScore = swingManScore {
                    teamScores.append(swingManScore)
                    if swingManBirdie {
                        teamBirdies[teamIndex] += 1
                    }
                }
                
                guard !teamScores.isEmpty else { continue }
                teamScores.sort()
                
                // Alabama scoring (best N scores)
                let bestNScores = Array(teamScores.prefix(min(countingScores, teamScores.count)))
                let holeTotal = bestNScores.reduce(0, +)
                
                // Low ball (single lowest score)
                let lowBallScore = teamScores[0]
                
                if isFrontNine {
                    frontNineTeamTotals[teamIndex] += holeTotal
                    frontNineLowBallTotals[teamIndex] += lowBallScore
                } else {
                    backNineTeamTotals[teamIndex] += holeTotal
                    backNineLowBallTotals[teamIndex] += lowBallScore
                }
            }
        }
        
        // Calculate team vs team results
        for (teamIndex, team) in teams.enumerated() {
            var teamWinnings = 0.0
            
            // Compare against each other team independently
            for otherTeamIndex in 0..<teams.count {
                if teamIndex == otherTeamIndex { continue }
                
                var matchupTotal = 0.0
                
                // Front Nine Alabama
                if frontNineTeamTotals[teamIndex] < frontNineTeamTotals[otherTeamIndex] {
                    matchupTotal += frontNineAmount
                } else if frontNineTeamTotals[teamIndex] > frontNineTeamTotals[otherTeamIndex] {
                    matchupTotal -= frontNineAmount
                }
                
                // Back Nine Alabama
                if backNineTeamTotals[teamIndex] < backNineTeamTotals[otherTeamIndex] {
                    matchupTotal += backNineAmount
                } else if backNineTeamTotals[teamIndex] > backNineTeamTotals[otherTeamIndex] {
                    matchupTotal -= backNineAmount
                }
                
                // Front Nine Low Ball
                if frontNineLowBallTotals[teamIndex] < frontNineLowBallTotals[otherTeamIndex] {
                    matchupTotal += lowBallAmount
                } else if frontNineLowBallTotals[teamIndex] > frontNineLowBallTotals[otherTeamIndex] {
                    matchupTotal -= lowBallAmount
                }
                
                // Back Nine Low Ball
                if backNineLowBallTotals[teamIndex] < backNineLowBallTotals[otherTeamIndex] {
                    matchupTotal += lowBallAmount
                } else if backNineLowBallTotals[teamIndex] > backNineLowBallTotals[otherTeamIndex] {
                    matchupTotal -= lowBallAmount
                }
                
                // Birdie differential
                let birdieDiff = teamBirdies[teamIndex] - teamBirdies[otherTeamIndex]
                matchupTotal += Double(birdieDiff) * perBirdieAmount
                
                // Calculate team size ratio
                let thisTeamSize = team.count + (swingManTeamIndex == teamIndex ? 1 : 0)
                let otherTeamSize = teams[otherTeamIndex].count + (swingManTeamIndex == otherTeamIndex ? 1 : 0)
                let teamSizeRatio = Double(otherTeamSize) / Double(thisTeamSize)
                
                // Apply team size ratio to matchup total
                matchupTotal *= teamSizeRatio
                
                // Only add half of the matchup total to avoid double counting
                teamWinnings += matchupTotal / 2.0
            }
            
            // Each regular team player gets their share
            let teamSize = team.count + (swingManTeamIndex == teamIndex ? 1 : 0)
            for player in team {
                winnings[player.id, default: 0] += teamWinnings / Double(teamSize)
            }
            
            // If this is the swing man's team, they get their share
            if let swingMan = swingMan, teamIndex == swingManTeamIndex {
                winnings[swingMan.id, default: 0] += teamWinnings / Double(teamSize)
            }
        }
        
        return winnings
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
    
    public func calculateWinnings(playerScores: [UUID: [String]], teeBox: TeeBox) -> [UUID: Double] {
        let scores = self.playerScores ?? playerScores
        let teeBoxToUse = self.teeBox ?? teeBox
        var winnings: [UUID: Double] = [:]
        
        // Initialize all players with zero winnings
        for player in players {
            winnings[player.id] = 0
        }
        
        // Count Do-Das (twos) for each player
        var playerDoDas: [UUID: Int] = [:]
        var totalDoDas = 0
        
        for player in players {
            var doDaCount = 0
            if let playerScores = scores[player.id] {
                for holeIndex in 0..<18 {
                    guard holeIndex < playerScores.count else { continue }
                    let scoreStr = playerScores[holeIndex]
                    guard !scoreStr.isEmpty,
                          let score = Int(scoreStr),
                          score == 2 else { continue }
                    doDaCount += 1
                    totalDoDas += 1
                }
            }
            playerDoDas[player.id] = doDaCount
        }
        
        if isPool {
            // Pool calculation
            let totalPool = amount * Double(players.count)
            
            // First, everyone loses their pool entry amount
            for player in players {
                winnings[player.id] = -amount
            }
            
            // If there were any Do-Das made, distribute the pool
            if totalDoDas > 0 {
                let amountPerDoDa = totalPool / Double(totalDoDas)
                
                // Award winnings for each Do-Da
                for (playerId, doDaCount) in playerDoDas {
                    if doDaCount > 0 {
                        winnings[playerId, default: 0] += amountPerDoDa * Double(doDaCount)
                    }
                }
            }
        } else {
            // Per Do-Da calculation
            for (playerId, doDaCount) in playerDoDas {
                if doDaCount > 0 {
                    // Player wins amount * number of other players for each Do-Da
                    let otherPlayersCount = players.count - 1
                    winnings[playerId, default: 0] += amount * Double(doDaCount) * Double(otherPlayersCount)
                    
                    // Each other player loses amount for each Do-Da this player made
                    for otherPlayer in players where otherPlayer.id != playerId {
                        winnings[otherPlayer.id, default: 0] -= amount * Double(doDaCount)
                    }
                }
            }
        }
        
        return winnings
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
        // Initialize each player's winnings to -amount (entry fee)
        var winnings: [UUID: Double] = Dictionary(uniqueKeysWithValues: players.map { ($0.id, -amount) })
        var skinsWon: [UUID: Int] = Dictionary(uniqueKeysWithValues: players.map { ($0.id, 0) })
        
        for holeIndex in 0..<18 {
            let scores = players.compactMap { player -> (UUID, Int)? in
                let scoreStr = playerScores[player.id]?[holeIndex]
                if scoreStr == "X" {
                    return (player.id, teeBox.holes[holeIndex].par + 4)
                }
                guard let scoreStr = scoreStr,
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
                // Add skin winnings to the already initialized negative entry fee
                winnings[playerId, default: -amount] += Double(skins) * potPerSkin
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

public class BetManager: ObservableObject {
    @Published public var individualBets: [IndividualMatchBet] = []
    @Published public var fourBallBets: [FourBallMatchBet] = []
    @Published public var alabamaBets: [AlabamaBet] = []
    @Published public var doDaBets: [DoDaBet] = []
    @Published public var skinsBets: [SkinsBet] = []
    @Published public var acesBets: [AcesBet] = []
    @Published public var playerScores: [UUID: [String]] = [:]
    @Published public var teeBox: TeeBox?
    @Published public var allPlayers: [Player] = []
    
    public init() {
        updateAllPlayers()
    }
    
    public func updateAllPlayers() {
        var players = Set<Player>()
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
        }
        doDaBets.forEach { bet in
            players.formUnion(bet.players)
        }
        skinsBets.forEach { bet in
            players.formUnion(bet.players)
        }
        allPlayers = Array(players).sorted { $0.firstName < $1.firstName }
    }
    
    public func updateScoresAndTeeBox(_ scores: [UUID: [String]], _ teeBox: TeeBox) {
        self.playerScores = scores
        self.teeBox = teeBox
        
        for index in self.individualBets.indices {
            self.individualBets[index].playerScores = scores
            self.individualBets[index].teeBox = teeBox
        }
        
        for index in self.fourBallBets.indices {
            self.fourBallBets[index].playerScores = scores
            self.fourBallBets[index].teeBox = teeBox
        }
        
        for index in self.alabamaBets.indices {
            self.alabamaBets[index].playerScores = scores
            self.alabamaBets[index].teeBox = teeBox
        }
        
        for index in self.doDaBets.indices {
            self.doDaBets[index].playerScores = scores
            self.doDaBets[index].teeBox = teeBox
        }
        
        for index in self.skinsBets.indices {
            self.skinsBets[index].playerScores = scores
            self.skinsBets[index].teeBox = teeBox
        }
    }
    
    public func addAcesBet(amount: Double, players: [Player]) {
        let bet = AcesBet(
            id: UUID(),
            amount: amount,
            players: players
        )
        acesBets.append(bet)
    }
    
    public func deleteAlabamaBet(_ bet: AlabamaBet) {
        alabamaBets.removeAll { $0.id == bet.id }
        updateAllPlayers()
    }
    
    public func deleteIndividualBet(_ bet: IndividualMatchBet) {
        individualBets.removeAll { $0.id == bet.id }
        updateAllPlayers()
    }
    
    public func deleteFourBallBet(_ bet: FourBallMatchBet) {
        fourBallBets.removeAll { $0.id == bet.id }
        updateAllPlayers()
    }
    
    public func deleteSkinsBet(_ bet: SkinsBet) {
        skinsBets.removeAll { $0.id == bet.id }
        updateAllPlayers()
    }
    
    public func deleteDoDaBet(_ bet: DoDaBet) {
        doDaBets.removeAll { $0.id == bet.id }
        updateAllPlayers()
    }
    
    public func addAlabamaBet(teams: [[Player]], swingMan: Player? = nil, swingManTeamIndex: Int? = nil, countingScores: Int, frontNineAmount: Double, backNineAmount: Double, lowBallAmount: Double, perBirdieAmount: Double) {
        let bet = AlabamaBet(
            teams: teams,
            swingMan: swingMan,
            swingManTeamIndex: swingManTeamIndex,
            countingScores: countingScores,
            frontNineAmount: frontNineAmount,
            backNineAmount: backNineAmount,
            lowBallAmount: lowBallAmount,
            perBirdieAmount: perBirdieAmount
        )
        alabamaBets.append(bet)
        updateAllPlayers()
    }

    public func addDoDaBet(isPool: Bool, amount: Double, players: [Player]) {
        let bet = DoDaBet(
            id: UUID(),
            isPool: isPool,
            amount: amount,
            players: players
        )
        doDaBets.append(bet)
        updateAllPlayers()
    }

    public func addSkinsBet(amount: Double, players: [Player]) {
        let bet = SkinsBet(
            id: UUID(),
            amount: amount,
            players: players
        )
        skinsBets.append(bet)
        updateAllPlayers()
    }

    public func addFourBallBet(team1Player1: Player, team1Player2: Player, team2Player1: Player, team2Player2: Player, perHoleAmount: Double, perBirdieAmount: Double, pressOn9and18: Bool) {
        let bet = FourBallMatchBet(
            id: UUID(),
            team1Player1: team1Player1,
            team1Player2: team1Player2,
            team2Player1: team2Player1,
            team2Player2: team2Player2,
            perHoleAmount: perHoleAmount,
            perBirdieAmount: perBirdieAmount,
            pressOn9and18: pressOn9and18
        )
        fourBallBets.append(bet)
        updateAllPlayers()
    }

    public func addIndividualBet(player1: Player, player2: Player, perHoleAmount: Double, perBirdieAmount: Double, pressOn9and18: Bool) {
        let bet = IndividualMatchBet(
            id: UUID(),
            player1: player1,
            player2: player2,
            perHoleAmount: perHoleAmount,
            perBirdieAmount: perBirdieAmount,
            pressOn9and18: pressOn9and18
        )
        individualBets.append(bet)
        updateAllPlayers()
    }

    public func calculateRoundWinnings(player: Player, playerScores: [UUID: [String]], teeBox: TeeBox) -> Double {
        var totalWinnings = 0.0
        
        // Calculate individual match winnings
        for bet in individualBets where bet.player1.id == player.id || bet.player2.id == player.id {
            let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
            totalWinnings += bet.player1.id == player.id ? winnings : -winnings
        }
        
        // Calculate four ball match winnings
        for bet in fourBallBets where [bet.team1Player1.id, bet.team1Player2.id, bet.team2Player1.id, bet.team2Player2.id].contains(player.id) {
            let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
            let isTeam1 = bet.team1Player1.id == player.id || bet.team1Player2.id == player.id
            totalWinnings += isTeam1 ? winnings : -winnings
        }
        
        // Calculate skins winnings
        for bet in skinsBets where bet.players.contains(where: { $0.id == player.id }) {
            if let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
                totalWinnings += winnings
            }
        }
        
        // Calculate Do-Da winnings
        for bet in doDaBets where bet.players.contains(where: { $0.id == player.id }) {
            if let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
                totalWinnings += winnings
            }
        }
        
        return totalWinnings
    }
    
    public func calculateTotalWinnings(player: Player, playerScores: [UUID: [String]], teeBox: TeeBox) -> Double {
        var totalWinnings = calculateRoundWinnings(player: player, playerScores: playerScores, teeBox: teeBox)
        
        // Add Alabama bet winnings
        for bet in alabamaBets {
            if let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
                totalWinnings += winnings
            }
        }
        
        return totalWinnings
    }

    public func resetAllBetData() {
        // Clear all bet-related data
        playerScores = [:]
        teeBox = nil
        
        // Create new arrays with reset bets
        individualBets = individualBets.map { bet in
            IndividualMatchBet(
                id: bet.id,
                player1: bet.player1,
                player2: bet.player2,
                perHoleAmount: bet.perHoleAmount,
                perBirdieAmount: bet.perBirdieAmount,
                pressOn9and18: bet.pressOn9and18
            )
        }
        
        fourBallBets = fourBallBets.map { bet in
            FourBallMatchBet(
                id: bet.id,
                team1Player1: bet.team1Player1,
                team1Player2: bet.team1Player2,
                team2Player1: bet.team2Player1,
                team2Player2: bet.team2Player2,
                perHoleAmount: bet.perHoleAmount,
                perBirdieAmount: bet.perBirdieAmount,
                pressOn9and18: bet.pressOn9and18
            )
        }
        
        alabamaBets = alabamaBets.map { bet in
            AlabamaBet(
                teams: bet.teams,
                swingMan: bet.swingMan,
                swingManTeamIndex: bet.swingManTeamIndex,
                countingScores: bet.countingScores,
                frontNineAmount: bet.frontNineAmount,
                backNineAmount: bet.backNineAmount,
                lowBallAmount: bet.lowBallAmount,
                perBirdieAmount: bet.perBirdieAmount
            )
        }
        
        doDaBets = doDaBets.map { bet in
            DoDaBet(
                id: bet.id,
                isPool: bet.isPool,
                amount: bet.amount,
                players: bet.players
            )
        }
        
        skinsBets = skinsBets.map { bet in
            SkinsBet(
                id: bet.id,
                amount: bet.amount,
                players: bet.players
            )
        }
        
        objectWillChange.send()
    }
}

public class UserProfile: ObservableObject {
    @Published public var currentUser: Player?
    
    public init() {}
} 