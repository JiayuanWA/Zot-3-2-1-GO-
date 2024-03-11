import SwiftUI
struct CreateAccount: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isAccountCreated = false
    @State private var isNavigationBarHidden = true
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Create Account")
                    .font(.custom("UhBee Se_hyun", size: 24))
                    .fontWeight(.bold)

                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                NavigationLink( 
                    destination: ProfileAndPreferences(username: username)
                        .navigationBarHidden(isNavigationBarHidden)
                        .onAppear {
                            isNavigationBarHidden = true
                        },
                    isActive: $isAccountCreated
                ) {
                    EmptyView()
                }
                .hidden()

                Button(action: {
                    if password == confirmPassword {
                        isAccountCreated = true
                    } else {
                        print("Passwords don't match")
                                                                }
                    
                }) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .font(.custom("UhBee Se_hyun", size: 18))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()

                Spacer()
            }
            .background(
                Image("Wallpaper")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
            )
            .padding()
            .navigationBarHidden(true)
        }
    }
}
