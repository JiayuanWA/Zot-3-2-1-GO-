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
                        print("here")
//                        networkManager.registerUser(
//                            username: username,
//                            password: password,
//                            first_name:first_name,
//                            last_name: last_name,
//                            gender: gender,
//                            date_of_birth: date_of_birth,
//                            height: height,
//                            weight: weight,
//                            activity_level: activity_level,
//                            goals: goals,
//                            fitness_level: fitness_level
//                        )
                        
                    
                        
                        networkManager.registerUser(username: username, password: password, firstName: "N", lastName: "Y", gender: "male", dateOfBirth: "2002-12-21", height: 10, weight: 20, activityLevel: "active", goals: ["lose weight", "improve cardio"], fitnessLevel:"intermediate")
                       
                        
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


