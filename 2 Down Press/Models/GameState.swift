import Foundation
import BetComponents

public struct GameState: Codable {
    public let courseId: UUID
    public let courseName: String
    public let teeBoxName: String
    public let players: [BetComponents.Player]
    public let scores: [UUID: [String]]
    public let timestamp: Date
    public let bets: SavedBets
    public let groups: [[BetComponents.Player]]
    public let currentGroupIndex: Int?
    public let isGroupLeader: Bool
    public var isCompleted: Bool
    public let selectedPlayerId: UUID?
    
    public struct SavedBets: Codable {
        public let individualBets: [BetComponents.IndividualMatchBet]
        public let fourBallBets: [BetComponents.FourBallMatchBet]
        public let alabamaBets: [BetComponents.AlabamaBet]
        public let doDaBets: [BetComponents.DoDaBet]
        public let skinsBets: [BetComponents.SkinsBet]
        
        public init(
            individualBets: [BetComponents.IndividualMatchBet],
            fourBallBets: [BetComponents.FourBallMatchBet],
            alabamaBets: [BetComponents.AlabamaBet],
            doDaBets: [BetComponents.DoDaBet],
            skinsBets: [BetComponents.SkinsBet]
        ) {
            self.individualBets = individualBets
            self.fourBallBets = fourBallBets
            self.alabamaBets = alabamaBets
            self.doDaBets = doDaBets
            self.skinsBets = skinsBets
        }
    }
    
    public init(
        courseId: UUID,
        courseName: String,
        teeBoxName: String,
        players: [BetComponents.Player],
        scores: [UUID: [String]],
        timestamp: Date,
        bets: SavedBets,
        groups: [[BetComponents.Player]],
        currentGroupIndex: Int?,
        isGroupLeader: Bool,
        isCompleted: Bool,
        selectedPlayerId: UUID?
    ) {
        self.courseId = courseId
        self.courseName = courseName
        self.teeBoxName = teeBoxName
        self.players = players
        self.scores = scores
        self.timestamp = timestamp
        self.bets = bets
        self.groups = groups
        self.currentGroupIndex = currentGroupIndex
        self.isGroupLeader = isGroupLeader
        self.isCompleted = isCompleted
        self.selectedPlayerId = selectedPlayerId
    }
} 