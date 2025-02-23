import Foundation
import SwiftUI
import CoreLocation
import BetComponents

// Bet management and calculation
class BetManager: ObservableObject {
    @Published var individualBets: [IndividualMatchBet] = []
    @Published var fourBallBets: [FourBallMatchBet] = []
    @Published var alabamaBets: [AlabamaBet] = []
    @Published var doDaBets: [DoDaBet] = []
    @Published var skinsBets: [SkinsBet] = []
    
    func deleteIndividualBet(_ bet: IndividualMatchBet) {
        individualBets.removeAll { $0.id == bet.id }
    }
    
    func deleteFourBallBet(_ bet: FourBallMatchBet) {
        fourBallBets.removeAll { $0.id == bet.id }
    }
    
    func deleteAlabamaBet(_ bet: AlabamaBet) {
        alabamaBets.removeAll { $0.id == bet.id }
    }
    
    func deleteDoDaBet(_ bet: DoDaBet) {
        doDaBets.removeAll { $0.id == bet.id }
    }
    
    func deleteSkinsBet(_ bet: SkinsBet) {
        skinsBets.removeAll { $0.id == bet.id }
    }
    
    func addIndividualBet(player1: Player, player2: Player, perHoleAmount: Double, perBirdieAmount: Double, pressOn9and18: Bool) {
        let bet = IndividualMatchBet(
            id: UUID(),
            player1: player1,
            player2: player2,
            perHoleAmount: perHoleAmount,
            perBirdieAmount: perBirdieAmount,
            pressOn9and18: pressOn9and18
        )
        individualBets.append(bet)
    }
    
    func addFourBallBet(team1Player1: Player, team1Player2: Player, team2Player1: Player, team2Player2: Player, perHoleAmount: Double, perBirdieAmount: Double, pressOn9and18: Bool) {
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
    }
    
    func addAlabamaBet(teams: [[Player]], swingMan: Player? = nil, countingScores: Int, frontNineAmount: Double, backNineAmount: Double, lowBallAmount: Double, perBirdieAmount: Double) {
        let bet = AlabamaBet(teams: teams, swingMan: swingMan, countingScores: countingScores, frontNineAmount: frontNineAmount, backNineAmount: backNineAmount, lowBallAmount: lowBallAmount, perBirdieAmount: perBirdieAmount)
        alabamaBets.append(bet)
    }
    
    func addDoDaBet(isPool: Bool, amount: Double, players: [Player]) {
        let bet = DoDaBet(
            id: UUID(),
            isPool: isPool,
            amount: amount,
            players: players
        )
        doDaBets.append(bet)
    }
    
    func addSkinsBet(amount: Double, players: [Player]) {
        let bet = SkinsBet(
            id: UUID(),
            amount: amount,
            players: players
        )
        skinsBets.append(bet)
    }
    
    // For real-time round view (excludes Alabama bets)
    func calculateRoundWinnings(player: Player, playerScores: [UUID: [String]], teeBox: TeeBox) -> Double {
        var totalWinnings = 0.0
        
        // Calculate individual match winnings
        for bet in individualBets {
            if bet.player1.id == player.id || bet.player2.id == player.id {
                let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
                totalWinnings += bet.player1.id == player.id ? winnings : -winnings
            }
        }
        
        // Calculate four ball match winnings
        for bet in fourBallBets {
            if bet.team1Player1.id == player.id || 
               bet.team1Player2.id == player.id || 
               bet.team2Player1.id == player.id || 
               bet.team2Player2.id == player.id {
                let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)
                totalWinnings += (bet.team1Player1.id == player.id || bet.team1Player2.id == player.id) ? winnings : -winnings
            }
        }
        
        return totalWinnings
    }
    
    // For "THE SHEET" view (includes all bets including Alabama)
    func calculateTotalWinnings(player: Player, playerScores: [UUID: [String]], teeBox: TeeBox) -> Double {
        print("=== CALCULATING TOTAL WINNINGS ===")
        print("Player: \(player.firstName)")
        print("Number of skins bets: \(skinsBets.count)")
        
        var totalWinnings = calculateRoundWinnings(player: player, playerScores: playerScores, teeBox: teeBox)
        print("Base round winnings: \(totalWinnings)")
        
        // Add Alabama bet winnings
        for bet in alabamaBets {
            if let scores = bet.playerScores,
               let teeBox = bet.teeBox {
                let winnings = bet.calculateWinnings(playerScores: scores, teeBox: teeBox)
                if let playerWinnings = winnings[player.id] {
                    totalWinnings += playerWinnings
                }
            }
        }
        
        // Add Do-Da bet winnings
        for bet in doDaBets {
            if let scores = bet.playerScores,
               let teeBox = bet.teeBox {
                let winnings = bet.calculateWinnings(playerScores: scores, teeBox: teeBox)
                if let playerWinnings = winnings[player.id] {
                    totalWinnings += playerWinnings
                }
            }
        }
        
        // Add Skins bet winnings
        for bet in skinsBets {
            print("Processing skins bet: \(bet.id)")
            print("Players in bet: \(bet.players.map { $0.firstName }.joined(separator: ", "))")
            print("Has playerScores: \(bet.playerScores != nil)")
            print("Has teeBox: \(bet.teeBox != nil)")
            
            if let scores = bet.playerScores,
               let teeBox = bet.teeBox {
                let winnings = bet.calculateWinnings(playerScores: scores, teeBox: teeBox)
                print("Calculated winnings: \(winnings)")
                if let playerWinnings = winnings[player.id] {
                    print("Player \(player.firstName)'s winnings: \(playerWinnings)")
                    totalWinnings += playerWinnings
                } else {
                    print("No winnings found for player \(player.firstName)")
                }
            } else {
                print("Skipping bet calculation - missing scores or teeBox")
            }
        }
        
        print("Final total winnings: \(totalWinnings)")
        return totalWinnings
    }
}

struct IndividualMatchBet: Identifiable {
    let id: UUID
    let player1: Player
    let player2: Player
    let perHoleAmount: Double
    let perBirdieAmount: Double
    let pressOn9and18: Bool
    var playerScores: [UUID: [String]]?
    var teeBox: TeeBox?
    
    func calculateWinnings(playerScores: [UUID: [String]], teeBox: TeeBox) -> Double {
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

struct FourBallMatchBet: Identifiable {
    let id: UUID
    let team1Player1: Player
    let team1Player2: Player
    let team2Player1: Player
    let team2Player2: Player
    let perHoleAmount: Double
    let perBirdieAmount: Double
    let pressOn9and18: Bool
    var playerScores: [UUID: [String]]?
    var teeBox: TeeBox?
    
    func calculateWinnings(playerScores: [UUID: [String]], teeBox: TeeBox) -> Double {
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

struct AlabamaBet: Identifiable {
    let id: UUID
    let teams: [[Player]]
    let swingMan: Player?  // Optional swing man player
    let countingScores: Int
    let frontNineAmount: Double
    let backNineAmount: Double
    let lowBallAmount: Double
    let perBirdieAmount: Double
    var playerScores: [UUID: [String]]?
    var teeBox: TeeBox?
    
    init(teams: [[Player]], swingMan: Player? = nil, countingScores: Int, frontNineAmount: Double, backNineAmount: Double, lowBallAmount: Double, perBirdieAmount: Double) {
        self.id = UUID()
        self.teams = teams
        self.swingMan = swingMan
        self.countingScores = countingScores
        self.frontNineAmount = frontNineAmount
        self.backNineAmount = backNineAmount
        self.lowBallAmount = lowBallAmount
        self.perBirdieAmount = perBirdieAmount
    }
    
    func calculateWinnings(playerScores: [UUID: [String]], teeBox: TeeBox) -> [UUID: Double] {
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
                if let swingMan = swingMan,
                   let scoreStr = scores[swingMan.id]?[holeIndex],
                   let score = Int(String(scoreStr)) {
                    teamScores.append(score)
                    // Count swing man birdies
                    if score < par {
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
                
                // Front Nine Alabama
                if frontNineTeamTotals[teamIndex] < frontNineTeamTotals[otherTeamIndex] {
                    teamWinnings += frontNineAmount
                } else if frontNineTeamTotals[teamIndex] > frontNineTeamTotals[otherTeamIndex] {
                    teamWinnings -= frontNineAmount
                }
                
                // Back Nine Alabama
                if backNineTeamTotals[teamIndex] < backNineTeamTotals[otherTeamIndex] {
                    teamWinnings += backNineAmount
                } else if backNineTeamTotals[teamIndex] > backNineTeamTotals[otherTeamIndex] {
                    teamWinnings -= backNineAmount
                }
                
                // Front Nine Low Ball
                if frontNineLowBallTotals[teamIndex] < frontNineLowBallTotals[otherTeamIndex] {
                    teamWinnings += lowBallAmount
                } else if frontNineLowBallTotals[teamIndex] > frontNineLowBallTotals[otherTeamIndex] {
                    teamWinnings -= lowBallAmount
                }
                
                // Back Nine Low Ball
                if backNineLowBallTotals[teamIndex] < backNineLowBallTotals[otherTeamIndex] {
                    teamWinnings += lowBallAmount
                } else if backNineLowBallTotals[teamIndex] > backNineLowBallTotals[otherTeamIndex] {
                    teamWinnings -= lowBallAmount
                }
                
                // Birdie differential
                let birdieDiff = teamBirdies[teamIndex] - teamBirdies[otherTeamIndex]
                teamWinnings += Double(birdieDiff) * perBirdieAmount
            }
            
            // Each player gets the full amount (no division)
            for player in team {
                winnings[player.id, default: 0] += teamWinnings
            }
            if let swingMan = swingMan {
                winnings[swingMan.id, default: 0] += teamWinnings
            }
        }
        
        return winnings
    }
}

struct DoDaBet: Identifiable {
    let id: UUID
    let isPool: Bool
    let amount: Double
    let players: [Player]
    var playerScores: [UUID: [String]]?
    var teeBox: TeeBox?
    
    func calculateWinnings(playerScores: [UUID: [String]], teeBox: TeeBox) -> [UUID: Double] {
        let scores = self.playerScores ?? playerScores
        var winnings: [UUID: Double] = [:]
        
        // Only include players who have scores (were part of the round)
        let activePlayers = players.filter { scores.keys.contains($0.id) }
        
        // Initialize active players with zero winnings
        for player in activePlayers {
            winnings[player.id] = 0
        }
        
        // Count Do-Das (twos) for each player
        var playerDoDas: [UUID: Int] = [:]
        var totalDoDas = 0
        
        for player in activePlayers {
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
            let totalPool = amount * Double(activePlayers.count)
            
            // First, everyone loses their pool entry amount
            for player in activePlayers {
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
            // Per Do-Da calculation using the specified logic:
            // 1. Calculate total Do-Das (N) - already done in totalDoDas
            // 2. Calculate total amount per Do-Da (TOT$)
            let totalPerDoDa = amount * Double(totalDoDas)
            // 3. Calculate total pooled amount (TDDP$)
            let totalPooledAmount = totalPerDoDa * Double(activePlayers.count)
            // 4. Calculate worth of each Do-Da (TDDW$)
            let worthPerDoDa = totalDoDas > 0 ? totalPooledAmount / Double(totalDoDas) : 0
            
            // First, everyone pays for all Do-Das
            for player in activePlayers {
                winnings[player.id] = -totalPerDoDa
            }
            
            // Then, players get paid for their Do-Das
            for (playerId, doDaCount) in playerDoDas {
                if doDaCount > 0 {
                    winnings[playerId, default: 0] += worthPerDoDa * Double(doDaCount)
                }
            }
        }
        
        return winnings
    }
}

struct SkinsBet: Identifiable {
    let id: UUID
    let amount: Double
    let players: [Player]
    var playerScores: [UUID: [String]]?
    var teeBox: TeeBox?
    
    func calculateWinnings(playerScores: [UUID: [String]], teeBox: TeeBox) -> [UUID: Double] {
        let scores = self.playerScores ?? playerScores
        var winnings: [UUID: Double] = [:]
        
        // Only include players who have scores (were part of the round)
        let activePlayers = players.filter { scores.keys.contains($0.id) }
        
        // Initialize all active players with their entry amount loss
        for player in activePlayers {
            winnings[player.id] = -amount
        }
        
        // Calculate total pool
        let totalPool = amount * Double(activePlayers.count)
        
        // Track skins won per player
        var skinsWon: [UUID: Int] = [:]
        
        // For each hole
        for holeIndex in 0..<18 {
            // Get valid scores for this hole
            var holeScores: [(playerId: UUID, score: Int)] = []
            for player in activePlayers {
                if let playerScores = scores[player.id],
                   holeIndex < playerScores.count,
                   let score = Int(playerScores[holeIndex]) {
                    holeScores.append((player.id, score))
                }
            }
            
            // Skip hole if not all players have scores
            guard holeScores.count == activePlayers.count else { continue }
            
            // Find lowest score for the hole
            let lowestScore = holeScores.min { $0.score < $1.score }?.score
            guard let lowestScore = lowestScore else { continue }
            
            // Count how many players have the lowest score
            let playersWithLowestScore = holeScores.filter { $0.score == lowestScore }
            
            // If only one player has the lowest score, they win a skin
            if playersWithLowestScore.count == 1 {
                let winnerId = playersWithLowestScore[0].playerId
                skinsWon[winnerId, default: 0] += 1
            }
        }
        
        // Calculate total skins won
        let totalSkinsWon = skinsWon.values.reduce(0, +)
        
        // If any skins were won, distribute the pool
        if totalSkinsWon > 0 {
            let valuePerSkin = totalPool / Double(totalSkinsWon)
            
            // Add winnings for skins won
            for (playerId, skins) in skinsWon {
                winnings[playerId, default: 0] += valuePerSkin * Double(skins)
            }
        }
        
        return winnings
    }
} 
