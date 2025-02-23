import Foundation

// Player model for user data
struct Player: Codable, Identifiable, Hashable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var nickname: String?
    
    var scorecardName: String {
        if let nickname = nickname {
            return "\"" + nickname + "\""
        }
        return String(firstName.prefix(8).uppercased())
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
} 