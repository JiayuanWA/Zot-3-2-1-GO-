import SwiftUI

struct ProfileAndPreferences: View {
    var username: String
    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var age: String = ""
    let networkManager = NetworkManager()
    var password: String
    
    @State private var height: String = ""
    @State private var weight: String = ""
    
    @State private var newheight: Int = 0
    @State private var newweight: Int = 0
    
    @State private var gender: String = ""
    
    @State private var isFirstNameValid = false
    @State private var isLastNameValid = false
    @State private var isAgeValid = false
    @State private var isHeightValid = false
    @State private var isWeightValid = false
    @State private var isGenderValid = false
    
    @State private var isSaved = false
    
    @State private var errorMessage: String = ""
    @State private var showErrorAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Basic Profile")
                    .font(.custom("UhBee Se_hyun", size: 24))
                    .fontWeight(.bold)

                Form {
                    Section(header: Text("Personal Information")) {
                        CustomTextField(placeholder: "First Name", text: $firstname, keyboardType: .default)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .onChange(of: firstname) { newValue in
                                isFirstNameValid = !newValue.isEmpty
                            }
                        
                        CustomTextField(placeholder: "Last Name", text: $lastname, keyboardType: .default)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .onChange(of: lastname) { newValue in
                                isLastNameValid = !newValue.isEmpty
                            }
                        
                        CustomTextField(placeholder: "Date of Birth (YYYY-MM-DD)", text: $age, keyboardType: .default)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .onChange(of: age) { newValue in
                                isAgeValid = !newValue.isEmpty
                            }
                        
                        CustomTextField(placeholder: "Height (cm)", text: $height, keyboardType: .decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .onChange(of: height) { newValue in
                                isHeightValid = !newValue.isEmpty
                            }
                        
                        CustomTextField(placeholder: "Weight (kg)", text: $weight, keyboardType: .decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .onChange(of: weight) { newValue in
                                isWeightValid = !newValue.isEmpty
                            }
                        
                        Picker("Gender", selection: $gender) {
                            Text("Select Gender").tag("")
                            ForEach(["Male", "Female", "Other", "Prefer not to say"], id: \.self) { option in
                                Text(option)
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .onChange(of: gender) { newValue in
                            isGenderValid = !newValue.isEmpty
                        }
                    }
                }
                
                NavigationLink(destination: Optional(username: username).navigationBarHidden(true), isActive: $isSaved) {
                                    Button(action: {
                                        if isFormValid() {
                                            if let convertedHeight = Int(height), let convertedWeight = Int(weight) {
                                                // Proceed with submission
                                                // Reset form states
                                                isFirstNameValid = false
                                                isLastNameValid = false
                                                isAgeValid = false
                                                isHeightValid = false
                                                isWeightValid = false
                                                isGenderValid = false
                                                
                                                errorMessage = ""
                                                showErrorAlert = false
                                                print("Username saved", username)
                                                
                                                // Proceed with submission
                                                networkManager.registerUser(username: username, password: password, firstName: firstname, lastName: lastname, gender: gender, dateOfBirth: age, height: convertedHeight, weight: convertedWeight, activityLevel: "moderate", goals: ["improve cardio"], fitnessLevel:"intermediate")
                                                let preferences: [String: Any] = [
                                                    "firstName": firstname,
                                                    "lastName": lastname,
                                                    "age": age,
                                                    "height": convertedHeight,
                                                    "weight": convertedWeight
                                                ]
                                                UserDefaults.standard.set(preferences, forKey: "userPreferences")
                                                isSaved = true
                                            } else {
                                                errorMessage = "Invalid height or weight format."
                                                showErrorAlert = true
                                            }
                                        } else {
                                            errorMessage = "Please fill out all required fields."
                                            showErrorAlert = true
                                        }
                                    }) {
                                        Text("Submit")
                                    }
                                    .padding()
                                }
                                .alert(isPresented: $showErrorAlert) {
                                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                                }
                            }
                            .navigationBarHidden(true)
                            
                        }
                    }
                    
    private func isFormValid() -> Bool {
        return isFirstNameValid && isLastNameValid && isAgeValid && isHeightValid && isWeightValid && isGenderValid
    }
}
