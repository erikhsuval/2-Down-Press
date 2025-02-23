import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var betManager: BetManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("My Bets", destination: MyBetsView())
                NavigationLink("The Sheet", destination: TheSheetView())
                NavigationLink("Past Rounds", destination: Text("Past Rounds"))
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