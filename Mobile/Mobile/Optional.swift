import SwiftUI

struct Optional: View {
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
      ]
      
      var body: some View {
          NavigationView {
              VStack {
                  Form {
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
                  
                  NavigationLink(destination: ContentView().navigationBarHidden(true), isActive: $isSaved) {
                      Button(action: {
                          let preferences: [String: Any] = [
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
              .navigationBarItems(trailing:
                  Button(action: {
                      // Action for skip button
                  }) {
                      Text("Skip")
                  }
              )
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
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
        }
    }
}
