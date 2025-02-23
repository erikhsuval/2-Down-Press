import SwiftUI

struct BetAmountField: View {
    let label: String
    let emoji: String
    @Binding var amount: Double
    
    var body: some View {
        HStack {
            Text(emoji)
                .font(.title)
            
            VStack(alignment: .leading) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("Amount", value: $amount, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    BetAmountField(
        label: "Per Hole",
        emoji: "⛳️",
        amount: .constant(10.0)
    )
    .padding()
} 