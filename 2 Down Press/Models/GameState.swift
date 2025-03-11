import Foundation
import BetComponents

struct GameState: Codable {
    let courseId: UUID
    let courseName: String
    let teeBoxName: String
    let players: [BetComponents.Player]
    let scores: [UUID: [String]]
    let timestamp: Date
    let bets: SavedBets
    var isCompleted: Bool
    
    struct SavedBets: Codable {
        let individualBets: [BetComponents.IndividualMatchBet]
        let fourBallBets: [BetComponents.FourBallMatchBet]
        let alabamaBets: [BetComponents.AlabamaBet]
        let doDaBets: [BetComponents.DoDaBet]
        let skinsBets: [BetComponents.SkinsBet]
    }
}

class GameStateManager: ObservableObject {
    @Published var currentGame: GameState?
    private let defaults = UserDefaults.standard
    private let currentGameKey = "currentGameState"
    
    init() {
        loadCurrentGame()
    }
    
    func saveCurrentGame(
        course: GolfCourse,
        teeBox: BetComponents.TeeBox,
        players: [BetComponents.Player],
        scores: [UUID: [String]],
        betManager: BetManager,
        isCompleted: Bool = false
    ) {
        let gameState = GameState(
            courseId: course.id,
            courseName: course.name,
            teeBoxName: teeBox.name,
            players: players,
            scores: scores,
            timestamp: Date(),
            bets: GameState.SavedBets(
                individualBets: betManager.individualBets,
                fourBallBets: betManager.fourBallBets,
                alabamaBets: betManager.alabamaBets,
                doDaBets: betManager.doDaBets,
                skinsBets: betManager.skinsBets
            ),
            isCompleted: isCompleted
        )
        
        if let encoded = try? JSONEncoder().encode(gameState) {
            defaults.set(encoded, forKey: currentGameKey)
            currentGame = gameState
        }
    }
    
    func loadCurrentGame() {
        if let savedGame = defaults.data(forKey: currentGameKey),
           let gameState = try? JSONDecoder().decode(GameState.self, from: savedGame) {
            currentGame = gameState
        }
    }
    
    func clearCurrentGame() {
        defaults.removeObject(forKey: currentGameKey)
        currentGame = nil
    }
    
    func restoreGame(to betManager: BetManager) {
        guard let game = currentGame else { return }
        
        // Restore all bets
        betManager.individualBets = game.bets.individualBets
        betManager.fourBallBets = game.bets.fourBallBets
        betManager.alabamaBets = game.bets.alabamaBets
        betManager.doDaBets = game.bets.doDaBets
        betManager.skinsBets = game.bets.skinsBets
        
        // Restore scores
        betManager.playerScores = game.scores
    }
} 