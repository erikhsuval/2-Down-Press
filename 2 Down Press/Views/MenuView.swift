import SwiftUI
import BetComponents

struct MenuView: View {
    @EnvironmentObject private var betManager: BetManager
    @EnvironmentObject private var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("My Bets", destination: MyBetsView()
                    .environmentObject(betManager)
                    .environmentObject(userProfile))
                NavigationLink("The Sheet", destination: TheSheetView())
                NavigationLink("Past Rounds", destination: Text("Past Rounds"))
                NavigationLink("Manage Players", destination: PlayerManagementView())
                NavigationLink("Settings", destination: Text("Settings"))
                NavigationLink("Help", destination: Text("Help"))
                NavigationLink("Account", destination: Text("Account"))
            }
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 