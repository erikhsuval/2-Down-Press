import Foundation
import CoreLocation
import BetComponents

// Base types for golf course data
struct GolfCourse: Identifiable, Codable {
    let id: UUID
    let name: String
    let location: CLLocationCoordinate2D
    let teeBoxes: [BetComponents.TeeBox]
    
    init(id: UUID = UUID(), name: String, location: CLLocationCoordinate2D, teeBoxes: [BetComponents.TeeBox]) {
        self.id = id
        self.name = name
        self.location = location
        self.teeBoxes = teeBoxes
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, teeBoxes
        case latitude, longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        teeBoxes = try container.decode([BetComponents.TeeBox].self, forKey: .teeBoxes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(location.latitude, forKey: .latitude)
        try container.encode(location.longitude, forKey: .longitude)
        try container.encode(teeBoxes, forKey: .teeBoxes)
    }
    
    static let bayouDeSiard = GolfCourse(
        name: "Bayou DeSiard Country Club",
        location: CLLocationCoordinate2D(latitude: 32.5429, longitude: -92.0974),
        teeBoxes: [
            .championship,
            .black,
            .blackBlue,
            .blue,
            .blueGold,
            .gold,
            .white,
            .green
        ]
    )
}

struct HoleInfo: Identifiable, Codable, Hashable {
    let id: UUID
    let number: Int
    let par: Int
    let yardage: Int
    let handicap: Int
} 