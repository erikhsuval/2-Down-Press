import SwiftUI
import BetComponents

struct PuttingSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var betManager: BetManager
    @State private var selectedWinners: Set<UUID> = []
    @State private var selectedAmount: Double = 20.0
    @State private var customAmount: String = ""
    @State private var isCustomAmount: Bool = false
    @State private var showCustomAmountSheet = false
    @State private var showSettleAnimation = false
    @State private var showMoneyDisplayAnimation = false
    let bet: PuttingWithPuffBet
    
    private let quickAmounts = [10.0, 20.0, 30.0, 50.0, 100.0]
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(dismiss: dismiss)
            
            BetAmountSelectionView(
                quickAmounts: quickAmounts,
                selectedAmount: $selectedAmount,
                isCustomAmount: $isCustomAmount,
                showCustomAmountSheet: $showCustomAmountSheet
            )
            
            // Main content with player selection and scoreboard
            MainContentView(
                bet: bet,
                selectedWinners: $selectedWinners,
                showMoneyDisplayAnimation: $showMoneyDisplayAnimation
            )
            .padding(.vertical, 8)
            
            MadePuttButton(
                selectedWinners: selectedWinners,
                selectedAmount: selectedAmount,
                bet: bet,
                betManager: betManager,
                showMoneyDisplayAnimation: $showMoneyDisplayAnimation,
                selectedWinnersBinding: $selectedWinners
            )
        }
        .background(Color.gray.opacity(0.1))
        .sheet(isPresented: $showCustomAmountSheet) {
            CustomAmountSheet(
                customAmount: $customAmount,
                isCustomAmount: $isCustomAmount,
                selectedAmount: $selectedAmount,
                showSheet: $showCustomAmountSheet
            )
        }
    }
}

private struct HeaderView: View {
    let dismiss: DismissAction
    
    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                Text("Settle Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
            
            Spacer()
            
            Text("Putting with Puff")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .background(Color.primaryGreen)
    }
}

private struct BetAmountSelectionView: View {
    let quickAmounts: [Double]
    @Binding var selectedAmount: Double
    @Binding var isCustomAmount: Bool
    @Binding var showCustomAmountSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Bet Amount")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quickAmounts, id: \.self) { amount in
                        BetAmountButton(
                            amount: amount,
                            isSelected: !isCustomAmount && selectedAmount == amount,
                            action: {
                                isCustomAmount = false
                                selectedAmount = amount
                            }
                        )
                    }
                    
                    BetAmountButton(
                        amount: isCustomAmount ? selectedAmount : 0,
                        isSelected: isCustomAmount,
                        isCustom: true,
                        customAmount: isCustomAmount ? String(format: "$%.0f", selectedAmount) : nil,
                        action: { showCustomAmountSheet = true }
                    )
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color.white)
    }
}

private struct MainContentView: View {
    let bet: PuttingWithPuffBet
    @Binding var selectedWinners: Set<UUID>
    @Binding var showMoneyDisplayAnimation: Bool
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left side: Player Selection (40% width)
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(bet.players), id: \.id) { player in
                            SelectablePlayerButton(
                                player: player,
                                isSelected: selectedWinners.contains(player.id)
                            ) {
                                if selectedWinners.contains(player.id) {
                                    selectedWinners.remove(player.id)
                                } else {
                                    selectedWinners.insert(player.id)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .frame(width: geometry.size.width * 0.4)
                
                // Right side: Stadium Scoreboard (60% width)
                StadiumScoreboard(
                    playerTotals: bet.playerTotals,
                    players: bet.players,
                    showAnimation: showMoneyDisplayAnimation
                )
                .frame(width: geometry.size.width * 0.6)
            }
        }
    }
}

private struct SelectablePlayerButton: View {
    let player: BetComponents.Player
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(isSelected ? Color.primaryGreen : Color.white)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(player.firstName.prefix(1))
                            .font(.title2.bold())
                            .foregroundColor(isSelected ? .white : .primaryGreen)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.primaryGreen, lineWidth: 2)
                    )
                
                Text(player.firstName)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.primaryGreen.opacity(0.1) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primaryGreen : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
    }
}

private struct StadiumScoreboard: View {
    let playerTotals: [UUID: Double]
    let players: Set<BetComponents.Player>
    let showAnimation: Bool
    
    var sortedPlayers: [(player: BetComponents.Player, total: Double)] {
        players.map { player in
            (player, playerTotals[player.id] ?? 0)
        }.sorted { $0.total > $1.total }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Scoreboard Header with Money Animation
            ZStack {
                Text("LIVE MONEY DISPLAY")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                
                if showAnimation {
                    MoneyBorderAnimation()
                }
            }
            .background(Color.deepNavyBlue)
            
            // Scoreboard Content
            ScrollView {
                VStack(spacing: 1) {
                    ForEach(sortedPlayers, id: \.player.id) { playerInfo in
                        ScoreboardRow(
                            playerName: playerInfo.player.firstName,
                            amount: playerInfo.total,
                            showAnimation: showAnimation
                        )
                    }
                }
            }
            .background(Color.black)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.deepNavyBlue, lineWidth: 2)
        )
    }
}

private struct MoneyBorderAnimation: View {
    @State private var currentMoneyIndex = 0
    private let numberOfMoneySymbols = 16  // Total positions around the border
    private let numberOfLoops = 2  // Number of times to circle around
    private let animationDuration = 0.15  // Duration for each money symbol
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<numberOfMoneySymbols, id: \.self) { index in
                MoneySymbol(
                    position: index,
                    totalPositions: numberOfMoneySymbols,
                    size: geometry.size,
                    isVisible: index == currentMoneyIndex
                )
            }
        }
        .onAppear {
            animateMoneySequence()
        }
    }
    
    private func animateMoneySequence() {
        let totalSteps = numberOfMoneySymbols * numberOfLoops
        
        func animate(step: Int) {
            guard step < totalSteps else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                withAnimation(.easeInOut(duration: animationDuration)) {
                    currentMoneyIndex = step % numberOfMoneySymbols
                }
                animate(step: step + 1)
            }
        }
        
        animate(step: 0)
    }
}

private struct MoneySymbol: View {
    let position: Int
    let totalPositions: Int
    let size: CGSize
    let isVisible: Bool
    
    var body: some View {
        let angle = (Double(position) / Double(totalPositions)) * 2 * .pi
        let radius = min(size.width, size.height) * 0.4
        let x = size.width/2 + radius * cos(angle)
        let y = size.height/2 + radius * sin(angle)
        
        Text("💰")
            .font(.system(size: 20))
            .position(x: x, y: y)
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.5)
    }
}

private struct ScoreboardRow: View {
    let playerName: String
    let amount: Double
    let showAnimation: Bool
    
    var body: some View {
        HStack {
            Text(playerName)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(String(format: "$%.0f", amount))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(amount >= 0 ? .green : .red)
                .shadow(color: amount >= 0 ? .green.opacity(0.5) : .red.opacity(0.5), radius: showAnimation ? 12 : 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black)
        .overlay(
            Rectangle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        .white.opacity(showAnimation ? 0.2 : 0.1),
                        .clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
        )
        .scaleEffect(showAnimation ? 1.05 : 1.0)
        .brightness(showAnimation ? 0.1 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showAnimation)
    }
}

private struct MadePuttButton: View {
    let selectedWinners: Set<UUID>
    let selectedAmount: Double
    let bet: PuttingWithPuffBet
    let betManager: BetManager
    @Binding var showMoneyDisplayAnimation: Bool
    @Binding var selectedWinnersBinding: Set<UUID>
    
    var body: some View {
        Button(action: {
            if var updatedBet = betManager.puttingWithPuffBets.last {
                for playerId in bet.players.map(\.id) {
                    if selectedWinners.contains(playerId) {
                        let numberOfLosers = bet.players.count - selectedWinners.count
                        let winnings = selectedAmount * Double(numberOfLosers)
                        updatedBet.playerTotals[playerId, default: 0] += winnings
                    } else {
                        let paymentToWinners = selectedAmount * Double(selectedWinners.count)
                        updatedBet.playerTotals[playerId, default: 0] -= paymentToWinners
                    }
                }
                
                betManager.updatePuttingWithPuffBet(updatedBet)
                
                withAnimation {
                    showMoneyDisplayAnimation = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showMoneyDisplayAnimation = false
                        selectedWinnersBinding.removeAll()
                    }
                }
            }
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Made putt, apply amount")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(selectedWinners.isEmpty ? Color.gray : Color.primaryGreen)
            )
        }
        .disabled(selectedWinners.isEmpty)
        .padding()
    }
}

private struct BetAmountButton: View {
    let amount: Double
    let isSelected: Bool
    var isCustom: Bool = false
    var customAmount: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if isCustom {
                    Image(systemName: "plus.circle.fill")
                    Text(customAmount ?? "Custom")
                } else {
                    Text("$\(Int(amount))")
                }
            }
            .font(.headline)
            .foregroundColor(isSelected ? .white : .primaryGreen)
            .frame(width: isCustom ? 100 : 80, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(isSelected ? Color.primaryGreen : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.primaryGreen, lineWidth: 2)
            )
        }
        .shadow(color: .black.opacity(0.1), radius: 4)
    }
}

private struct RunningTotalsCard: View {
    let playerTotals: [UUID: Double]
    let players: Set<BetComponents.Player>
    
    var sortedPlayers: [(player: BetComponents.Player, total: Double)] {
        players.map { player in
            (player, playerTotals[player.id] ?? 0)
        }.sorted { $0.total > $1.total }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Running Totals")
                .font(.headline)
                .foregroundColor(.primaryGreen)
            
            ForEach(sortedPlayers, id: \.player.id) { playerInfo in
                HStack(spacing: 16) {
                    Circle()
                        .fill(playerInfo.total >= 0 ? Color.primaryGreen.opacity(0.2) : Color.red.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(playerInfo.player.firstName.prefix(1))
                                .font(.headline.bold())
                                .foregroundColor(playerInfo.total >= 0 ? .primaryGreen : .red)
                        )
                    
                    Text(playerInfo.player.firstName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(String(format: "$%.0f", playerInfo.total))
                        .font(.title3.bold())
                        .foregroundColor(playerInfo.total >= 0 ? .primaryGreen : .red)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 3)
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.05))
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .padding(.horizontal)
    }
}

struct CustomAmountSheet: View {
    @Binding var customAmount: String
    @Binding var isCustomAmount: Bool
    @Binding var selectedAmount: Double
    @Binding var showSheet: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter amount", text: $customAmount)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: {
                    if let amount = Double(customAmount) {
                        isCustomAmount = true
                        selectedAmount = amount
                        showSheet = false
                    }
                }) {
                    Text("Set Amount")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Double(customAmount) != nil ? Color.primaryGreen : Color.gray)
                        )
                }
                .disabled(Double(customAmount) == nil)
                .padding(.horizontal)
            }
            .navigationTitle("Custom Amount")
            .navigationBarItems(trailing: Button("Cancel") {
                showSheet = false
            })
        }
    }
} 