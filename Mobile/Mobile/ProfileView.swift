import SwiftUI

struct ProfileView: View {
    @State private var profileData: UserProfile?
    let username: String = "never" // Assuming you have a way to get the username

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let data = profileData {
                Text("Hi, \(data.firstName) \(data.lastName)")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                ProfileInfoView(label: "Gender", value: data.gender)
                ProfileInfoView(label: "Age", value: "\(data.age)")
                ProfileInfoView(label: "Height", value: "\(data.height) cm")
                ProfileInfoView(label: "Weight", value: "\(data.weight) kg")
                ProfileInfoView(label: "Activity Level", value: data.activityLevel)
                ProfileInfoView(label: "Goals", value: data.goals.joined(separator: ", "))
                ProfileInfoView(label: "Fitness Level", value: data.fitnessLevel)
                ProfileInfoView(label: "Workout Days", value: data.workoutDays.joined(separator: ", "))
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
        // Make GET request to retrieve user's profile data
        guard let url = URL(string: "http://52.14.25.178:5000/profile/idlice3") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                return
            }
            
            print("Response code: \(httpResponse.statusCode)")
            
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
//            do {
//                let decoder = JSONDecoder()
//                let userData = try decoder.decode(UserProfile.self, from: data)
//                
//                DispatchQueue.main.async {
//                    self.profileData = userData
//                }
//            } catch {
//                print("Error decoding JSON: \(error.localizedDescription)")
//            }
        }.resume()
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

struct UserProfile: Codable {
    var firstName: String
    var lastName: String
    var gender: String
    var age: Int
    var height: Int
    var weight: Int
    var activityLevel: String
    var goals: [String]
    var fitnessLevel: String
    var workoutDays: [String]
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
