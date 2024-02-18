import SwiftUI

struct ProfileAndPreferences: View {
    var username: String

    @State private var age: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var selectedLifestyle = 0
    let lifestyles = ["Sedentary", "Moderate", "Active", "Very Active"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    CustomTextField(placeholder: "Age", text: $age, keyboardType: .numberPad)
                    CustomTextField(placeholder: "Height (cm)", text: $height, keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Weight (kg)", text: $weight, keyboardType: .decimalPad)

                    
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
                    // Add fields for workout goals, preferences, etc.
                }

                Section(header: Text("Fitness Level")) {
                  
                    
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
