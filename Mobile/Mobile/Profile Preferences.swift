import SwiftUI

struct ProfileAndPreferences: View {
    var username: String
    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var gender: String = ""

    @State private var selectedLifestyle = 0
    @State private var selectedFitnessLevel = 0
    @State private var selectedDays: Set<String> = []
    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    let lifestyles = ["Sedentary", "Moderate", "Active", "Very Active"]
    @State private var isSaved = false

    @State private var selectedGoals: Set<String> = []
    let workoutGoals = [
        "Build Muscle",
        "Lose Weight",
        "Improve Cardio",
        "Better Lifestyle",
        "Improve Sleep Quality",
        "Improve Posture",
        "Increase Flexibility",
        "Achieve Mental Clarity"
    ]

    let fitnessLevels = [
        "Beginner",
        "Intermediate",
        "Advanced"
        // Add more fitness levels as needed
    ]

    var body: some View {
        NavigationView {
            VStack {
                Form {
                              Section(header: Text("Personal Information")) {
                                  CustomTextField(placeholder: "First Name", text: $firstname, keyboardType: .default)
                                  CustomTextField(placeholder: "Last Name", text: $lastname, keyboardType: .default)



                                  CustomTextField(placeholder: "Age", text: $age, keyboardType: .numberPad)
                                  CustomTextField(placeholder: "Height (cm)", text: $height, keyboardType: .decimalPad)
                                  CustomTextField(placeholder: "Weight (kg)", text: $weight, keyboardType: .decimalPad)
                                  Picker("Gender", selection: $gender) {
                                      Text("Select Gender").tag("") // Default empty value
                                      ForEach(["Male", "Female", "Other", "Prefer not to say"], id: \.self) { option in
                                          Text(option)
                                      }
                                  }
                                  .padding(.vertical, 8)
                                  .padding(.horizontal, 16)
                                  .font(.subheadline)
                                  
                              }
                              
                              Section(header: Text("Activity Level")) {
                                  // Add fields for fitness level, experience, etc.
                                  Picker("Lifestyle", selection: $selectedLifestyle) {
                                      ForEach(0..<lifestyles.count) {
                                          Text(self.lifestyles[$0])
                                      }
                                  }
                                  .pickerStyle(SegmentedPickerStyle())
                                  
                              }
                              
                              Section(header: Text("Goals")) {
                                  List {
                                      ForEach(workoutGoals, id: \.self) { goal in
                                          Toggle(goal, isOn: Binding(
                                            get: {
                                                selectedGoals.contains(goal)
                                            },
                                            set: { newValue in
                                                if let index = selectedGoals.firstIndex(of: goal) {
                                                    selectedGoals.remove(at: index)
                                                } else {
                                                    selectedGoals.insert(goal)
                                                }
                                            }
                                          ))
                                      }
                                  }
                              }
                              
                              
                              Section(header: Text("Fitness Level")) {
                                  Picker("Select Fitness Level", selection: $selectedFitnessLevel) {
                                      ForEach(0..<fitnessLevels.count) {
                                          Text(self.fitnessLevels[$0])
                                      }
                                  }
                                  
                                  
                                  .pickerStyle(SegmentedPickerStyle())
                              }
                              Section(header: Text("Select Workout Days")) {
                                  List {
                                      ForEach(daysOfWeek, id: \.self) { day in
                                          Toggle(day, isOn: Binding(
                                            get: { selectedDays.contains(day) },
                                            set: { newValue in
                                                if selectedDays.contains(day) {
                                                    selectedDays.remove(day)
                                                } else {
                                                    selectedDays.insert(day)
                                                }
                                            }
                                          ))
                                      }
                                  }
                              }
                          }
            
                NavigationLink(destination: ContentView(), isActive: $isSaved) {
                                    Button(action: {
                                        let preferences: [String: Any] = [
                                            "firstName": firstname, // Assuming you have a variable named firstName
                                            "lastName": lastname,   // Assuming you have a variable named lastName
                                            "age": age,
                                            "height": height,
                                            "weight": weight,
                                            "lifestyle": lifestyles[selectedLifestyle],
                                            "fitnessLevel": fitnessLevels[selectedFitnessLevel],
                                            "selectedGoals": Array(selectedGoals),
                                            "selectedDays": Array(selectedDays)
                                        ]


                                        UserDefaults.standard.set(preferences, forKey: "userPreferences")
                                        isSaved = true
                                    }) {
                                        Text("Save and return to login")
                                            .foregroundColor(.white)
                                            .font(.headline)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.blue)
                                            .cornerRadius(8)
                                    }
                                    .padding()
                                }
                            }
                            .navigationBarHidden(true)
                        }
                    }
                }


struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType

    var body: some View {
        HStack {
            Text(placeholder)
                .foregroundColor(.secondary)
                .font(.body)

            Spacer()

            TextField("", text: $text)
                .keyboardType(keyboardType)
                .padding(.vertical, 8)  // Adjust vertical padding
                .padding(.horizontal, 16) // Adjust horizontal padding
                .font(.subheadline)  // Adjust font size
                .multilineTextAlignment(.trailing) // Align text to the right
        }
    }
}
