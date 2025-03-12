import Foundation
import SwiftUI
import BetComponents

class GameStateManager: ObservableObject {
    @Published var currentGame: GameState?
    private let defaults = UserDefaults.standard
    private let currentGameKey = "currentGameState"
    
    init() {
        loadCurrentGame()
    }
    
    public func saveCurrentGame(
        course: GolfCourse,
        teeBox: BetComponents.TeeBox,
        players: [BetComponents.Player],
        scores: [UUID: [String]],
        betManager: BetManager,
        isCompleted: Bool = false,
        selectedPlayerId: UUID? = nil
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
            groups: [],
            currentGroupIndex: nil,
            isGroupLeader: false,
            isCompleted: isCompleted,
            selectedPlayerId: selectedPlayerId
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