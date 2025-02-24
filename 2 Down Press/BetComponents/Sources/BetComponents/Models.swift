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
    
    public func updateScoresAndTeeBox(scores: [UUID: [String]], teeBox: TeeBox) {
        self.playerScores = scores
        self.teeBox = teeBox
        
        // Update scores and teeBox for all bets
        for index in individualBets.indices {
            individualBets[index].playerScores = scores
            individualBets[index].teeBox = teeBox
        }
        
        for index in fourBallBets.indices {
            fourBallBets[index].playerScores = scores
            fourBallBets[index].teeBox = teeBox
        }
        
        for index in alabamaBets.indices {
            alabamaBets[index].playerScores = scores
            alabamaBets[index].teeBox = teeBox
        }
        
        for index in doDaBets.indices {
            doDaBets[index].playerScores = scores
            doDaBets[index].teeBox = teeBox
        }
        
        for index in skinsBets.indices {
            skinsBets[index].playerScores = scores
            skinsBets[index].teeBox = teeBox
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
}

public class UserProfile: ObservableObject {
    @Published public var currentUser: Player?
    
    public init() {}
} 