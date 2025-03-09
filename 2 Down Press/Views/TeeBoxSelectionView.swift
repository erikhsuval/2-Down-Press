import SwiftUI
import BetComponents
import os

private struct LoggerKey: EnvironmentKey {
    static let defaultValue = Logger(subsystem: "com.2downpress", category: "default")
}

extension EnvironmentValues {
    var logger: Logger {
        get { self[LoggerKey.self] }
        set { self[LoggerKey.self] = newValue }
    }
}

extension TeeBox: Hashable {
    static func == (lhs: TeeBox, rhs: TeeBox) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TeeBoxSelectionView: View {
    let course: GolfCourse
    @State private var selectedIndex: Int = 0
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var navigateToScorecard = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userProfile: UserProfile
    @EnvironmentObject private var betManager: BetManager
    
    private var selectedLocalTeeBox: BetComponents.TeeBox? {
        guard !course.teeBoxes.isEmpty else { return nil }
        let name = course.teeBoxes[selectedIndex].name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch name {
        case "championship": return .championship
        case "black": return .black
        case "black/blue": return .blackBlue
        case "blue": return .blue
        case "blue/gold": return .blueGold
        case "gold": return .gold
        case "white": return .white
        case "green": return .green
        default: return .white
        }
    }
    
    private let logger = Logger(subsystem: "com.2downpress", category: "TeeBoxSelection")
    
    var body: some View {
        NavigationStack {
            TeeBoxFormContent(
                course: course,
                selectedIndex: $selectedIndex,
                selectedLocalTeeBox: selectedLocalTeeBox
            )
            .navigationTitle("Select Tee Box")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton(dismiss: dismiss)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NextButton(
                        isEnabled: !course.teeBoxes.isEmpty && selectedLocalTeeBox != nil,
                        action: { navigateToScorecard = true }
                    )
                }
            }
            .navigationDestination(isPresented: $navigateToScorecard) {
                if let selected = selectedLocalTeeBox {
                    ScorecardView(course: course, teeBox: selected)
                }
            }
        }
        .onAppear {
            selectedIndex = 0
            logger.debug("Set initial tee box index to 0")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}

private struct TeeBoxFormContent: View {
    let course: GolfCourse
    @Binding var selectedIndex: Int
    let selectedLocalTeeBox: BetComponents.TeeBox?
    
    var body: some View {
        Form {
            if course.teeBoxes.isEmpty {
                EmptyTeeBoxSection()
            } else {
                TeeBoxPickerSection(
                    course: course,
                    selectedIndex: $selectedIndex
                )
                
                if let selected = selectedLocalTeeBox {
                    TeeBoxDetailsSection(teeBox: selected)
                }
            }
        }
    }
}

private struct EmptyTeeBoxSection: View {
    var body: some View {
        Section {
            Text("No tee boxes available for this course")
                .foregroundColor(.red)
        }
    }
}

private struct TeeBoxPickerSection: View {
    let course: GolfCourse
    @Binding var selectedIndex: Int
    
    var body: some View {
        Section(header: Text("Select Tee Box")) {
            Picker("Tee Box", selection: $selectedIndex) {
                ForEach(Array(course.teeBoxes.enumerated()), id: \.offset) { index, teeBox in
                    Text(teeBox.name).tag(index)
                }
            }
            .pickerStyle(.inline)
        }
    }
}

private struct TeeBoxDetailsSection: View {
    let teeBox: BetComponents.TeeBox
    
    var body: some View {
        Section(header: Text("Tee Box Details")) {
            TotalYardsRow(teeBox: teeBox)
            TotalParRow(teeBox: teeBox)
        }
    }
}

private struct TotalYardsRow: View {
    let teeBox: BetComponents.TeeBox
    
    var body: some View {
        HStack {
            Text("Total Yards:")
            Spacer()
            Text("\(teeBox.holes.reduce(0) { $0 + $1.yardage })")
        }
    }
}

private struct TotalParRow: View {
    let teeBox: BetComponents.TeeBox
    
    var body: some View {
        HStack {
            Text("Total Par:")
            Spacer()
            Text("\(teeBox.holes.reduce(0) { $0 + $1.par })")
        }
    }
}

private struct BackButton: View {
    let dismiss: DismissAction
    
    var body: some View {
        Button(action: { dismiss() }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Course Selection")
            }
        }
    }
}

private struct NextButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Next")
        }
        .disabled(!isEnabled)
    }
} 
