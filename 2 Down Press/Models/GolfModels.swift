import Foundation
import CoreLocation

// Base types for golf course data
struct GolfCourse: Identifiable, Codable {
    let id: UUID
    let name: String
    let location: CLLocationCoordinate2D
    let teeBoxes: [TeeBox]
    
    init(id: UUID, name: String, location: CLLocationCoordinate2D, teeBoxes: [TeeBox]) {
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
        teeBoxes = try container.decode([TeeBox].self, forKey: .teeBoxes)
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
        id: UUID(),
        name: "Bayou DeSiard Country Club",
        location: CLLocationCoordinate2D(latitude: 32.5429, longitude: -92.0974),
        teeBoxes: [
            TeeBox(id: UUID(), name: "Championship", rating: 74.5, slope: 131, holes: championshipHoles),
            TeeBox(id: UUID(), name: "Black", rating: 73.8, slope: 125, holes: blackHoles),
            TeeBox(id: UUID(), name: "Black/Blue", rating: 72.4, slope: 123, holes: blackBlueHoles),
            TeeBox(id: UUID(), name: "Blue", rating: 71.5, slope: 122, holes: blueHoles),
            TeeBox(id: UUID(), name: "Blue/Gold", rating: 69.7, slope: 118, holes: blueGoldHoles),
            TeeBox(id: UUID(), name: "Gold", rating: 68.8, slope: 117, holes: goldHoles),
            TeeBox(id: UUID(), name: "White", rating: 66.5, slope: 110, holes: whiteHoles),
            TeeBox(id: UUID(), name: "Green", rating: 62.8, slope: 100, holes: greenHoles)
        ]
    )
    
    // Championship tee holes data
    private static let championshipHoles: [HoleInfo] = [
        HoleInfo(id: UUID(), number: 1, par: 4, yardage: 376, handicap: 7),
        HoleInfo(id: UUID(), number: 2, par: 4, yardage: 388, handicap: 3),
        HoleInfo(id: UUID(), number: 3, par: 5, yardage: 554, handicap: 11),
        HoleInfo(id: UUID(), number: 4, par: 3, yardage: 200, handicap: 1),
        HoleInfo(id: UUID(), number: 5, par: 4, yardage: 416, handicap: 9),
        HoleInfo(id: UUID(), number: 6, par: 5, yardage: 544, handicap: 17),
        HoleInfo(id: UUID(), number: 7, par: 4, yardage: 406, handicap: 13),
        HoleInfo(id: UUID(), number: 8, par: 4, yardage: 458, handicap: 5),
        HoleInfo(id: UUID(), number: 9, par: 3, yardage: 174, handicap: 15),
        HoleInfo(id: UUID(), number: 10, par: 4, yardage: 415, handicap: 6),
        HoleInfo(id: UUID(), number: 11, par: 4, yardage: 414, handicap: 8),
        HoleInfo(id: UUID(), number: 12, par: 4, yardage: 390, handicap: 14),
        HoleInfo(id: UUID(), number: 13, par: 4, yardage: 434, handicap: 4),
        HoleInfo(id: UUID(), number: 14, par: 5, yardage: 597, handicap: 10),
        HoleInfo(id: UUID(), number: 15, par: 3, yardage: 129, handicap: 16),
        HoleInfo(id: UUID(), number: 16, par: 5, yardage: 553, handicap: 18),
        HoleInfo(id: UUID(), number: 17, par: 3, yardage: 208, handicap: 12),
        HoleInfo(id: UUID(), number: 18, par: 4, yardage: 436, handicap: 2)
    ]
    
    // Black tee holes data
    private static let blackHoles: [HoleInfo] = [
        HoleInfo(id: UUID(), number: 1, par: 4, yardage: 376, handicap: 7),
        HoleInfo(id: UUID(), number: 2, par: 4, yardage: 388, handicap: 3),
        HoleInfo(id: UUID(), number: 3, par: 5, yardage: 517, handicap: 11),
        HoleInfo(id: UUID(), number: 4, par: 3, yardage: 200, handicap: 1),
        HoleInfo(id: UUID(), number: 5, par: 4, yardage: 377, handicap: 9),
        HoleInfo(id: UUID(), number: 6, par: 5, yardage: 544, handicap: 17),
        HoleInfo(id: UUID(), number: 7, par: 4, yardage: 406, handicap: 13),
        HoleInfo(id: UUID(), number: 8, par: 4, yardage: 416, handicap: 5),
        HoleInfo(id: UUID(), number: 9, par: 3, yardage: 174, handicap: 15),
        HoleInfo(id: UUID(), number: 10, par: 4, yardage: 415, handicap: 6),
        HoleInfo(id: UUID(), number: 11, par: 4, yardage: 414, handicap: 8),
        HoleInfo(id: UUID(), number: 12, par: 4, yardage: 390, handicap: 14),
        HoleInfo(id: UUID(), number: 13, par: 4, yardage: 406, handicap: 4),
        HoleInfo(id: UUID(), number: 14, par: 5, yardage: 563, handicap: 10),
        HoleInfo(id: UUID(), number: 15, par: 3, yardage: 123, handicap: 16),
        HoleInfo(id: UUID(), number: 16, par: 5, yardage: 553, handicap: 18),
        HoleInfo(id: UUID(), number: 17, par: 3, yardage: 208, handicap: 12),
        HoleInfo(id: UUID(), number: 18, par: 4, yardage: 436, handicap: 2)
    ]
    
    // Black/Blue tee holes data
    private static let blackBlueHoles: [HoleInfo] = [
        HoleInfo(id: UUID(), number: 1, par: 4, yardage: 376, handicap: 7),
        HoleInfo(id: UUID(), number: 2, par: 4, yardage: 388, handicap: 3),
        HoleInfo(id: UUID(), number: 3, par: 5, yardage: 497, handicap: 11),
        HoleInfo(id: UUID(), number: 4, par: 3, yardage: 174, handicap: 1),
        HoleInfo(id: UUID(), number: 5, par: 4, yardage: 360, handicap: 9),
        HoleInfo(id: UUID(), number: 6, par: 5, yardage: 544, handicap: 17),
        HoleInfo(id: UUID(), number: 7, par: 4, yardage: 406, handicap: 13),
        HoleInfo(id: UUID(), number: 8, par: 4, yardage: 378, handicap: 5),
        HoleInfo(id: UUID(), number: 9, par: 3, yardage: 174, handicap: 15),
        HoleInfo(id: UUID(), number: 10, par: 4, yardage: 394, handicap: 6),
        HoleInfo(id: UUID(), number: 11, par: 4, yardage: 414, handicap: 8),
        HoleInfo(id: UUID(), number: 12, par: 4, yardage: 350, handicap: 14),
        HoleInfo(id: UUID(), number: 13, par: 4, yardage: 392, handicap: 4),
        HoleInfo(id: UUID(), number: 14, par: 5, yardage: 524, handicap: 10),
        HoleInfo(id: UUID(), number: 15, par: 3, yardage: 123, handicap: 16),
        HoleInfo(id: UUID(), number: 16, par: 5, yardage: 553, handicap: 18),
        HoleInfo(id: UUID(), number: 17, par: 3, yardage: 175, handicap: 12),
        HoleInfo(id: UUID(), number: 18, par: 4, yardage: 408, handicap: 2)
    ]
    
    // Blue tee holes data
    private static let blueHoles: [HoleInfo] = [
        HoleInfo(id: UUID(), number: 1, par: 4, yardage: 359, handicap: 7),
        HoleInfo(id: UUID(), number: 2, par: 4, yardage: 366, handicap: 3),
        HoleInfo(id: UUID(), number: 3, par: 5, yardage: 497, handicap: 11),
        HoleInfo(id: UUID(), number: 4, par: 3, yardage: 174, handicap: 1),
        HoleInfo(id: UUID(), number: 5, par: 4, yardage: 360, handicap: 9),
        HoleInfo(id: UUID(), number: 6, par: 5, yardage: 499, handicap: 17),
        HoleInfo(id: UUID(), number: 7, par: 4, yardage: 369, handicap: 13),
        HoleInfo(id: UUID(), number: 8, par: 4, yardage: 378, handicap: 5),
        HoleInfo(id: UUID(), number: 9, par: 3, yardage: 155, handicap: 15),
        HoleInfo(id: UUID(), number: 10, par: 4, yardage: 394, handicap: 6),
        HoleInfo(id: UUID(), number: 11, par: 4, yardage: 396, handicap: 8),
        HoleInfo(id: UUID(), number: 12, par: 4, yardage: 350, handicap: 14),
        HoleInfo(id: UUID(), number: 13, par: 4, yardage: 392, handicap: 4),
        HoleInfo(id: UUID(), number: 14, par: 5, yardage: 524, handicap: 10),
        HoleInfo(id: UUID(), number: 15, par: 3, yardage: 109, handicap: 16),
        HoleInfo(id: UUID(), number: 16, par: 5, yardage: 522, handicap: 18),
        HoleInfo(id: UUID(), number: 17, par: 3, yardage: 175, handicap: 12),
        HoleInfo(id: UUID(), number: 18, par: 4, yardage: 408, handicap: 2)
    ]
    
    // Blue/Gold tee holes data
    private static let blueGoldHoles: [HoleInfo] = [
        HoleInfo(id: UUID(), number: 1, par: 4, yardage: 343, handicap: 7),
        HoleInfo(id: UUID(), number: 2, par: 4, yardage: 354, handicap: 3),
        HoleInfo(id: UUID(), number: 3, par: 5, yardage: 482, handicap: 11),
        HoleInfo(id: UUID(), number: 4, par: 3, yardage: 174, handicap: 1),
        HoleInfo(id: UUID(), number: 5, par: 4, yardage: 316, handicap: 9),
        HoleInfo(id: UUID(), number: 6, par: 5, yardage: 499, handicap: 17),
        HoleInfo(id: UUID(), number: 7, par: 4, yardage: 346, handicap: 13),
        HoleInfo(id: UUID(), number: 8, par: 4, yardage: 342, handicap: 5),
        HoleInfo(id: UUID(), number: 9, par: 3, yardage: 155, handicap: 15),
        HoleInfo(id: UUID(), number: 10, par: 4, yardage: 394, handicap: 6),
        HoleInfo(id: UUID(), number: 11, par: 4, yardage: 327, handicap: 8),
        HoleInfo(id: UUID(), number: 12, par: 4, yardage: 339, handicap: 14),
        HoleInfo(id: UUID(), number: 13, par: 4, yardage: 327, handicap: 4),
        HoleInfo(id: UUID(), number: 14, par: 5, yardage: 475, handicap: 10),
        HoleInfo(id: UUID(), number: 15, par: 3, yardage: 109, handicap: 16),
        HoleInfo(id: UUID(), number: 16, par: 5, yardage: 480, handicap: 18),
        HoleInfo(id: UUID(), number: 17, par: 3, yardage: 175, handicap: 12),
        HoleInfo(id: UUID(), number: 18, par: 4, yardage: 349, handicap: 2)
    ]
    
    // Gold tee holes data
    private static let goldHoles: [HoleInfo] = [
        HoleInfo(id: UUID(), number: 1, par: 4, yardage: 343, handicap: 7),
        HoleInfo(id: UUID(), number: 2, par: 4, yardage: 354, handicap: 3),
        HoleInfo(id: UUID(), number: 3, par: 5, yardage: 482, handicap: 11),
        HoleInfo(id: UUID(), number: 4, par: 3, yardage: 136, handicap: 1),
        HoleInfo(id: UUID(), number: 5, par: 4, yardage: 316, handicap: 9),
        HoleInfo(id: UUID(), number: 6, par: 5, yardage: 467, handicap: 17),
        HoleInfo(id: UUID(), number: 7, par: 4, yardage: 346, handicap: 13),
        HoleInfo(id: UUID(), number: 8, par: 4, yardage: 342, handicap: 5),
        HoleInfo(id: UUID(), number: 9, par: 3, yardage: 145, handicap: 15),
        HoleInfo(id: UUID(), number: 10, par: 4, yardage: 358, handicap: 6),
        HoleInfo(id: UUID(), number: 11, par: 4, yardage: 327, handicap: 8),
        HoleInfo(id: UUID(), number: 12, par: 4, yardage: 339, handicap: 14),
        HoleInfo(id: UUID(), number: 13, par: 4, yardage: 327, handicap: 4),
        HoleInfo(id: UUID(), number: 14, par: 5, yardage: 475, handicap: 10),
        HoleInfo(id: UUID(), number: 15, par: 3, yardage: 101, handicap: 16),
        HoleInfo(id: UUID(), number: 16, par: 5, yardage: 480, handicap: 18),
        HoleInfo(id: UUID(), number: 17, par: 3, yardage: 141, handicap: 12),
        HoleInfo(id: UUID(), number: 18, par: 4, yardage: 349, handicap: 2)
    ]
    
    // White tee holes data
    private static let whiteHoles: [HoleInfo] = [
        HoleInfo(id: UUID(), number: 1, par: 4, yardage: 318, handicap: 7),
        HoleInfo(id: UUID(), number: 2, par: 4, yardage: 321, handicap: 3),
        HoleInfo(id: UUID(), number: 3, par: 5, yardage: 430, handicap: 11),
        HoleInfo(id: UUID(), number: 4, par: 3, yardage: 129, handicap: 1),
        HoleInfo(id: UUID(), number: 5, par: 4, yardage: 283, handicap: 9),
        HoleInfo(id: UUID(), number: 6, par: 5, yardage: 436, handicap: 17),
        HoleInfo(id: UUID(), number: 7, par: 4, yardage: 315, handicap: 13),
        HoleInfo(id: UUID(), number: 8, par: 4, yardage: 336, handicap: 5),
        HoleInfo(id: UUID(), number: 9, par: 3, yardage: 100, handicap: 15),
        HoleInfo(id: UUID(), number: 10, par: 4, yardage: 353, handicap: 6),
        HoleInfo(id: UUID(), number: 11, par: 4, yardage: 301, handicap: 8),
        HoleInfo(id: UUID(), number: 12, par: 4, yardage: 309, handicap: 14),
        HoleInfo(id: UUID(), number: 13, par: 4, yardage: 286, handicap: 4),
        HoleInfo(id: UUID(), number: 14, par: 5, yardage: 470, handicap: 10),
        HoleInfo(id: UUID(), number: 15, par: 3, yardage: 73, handicap: 16),
        HoleInfo(id: UUID(), number: 16, par: 5, yardage: 445, handicap: 18),
        HoleInfo(id: UUID(), number: 17, par: 3, yardage: 116, handicap: 12),
        HoleInfo(id: UUID(), number: 18, par: 4, yardage: 316, handicap: 2)
    ]
    
    // Green tee holes data
    private static let greenHoles: [HoleInfo] = [
        HoleInfo(id: UUID(), number: 1, par: 4, yardage: 262, handicap: 7),
        HoleInfo(id: UUID(), number: 2, par: 4, yardage: 255, handicap: 3),
        HoleInfo(id: UUID(), number: 3, par: 5, yardage: 364, handicap: 11),
        HoleInfo(id: UUID(), number: 4, par: 3, yardage: 129, handicap: 1),
        HoleInfo(id: UUID(), number: 5, par: 4, yardage: 229, handicap: 9),
        HoleInfo(id: UUID(), number: 6, par: 5, yardage: 376, handicap: 17),
        HoleInfo(id: UUID(), number: 7, par: 4, yardage: 250, handicap: 13),
        HoleInfo(id: UUID(), number: 8, par: 4, yardage: 259, handicap: 5),
        HoleInfo(id: UUID(), number: 9, par: 3, yardage: 100, handicap: 15),
        HoleInfo(id: UUID(), number: 10, par: 4, yardage: 282, handicap: 6),
        HoleInfo(id: UUID(), number: 11, par: 4, yardage: 259, handicap: 8),
        HoleInfo(id: UUID(), number: 12, par: 4, yardage: 223, handicap: 14),
        HoleInfo(id: UUID(), number: 13, par: 4, yardage: 220, handicap: 4),
        HoleInfo(id: UUID(), number: 14, par: 5, yardage: 394, handicap: 10),
        HoleInfo(id: UUID(), number: 15, par: 3, yardage: 73, handicap: 16),
        HoleInfo(id: UUID(), number: 16, par: 5, yardage: 360, handicap: 18),
        HoleInfo(id: UUID(), number: 17, par: 3, yardage: 116, handicap: 12),
        HoleInfo(id: UUID(), number: 18, par: 4, yardage: 268, handicap: 2)
    ]
}

struct TeeBox: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let rating: Double
    let slope: Int
    let holes: [HoleInfo]
}

struct HoleInfo: Identifiable, Codable, Hashable {
    let id: UUID
    let number: Int
    let par: Int
    let yardage: Int
    let handicap: Int
} 