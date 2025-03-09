import Foundation

struct ShareableScoreData: Codable {
    let groupId: UUID
    let courseId: UUID
    let courseName: String
    let teeBoxId: UUID
    let teeBoxName: String
    let timestamp: Date
    let players: [PlayerData]
    
    struct PlayerData: Codable {
        let id: UUID
        let firstName: String
        let lastName: String
        let scores: [String]
    }
    
    func toQRString() -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    static func fromQRString(_ string: String) -> ShareableScoreData? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = string.data(using: .utf8),
              let scoreData = try? decoder.decode(ShareableScoreData.self, from: data) else {
            return nil
        }
        return scoreData
    }
} 