import SwiftUI
import BetComponents

struct PlayerManagementView: View {
    @EnvironmentObject var playerManager: PlayerManager
    @State private var showingAddPlayer = false
    @State private var newPlayerFirstName = ""
    @State private var newPlayerLastName = ""
    @State private var newPlayerEmail = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        List {
            Section {
                ForEach(playerManager.allPlayers) { player in
                    PlayerRow(player: player)
                        .swipeActions {
                            Button(role: .destructive) {
                                playerManager.removePlayer(player)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                }
            } header: {
                Text("Current Round Players")
            } footer: {
                if playerManager.allPlayers.isEmpty {
                    Text("Add players for this round")
                }
            }
        }
        .navigationTitle("Manage Players")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddPlayer = true
                } label: {
                    Image(systemName: "person.badge.plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Clear All") {
                    playerManager.clearAllPlayers()
                }
                .disabled(playerManager.allPlayers.isEmpty)
            }
        }
        .sheet(isPresented: $showingAddPlayer) {
            NavigationView {
                Form {
                    Section(header: Text("New Player")) {
                        TextField("First Name", text: $newPlayerFirstName)
                        TextField("Last Name", text: $newPlayerLastName)
                        TextField("Email (Optional)", text: $newPlayerEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                }
                .navigationTitle("Add Player")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        showingAddPlayer = false
                    },
                    trailing: Button("Add") {
                        addPlayer()
                    }
                    .disabled(newPlayerFirstName.isEmpty || newPlayerLastName.isEmpty)
                )
            }
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func addPlayer() {
        // Check if player already exists
        if playerManager.getPlayer(byName: newPlayerFirstName, lastName: newPlayerLastName) != nil {
            alertMessage = "A player with this name already exists."
            showingAlert = true
            return
        }
        
        playerManager.addPlayer(
            firstName: newPlayerFirstName,
            lastName: newPlayerLastName,
            email: newPlayerEmail
        )
        
        showingAddPlayer = false
        
        // Reset form
        newPlayerFirstName = ""
        newPlayerLastName = ""
        newPlayerEmail = ""
    }
}

struct PlayerRow: View {
    let player: BetComponents.Player
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(player.firstName) \(player.lastName)")
                .font(.headline)
            if !player.email.isEmpty {
                Text(player.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
} 