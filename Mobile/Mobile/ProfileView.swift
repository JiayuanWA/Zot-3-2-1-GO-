import SwiftUI

struct ProfileView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var gender: String = ""
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var selectedLifestyle = 0
    @State private var selectedFitnessLevel = 0
    @State private var selectedDays: Set<String> = []
    @State private var selectedGoals: Set<String> = []
    let fitnessLevels = [
        "Beginner",
        "Intermediate",
        "Advanced"
    ]


    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Hi, \(firstName) \(lastName)")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()

                VStack(alignment: .leading, spacing: 10) {
                    ProfileInfoView(label: "Gender", value: gender)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)

                    ProfileInfoView(label: "Age", value: age)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)

                    ProfileInfoView(label: "Height", value: height)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)

                    ProfileInfoView(label: "Weight", value: weight)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)

                    ProfileInfoView(label: "Activity Level", value: selectedLifestyle == 0 ? "Sedentary" :
                                                                     selectedLifestyle == 1 ? "Moderate" :
                                                                     selectedLifestyle == 2 ? "Active" :
                                                                     "Very Active")
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)

                    ProfileInfoView(label: "Goals", value: selectedGoals.joined(separator: ", "))
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)

                    ProfileInfoView(label: "Fitness Level", value: fitnessLevels[selectedFitnessLevel])
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)

                    ProfileInfoView(label: "Workout Days", value: selectedDays.isEmpty ? "Not selected" : selectedDays.joined(separator: ", "))
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }

                .padding(20)


                NavigationLink(
                    destination: ExerciseListView(),
                    label: {
                        Text("View Past Exercises")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                )
                .padding()
            }
            .padding()
            .onAppear {
                // Retrieve data from user preferences
                if let savedPreferences = UserDefaults.standard.dictionary(forKey: "userPreferences") as? [String: Any] {
                    self.firstName = savedPreferences["firstName"] as? String ?? ""
                    self.lastName = savedPreferences["lastName"] as? String ?? ""
                    self.gender = savedPreferences["gender"] as? String ?? ""
                    self.age = savedPreferences["age"] as? String ?? ""
                    self.height = savedPreferences["height"] as? String ?? ""
                    self.weight = savedPreferences["weight"] as? String ?? ""
                    
                    if let selectedLifestyle = savedPreferences["selectedLifestyle"] as? Int {
                        self.selectedLifestyle = selectedLifestyle
                    }
                    
                    if let selectedFitnessLevel = savedPreferences["selectedFitnessLevel"] as? Int {
                        self.selectedFitnessLevel = selectedFitnessLevel
                    }
                    
                    if let selectedGoals = savedPreferences["selectedGoals"] as? [String] {
                        self.selectedGoals = Set(selectedGoals)
                    }
                    
                    if let selectedDays = savedPreferences["selectedDays"] as? [String] {
                        self.selectedDays = Set(selectedDays)
                    }
                }
            }

        }
    }
}

struct ProfileInfoView: View {
    var label: String
    var value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.blue)

            Spacer()

            Text(value)
                .font(.subheadline)
        }
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
