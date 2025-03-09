import Foundation

struct TeeBox: Identifiable, Codable {
    let id: UUID
    let name: String
    let holes: [HoleInfo]
    
    init(id: UUID = UUID(), name: String, holes: [HoleInfo]) {
        self.id = id
        self.name = name
        self.holes = holes
    }
} 