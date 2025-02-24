import SwiftUI
import BetComponents

struct BetPlayerSelectionView: View {
    let players: [BetComponents.Player]
    @Binding var selectedPlayer: BetComponents.Player?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userProfile: UserProfile
    
    var allPlayers: [BetComponents.Player] {
        var playerList = players
        if let currentUser = userProfile.currentUser {
            playerList.insert(currentUser, at: 0)
        }
        return playerList
    }
    
    var body: some View {
        NavigationView {
            List(allPlayers) { player in
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
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
        }
    }
} 