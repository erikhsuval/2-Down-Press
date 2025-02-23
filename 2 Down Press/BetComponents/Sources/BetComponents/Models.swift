import Foundation

public struct Player: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let handicap: Int
    
    public init(id: UUID = UUID(), name: String, handicap: Int) {
        self.id = id
        self.name = name
        self.handicap = handicap
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
    
    public init() {}
    
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