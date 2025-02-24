import SwiftUI
import BetComponents

struct TeeBoxSelectionView: View {
    let course: GolfCourse
    @State private var selectedTeeBox: TeeBox = TeeBox(id: UUID(), name: "", rating: 0, slope: 0, holes: [])
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userProfile: UserProfile
    @EnvironmentObject private var betManager: BetManager
    
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
                NavigationLink(destination: ScorecardView(course: course, teeBox: selectedTeeBox)) {
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