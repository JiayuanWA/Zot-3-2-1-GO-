import SwiftUI

struct ProfileView: View {
    @State private var profileData: UserProfile?
    @State public var  username: String = "Alice" // Assuming you have a way to get the username
    
    @State private var userProfile = UserProfile(firstName: "", lastName: "", gender: "", age: "", height: "", weight: "", activityLevel: "", goals: "", fitnessLevel: "")

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let data = profileData {
                Text("Hi, \(data.firstName) \(data.lastName)")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                ProfileInfoView(label: "Gender", value: data.gender ?? "", userProfile: $userProfile, field: "gender")
                ProfileInfoView(label: "Age", value: data.age ?? "", userProfile: $userProfile, field: "age")
                ProfileInfoView(label: "Height", value: data.height ?? "", userProfile: $userProfile, field: "height_cm")
                ProfileInfoView(label: "Weight", value: data.weight ?? "", userProfile: $userProfile, field: "weight_kg")
                ProfileInfoView(label: "Activity Level", value: data.activityLevel ?? "", userProfile: $userProfile, field: "activity_level")
                ProfileInfoView(label: "Goals", value: data.goals ?? "", userProfile: $userProfile, field: "goals")
                ProfileInfoView(label: "Fitness Level", value: data.fitnessLevel ?? "", userProfile: $userProfile, field: "fitness_level")
                
            } else {
                Text("Loading...")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            fetchData(for: username)
        }
    }

    func fetchData(for username: String) {
        // Construct the URL with username parameter
        let urlString = "http://52.14.25.178:5000/profile/\(username)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Specify GET method
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                return
            }
            
            print("Response code: \(httpResponse.statusCode)")
            
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let userInfo = json["user_info"] as? [String: Any] {
                    print("Retrieved JSON: \(json)")
                    
                    // Parse the user info
                    let firstName = userInfo["first_name"] as? String ?? ""
                    let lastName = userInfo["last_name"] as? String ?? ""
                    let gender = userInfo["gender"] as? String
                    let age = userInfo["date_of_birth"] as? String
                    let height = userInfo["height_cm"] as? String
                    let weight = userInfo["weight_kg"] as? String
                    let activityLevel = userInfo["activity_level"] as? String
                    let goals = userInfo["goals"] as? String
                    let fitnessLevel = userInfo["fitness_level"] as? String
                    
                    // Create UserProfile object
                    let userProfile = UserProfile(firstName: firstName, lastName: lastName, gender: gender ?? "", age: age ?? "", height: height ?? "", weight: weight ?? "", activityLevel: activityLevel ?? "", goals: goals ?? "", fitnessLevel: fitnessLevel ?? "")
                    
                    DispatchQueue.main.async {
                        self.profileData = userProfile
                    }
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct ProfileInfoView: View {
    @State public var  username: String = "Alice"
    var label: String
    @State var value: String
    @Binding var userProfile: UserProfile
    var field: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.blue)

            Spacer()

            TextField("Enter \(label)", text: Binding(
                get: { self.value },
                set: { newValue in
                    self.value = newValue
                    
                }
            ))
            .font(.subheadline)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }

//    func updateUserProfileField(for username: String) {
//        var update_data: [String: Any] = [
//            "username": username,
//            "height_cm": 130,
//            "weight_kg": 150,
//            "activity_level": "active",
//            "goals": ["improve posture"],
//            "fitness_level": "intermediate"
//        ]
//        
//        switch field {
//        case "gender":
//            update_data["gender"] = value
//        case "age":
//            update_data["age"] = value
//        case "height_cm":
//            update_data["height_cm"] = value
//        case "weight_kg":
//            update_data["weight_kg"] = value
//        case "activity_level":
//            update_data["activity_level"] = value
//        case "goals":
//            update_data["goals"] = [value]
//        case "fitness_level":
//            update_data["fitness_level"] = value
//        default:
//            break
//        }
//        
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: update_data) else {
//            print("Error: Failed to serialize JSON data")
//            return
//        }
//        
//        guard let url = URL(string: "http://52.14.25.178:5000/update_profile") else {
//            print("Invalid URL")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("Invalid HTTP response")
//                return
//            }
//            
//            print("Response code: \(httpResponse.statusCode)")
//            
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                return
//            }
//            
//            // Handle response if needed
//        }.resume()
//    }

}

struct UserProfile {
    var firstName: String
    var lastName: String
    var gender: String
    var age: String
    var height: String
    var weight: String
    var activityLevel: String
    var goals: String
    var fitnessLevel: String
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

