import SwiftUI
import BetComponents

struct TeeBoxSelectionView: View {
    let course: GolfCourse
    @State private var selectedTeeBox: TeeBox = TeeBox(id: UUID(), name: "", rating: 0, slope: 0, holes: [])
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userProfile: UserProfile
    @EnvironmentObject private var betManager: BetManager
    
    private var betComponentsTeeBox: BetComponents.TeeBox {
        switch selectedTeeBox.name.lowercased() {
        case "black": return .black
        case "blue": return .blue
        case "white": return .white
        case "gold": return .gold
        case "red": return .red
        default: return .white
        }
    }
    
    var body: some View {
        Form(content: {
            Section(header: Text("Select Tee Box")) {
                Picker("Tee Box", selection: $selectedTeeBox) {
                    ForEach(course.teeBoxes) { teeBox in
                        Text(teeBox.name)
                            .tag(teeBox)
                    }
                }
                .pickerStyle(.inline)
            }
        })
        .navigationTitle("Select Tee Box")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ScorecardView(course: course, teeBox: betComponentsTeeBox)) {
                    Text("Next")
                }
            }
        }
        .onAppear {
            if !course.teeBoxes.isEmpty {
                selectedTeeBox = course.teeBoxes[0]
            }
        }
    }
} 