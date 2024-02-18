import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var manager = HealthKit()
    @EnvironmentObject var authManager: AuthManager

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            if authManager.isLoggedIn {
                EmptyView() 
                    .onAppear {
                        showAlert = true
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Success"),
                            message: Text("Loggin Success!"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
            } else {
                loginView
            }
        }
    }
    private var loginView: some View {
        VStack(spacing: 16) {
            Text("Log in to Your Account")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            NavigationLink(destination: CreateAccount()) {
                Text("Create Account")
                    .foregroundColor(.blue)
                    .font(.subheadline)
                    .underline()
            }

            Button(action: {
                authManager.loginUser(username: username, password: password)
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()

            Spacer()
        }
        .padding()
    }

}
