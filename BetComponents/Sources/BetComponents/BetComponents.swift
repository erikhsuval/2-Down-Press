// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public extension Color {
    static let primaryGreen = Color("PrimaryGreen")
    static let deepNavyBlue = Color(hex: "1B365D")
    static let primaryBlue = Color(hex: "1B365D")  // Same as deepNavyBlue for consistency
    static let teamGold = Color(hex: "D4AF37")  // This will be used for team assignments
    static let backgroundGray = Color(red: 0.95, green: 0.95, blue: 0.95)
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - TeamPlayerSelection Enum
public enum TeamPlayerSelection {
    case team1Player1
    case team1Player2
    case team2Player1
    case team2Player2
}

// MARK: - BetType Enum
public enum BetType: String, CaseIterable, Identifiable {
    case individualMatch = "Individual Match"
    case fourBallMatch = "Four-Ball Match"
    case alabama = "Alabama"
    case doDas = "Do-Da's"
    case skins = "Skins"
    case wolf = "Wolf"
    case circus = "Circus Bets"
    case puttingWithPuff = "Putting with Puff"
    
    public var id: String { rawValue }
    
    public var isSideBet: Bool {
        switch self {
        case .circus, .puttingWithPuff:
            return true
        default:
            return false
        }
    }
    
    public var description: String {
        switch self {
        case .individualMatch:
            return "One-on-one match with optional presses and birdie bets"
        case .fourBallMatch:
            return "Two-on-two better ball match with optional presses and birdie bets"
        case .alabama:
            return "Team game with multiple scoring formats"
        case .doDas:
            return "Pool or per-shot bet for chip-ins"
        case .skins:
            return "Individual pot for lowest score on each hole"
        case .wolf:
            return "Dynamic team selection on each hole"
        case .circus:
            return "Special bets for unique shots and achievements (Side Bet)"
        case .puttingWithPuff:
            return "Putting for money is normal (Side Bet)"
        }
    }
    
    public var emoji: String {
        switch self {
        case .individualMatch: return "👥"
        case .fourBallMatch: return "👥"
        case .alabama: return "🏌️"
        case .doDas: return "✌️"
        case .skins: return "💰"
        case .wolf: return "🐺"
        case .circus: return "🎪"
        case .puttingWithPuff: return "💉"
        }
    }
}

// MARK: - PlayerSelectionButton
public struct PlayerSelectionButton: View {
    let title: String
    let playerName: String
    
    public init(title: String, playerName: String) {
        self.title = title
        self.playerName = playerName
    }
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(playerName)
                    .font(.body)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
    }
}

// MARK: - BetTypeCard
public struct BetTypeCard: View {
    let title: String
    let description: String
    let imageName: String
    let action: () -> Void
    
    public init(title: String, description: String, imageName: String, action: @escaping () -> Void) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(imageName)
                    .font(.system(size: 30))
                    .foregroundColor(.primaryGreen)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
    }
}
