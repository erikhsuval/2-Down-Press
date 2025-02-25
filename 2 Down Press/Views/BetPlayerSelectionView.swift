import SwiftUI
import BetComponents

struct BetPlayerSelectionView: View {
    let players: [BetComponents.Player]
    @Binding var selectedPlayer: BetComponents.Player?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfile: UserProfile
    
    var displayPlayers: [BetComponents.Player] {
        // Show all available players from the scorecard
        players
    }
    
    var body: some View {
        NavigationView {
            List(displayPlayers) { player in
                Button(action: {
                    selectedPlayer = player
                    dismiss()
                }) {
                    HStack {
                        Text(player.firstName + " " + player.lastName)
                        Spacer()
                        if selectedPlayer?.id == player.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.primaryGreen)
                        }
                    }
                }
            }
            .navigationTitle("Select Players")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
        }
    }
} 