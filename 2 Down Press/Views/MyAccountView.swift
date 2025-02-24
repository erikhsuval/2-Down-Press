import SwiftUI
import BetComponents

struct MyAccountView: View {
    @EnvironmentObject private var userProfile: UserProfile
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Personal Information")) {
                        TextField("First Name", text: $firstName)
                        TextField("Last Name", text: $lastName)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        Text("Scorecard Name: \(String(firstName.prefix(4).uppercased()))")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("My Account")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    let player = BetComponents.Player(id: userProfile.currentUser?.id ?? UUID(),
                                      firstName: firstName,
                                      lastName: lastName,
                                      email: email)
                    userProfile.saveUser(player)
                    dismiss()
                }
            )
            .onAppear {
                if let user = userProfile.currentUser {
                    firstName = user.firstName
                    lastName = user.lastName
                    email = user.email
                }
            }
        }
    }
} 