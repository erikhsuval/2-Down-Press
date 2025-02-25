// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public extension Color {
    static let primaryGreen = Color("PrimaryGreen")
    static let secondaryGold = Color("SecondaryGold")
    static let backgroundGray = Color(red: 0.95, green: 0.95, blue: 0.95)
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
    
    public var id: String { rawValue }
    
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
