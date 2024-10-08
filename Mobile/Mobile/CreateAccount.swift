import SwiftUI
struct CreateAccount: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isAccountCreated = false
    @State private var isNavigationBarHidden = true
    @Environment(\.presentationMode) var presentationMode
    let networkManager = NetworkManager()
    @State private var first_name: String = ""
    @State private var last_name: String = ""
    @State private var date_of_birth: String = ""

    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var age: String = ""
    
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var gender: String = ""

    @State private var activity_level = 0
    @State private var goals = 0
    @State private var selectedDays: Set<String> = []
    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    let fitness_level = ["Sedentary", "Moderate", "Active", "Very Active"]
    
    var body: some View {
        NavigationView {
            VStack() {
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
                    destination: ProfileAndPreferences(username: username, password: password)
                        .navigationBarHidden(true)
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
                        print("here")

                        
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
            
            .padding()
            .navigationBarHidden(true)
            .background(
                Image("Wallpaper")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
            )
            
            
            
        }
    }
    

}


