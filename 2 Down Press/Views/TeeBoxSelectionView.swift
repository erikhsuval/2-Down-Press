import SwiftUI
import BetComponents
import os

struct TeeBoxSelectionView: View {
    let course: GolfCourse
    @State private var selectedTeeBox: TeeBox?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var navigateToScorecard = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userProfile: UserProfile
    @EnvironmentObject private var betManager: BetManager
    
    private let logger = Logger(subsystem: "com.2downpress", category: "TeeBoxSelection")
    
    private func convertToBetComponentsTeeBox(_ teeBox: TeeBox?) -> BetComponents.TeeBox {
        guard let teeBox = teeBox else {
            logger.debug("No tee box selected, defaulting to white")
            return .white
        }
        
        let name = teeBox.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        logger.debug("Converting tee box: \(name)")
        
        switch name {
        case "championship": return .championship
        case "black": return .black
        case "black/blue": return .blackBlue
        case "blue": return .blue
        case "blue/gold": return .blueGold
        case "gold": return .gold
        case "white": return .white
        case "green": return .green
        default:
            logger.error("Unknown tee box name: \(name), defaulting to white")
            return .white
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if course.teeBoxes.isEmpty {
                    Section {
                        Text("No tee boxes available for this course")
                            .foregroundColor(.red)
                    }
                } else {
                    Section(header: Text("Select Tee Box")) {
                        Picker("Tee Box", selection: $selectedTeeBox) {
                            ForEach(course.teeBoxes) { teeBox in
                                Text(teeBox.name)
                                    .tag(Optional(teeBox))
                            }
                        }
                        .pickerStyle(.inline)
                        .onChange(of: selectedTeeBox) { oldValue, newValue in
                            logger.debug("Tee box selection changed from \(String(describing: oldValue?.name)) to \(String(describing: newValue?.name))")
                        }
                    }
                    
                    if let selected = selectedTeeBox {
                        Section(header: Text("Tee Box Details")) {
                            HStack {
                                Text("Rating:")
                                Spacer()
                                Text(String(format: "%.1f", selected.rating))
                            }
                            HStack {
                                Text("Slope:")
                                Spacer()
                                Text("\(selected.slope)")
                            }
                            HStack {
                                Text("Total Yards:")
                                Spacer()
                                Text("\(selected.holes.reduce(0) { $0 + $1.yardage })")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Tee Box")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Course Selection")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !course.teeBoxes.isEmpty {
                        Button(action: {
                            navigateToScorecard = true
                        }) {
                            Text("Next")
                        }
                        .disabled(selectedTeeBox == nil)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToScorecard) {
                if let selected = selectedTeeBox {
                    let betTeeBox = convertToBetComponentsTeeBox(selected)
                    ScorecardView(course: course, teeBox: betTeeBox)
                }
            }
        }
        .onAppear {
            logger.debug("TeeBoxSelectionView appeared with \(course.teeBoxes.count) tee boxes")
            if !course.teeBoxes.isEmpty {
                selectedTeeBox = course.teeBoxes[0]
                logger.debug("Set initial tee box to: \(course.teeBoxes[0].name)")
            } else {
                logger.error("No tee boxes available for course: \(course.name)")
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
} 