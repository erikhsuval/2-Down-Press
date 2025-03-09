import SwiftUI
import BetComponents

struct PostRoundView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var betManager: BetManager
    @Binding var isRoundPosted: Bool
    @State private var showUnpostConfirmation = false
    @State private var showPostConfirmation = false
    @State private var showPostAnimation = false
    let course: GolfCourse
    let teeBox: BetComponents.TeeBox
    let players: [BetComponents.Player]
    let playerScores: [UUID: [String]]
    
    var body: some View {
        VStack {
            // Post/Unpost Buttons
            HStack(spacing: 20) {
                Button(action: { 
                    showUnpostConfirmation = true 
                }) {
                    Text("Unpost")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.red.opacity(0.8))
                        )
                }
                .opacity(isRoundPosted ? 1 : 0.5)
                .disabled(!isRoundPosted)
                
                Button(action: { 
                    showPostConfirmation = true 
                }) {
                    Text("Post")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.primaryGreen)
                        )
                }
                .opacity(isRoundPosted ? 0.5 : 1)
                .disabled(isRoundPosted)
            }
            .padding()
            .background(Color.white)
            .alert("Post Round", isPresented: $showPostConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Post") {
                    betManager.updateScoresAndTeeBox(playerScores, teeBox)
                    isRoundPosted = true
                    
                    withAnimation {
                        showPostAnimation = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showPostAnimation = false
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("This will finalize the scorecard and update The Sheet. Continue?")
            }
            .alert("Unpost Round", isPresented: $showUnpostConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Unpost", role: .destructive) {
                    betManager.updateScoresAndTeeBox([:], teeBox)
                    isRoundPosted = false
                    dismiss()
                }
            } message: {
                Text("This will clear The Sheet and allow you to make edits to the scorecard and bets. Any changes will update The Sheet when posted again.")
            }
        }
    }
} 
