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
        return String(firstName.prefix(8).uppercased())
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
    
    public init(id: UUID = UUID(), number: Int, par: Int, yardage: Int) {
        self.id = id
        self.number = number
        self.par = par
        self.yardage = yardage
    }
}

public enum TeeBox: String, CaseIterable {
    case black = "Black"
    case blue = "Blue"
    case white = "White"
    case gold = "Gold"
    case red = "Red"
    
    public var color: String {
        switch self {
        case .black: return "Black"
        case .blue: return "Blue"
        case .white: return "White"
        case .gold: return "Gold"
        case .red: return "Red"
        }
    }

    public var name: String { rawValue }
    
    public var holes: [HoleInfo] {
        // You'll need to implement this based on your course data
        []  // Placeholder return
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