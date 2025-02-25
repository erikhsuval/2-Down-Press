import SwiftUI
import BetComponents

struct SinglePlayerSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userProfile: UserProfile
    @Binding var selectedPlayer: BetComponents.Player?
    let allPlayers: [BetComponents.Player]
    let excludedPlayers: [BetComponents.Player]
    let title: String
    
    private var availablePlayers: [BetComponents.Player] {
        allPlayers.filter { player in
            !excludedPlayers.contains { $0.id == player.id }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(availablePlayers) { player in
                    Button(action: {
                        selectedPlayer = player
                        dismiss()
                    }) {
                        HStack {
                            Text(player.firstName + " " + player.lastName)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedPlayer?.id == player.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.primaryGreen)
                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
} 