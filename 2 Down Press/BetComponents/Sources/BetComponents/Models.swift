import Foundation

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

public class BetManager: ObservableObject {
    @Published public var individualBets: [IndividualMatchBet] = []
    @Published public var fourBallBets: [FourBallMatchBet] = []
    @Published public var alabamaBets: [AlabamaBet] = []
    @Published public var doDaBets: [DoDaBet] = []
    @Published public var skinsBets: [SkinsBet] = []
    @Published public var acesBets: [AcesBet] = []
    @Published public var playerScores: [UUID: [String]] = [:]
    @Published public var teeBox: TeeBox?
    
    public init() {}
    
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
    }
    
    public func deleteIndividualBet(_ bet: IndividualMatchBet) {
        individualBets.removeAll { $0.id == bet.id }
    }
    
    public func deleteFourBallBet(_ bet: FourBallMatchBet) {
        fourBallBets.removeAll { $0.id == bet.id }
    }
    
    public func deleteSkinsBet(_ bet: SkinsBet) {
        skinsBets.removeAll { $0.id == bet.id }
    }
    
    public func deleteDoDaBet(_ bet: DoDaBet) {
        doDaBets.removeAll { $0.id == bet.id }
    }
    
    public func addAlabamaBet(teams: [[Player]], countingScores: Int, frontNineAmount: Double, backNineAmount: Double, lowBallAmount: Double, perBirdieAmount: Double) {
        let bet = AlabamaBet(
            teams: teams,
            countingScores: countingScores,
            frontNineAmount: frontNineAmount,
            backNineAmount: backNineAmount,
            lowBallAmount: lowBallAmount,
            perBirdieAmount: perBirdieAmount
        )
        alabamaBets.append(bet)
    }

    public func addDoDaBet(isPool: Bool, amount: Double, players: [Player]) {
        let bet = DoDaBet(
            id: UUID(),
            isPool: isPool,
            amount: amount,
            players: players
        )
        doDaBets.append(bet)
    }

    public func addSkinsBet(amount: Double, players: [Player]) {
        let bet = SkinsBet(
            id: UUID(),
            amount: amount,
            players: players
        )
        skinsBets.append(bet)
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
    }

    public func calculateRoundWinnings(player: Player, playerScores: [UUID: [String]], teeBox: TeeBox) -> Double {
        var totalWinnings = 0.0
        
        // Calculate individual match winnings
        for bet in individualBets where bet.player1.id == player.id || bet.player2.id == player.id {
            // Add calculation logic here
        }
        
        // Calculate four ball match winnings
        for bet in fourBallBets where [bet.team1Player1.id, bet.team1Player2.id, bet.team2Player1.id, bet.team2Player2.id].contains(player.id) {
            // Add calculation logic here
        }
        
        // Calculate skins winnings
        for bet in skinsBets where bet.players.contains(where: { $0.id == player.id }) {
            if let winnings = bet.calculateWinnings(playerScores: playerScores, teeBox: teeBox)[player.id] {
                totalWinnings += winnings
            }
        }
        
        return totalWinnings
    }
}

public class UserProfile: ObservableObject {
    @Published public var currentUser: Player?
    
    public init() {}
} 