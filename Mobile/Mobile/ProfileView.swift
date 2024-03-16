import SwiftUI
var recommendedExerciseTime: Int = 0
var recommendedSleepTime: Double = 0.0
var recommendedCalorieIntake: Int = 0
var recommendedCaloriesToBurn: Int = 0
var recommendedDistanceToWalk: Int = 0
var recommendedStepsToWalk: Int = 0


class UserProfileData: ObservableObject {
    @Published var userProfile = UserProfile(firstName: "", lastName: "", gender: "", age: "", height: "", weight: "", activityLevel: "", goals: "", fitnessLevel: "")
}
struct ProfileView: View {
    @StateObject private var userProfileData = UserProfileData()
    @State private var profileData: UserProfile?
    
    @EnvironmentObject var userSettings: UserSettings

 

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            
            if let data = profileData {
                Text("Hi, \(data.firstName) \(data.lastName)")
                    .font(.custom("UhBee Se_hyun", size: 18))
                    .fontWeight(.bold)
                
              
              
                if let height = Double(data.height ?? ""), let weight = Double(data.weight ?? "") {
                    let heightInMeters = height / 100 // Convert height from cm to meters
                    let bmi = calculateBMI(weight: weight, height: heightInMeters)
                    let bmr = calculateBMR(data: data)
                    
                    VStack {
                        Text("Basal Metabolic Rate: \(bmr, specifier: "%.2f") Kcal")
                            .font(.title3)
                          
                        Text("Body Mass Index: \(bmi, specifier: "%.2f")")
                            .font(.title3)
                        
                            .padding(.bottom, 5)
                        
                        BMIProgressBar(bmi: bmi)
                            .frame(height: 20)
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                        
                        
                        Text("Recommended Calorie Intake: \(calculateRecommendedCalorieIntake(data: data)) Kcal/day")
                        

                        
                    }
                }
                Spacer()
                
                ProfileInfoView(label: "Gender", value: data.gender ?? "", userProfile: $userProfileData.userProfile, field: "gender")
                ProfileInfoView(label: "Age", value: data.age ?? "", userProfile: $userProfileData.userProfile, field: "age")
                ProfileInfoView(label: "Height", value: data.height ?? "", userProfile: $userProfileData.userProfile, field: "height_cm")
                ProfileInfoView(label: "Weight", value: data.weight ?? "", userProfile: $userProfileData.userProfile, field: "weight_kg")
                ProfileInfoView(label: "Activity Level", value: data.activityLevel ?? "", userProfile: $userProfileData.userProfile, field: "activity_level")
                ProfileInfoView(label: "Goals", value: data.goals ?? "", userProfile: $userProfileData.userProfile, field: "goals")
                ProfileInfoView(label: "Fitness Level", value: data.fitnessLevel ?? "", userProfile: $userProfileData.userProfile, field: "fitness_level")
//                Text("Recommendations:")
//                                    .font(.title)
//                                    .fontWeight(.bold)
//                                    .padding(.top)
//
                
                              
               


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
            print("username is: \(userSettings.username)")
            fetchData(for: userSettings.username)
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
        request.httpMethod = "GET" 
        
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


struct BMIProgressBar: View {
    var bmi: Double
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .opacity(0.3)
                        .foregroundColor(Color.gray)
                        .cornerRadius(5)
                    
                    HStack(spacing: 0) {
                        Color.blue.frame(width: geometry.size.width / 4)
                        Color.green.frame(width: geometry.size.width / 4)
                        Color.yellow.frame(width: geometry.size.width / 4)
                        Color.red.frame(width: geometry.size.width / 4)
                    }
                    
                    // Line or arrow indicating the user's BMI category
                    LineMarker(bmi: bmi, width: geometry.size.width)
                        .offset(x: offsetForBMI(bmi: bmi, width: geometry.size.width))
                }
                .cornerRadius(5.0)
                
                // Labels for each color category
                HStack {
                    Text("Underweight").frame(width: geometry.size.width / 4)
                    Text("Healthy Weight").frame(width: geometry.size.width / 4)
                    Text("Overweight").frame(width: geometry.size.width / 4)
                    Text("Obesity").frame(width: geometry.size.width / 4)
                }
                .foregroundColor(.black)
                .font(.caption)
            }
        }
        
    }
    
    func offsetForBMI(bmi: Double, width: CGFloat) -> CGFloat {
        let bmiCategories = [15.0, 18.5, 25.0, 30.0, 100.0]
        let categoryWidth = width / CGFloat(bmiCategories.count - 1)

        for i in 0..<bmiCategories.count - 1 {
            let lowerBound = bmiCategories[i]
            let upperBound = bmiCategories[i + 1]
            if bmi >= lowerBound && bmi < upperBound {
                let relativePosition = (bmi - lowerBound) / (upperBound - lowerBound)
                return CGFloat(i) * categoryWidth + relativePosition * categoryWidth
            }
        }

        print("here")
        return 0
    }

}

struct LineMarker: View {
    var bmi: Double
    var width: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Rectangle()
                .fill(Color.black)
                .frame(width: 2, height: 10)
            Triangle()
                .fill(Color.black)
                .frame(width: 10, height: 10)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private func calculateBMI(weight: Double, height: Double) -> Double {
        return weight / (height * height)
    }
    
    // Function to calculate BMR
    private func calculateBMR(data: UserProfile) -> Double {

        let age = Double(calculateAge(from: data.age)) ?? 0
            let weight = Double(data.weight) ?? 0
            let height = Double(data.height) ?? 0
            
            var bmr: Double = 0
            
            if data.gender.lowercased() == "male" {
                bmr = 66.5 + (13.75 * weight) + (5.003 * height) - (6.75 * age)
            } else {
                bmr = 655.1 + (9.563 * weight) + (1.850 * height) - (4.676 * age)
            }
        return bmr
    }

struct ProfileInfoView: View {
    @EnvironmentObject var userSettings: UserSettings
   
    var label: String
    @State var value: String
    @Binding var userProfile: UserProfile
    var field: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.black)

            Spacer()

            TextField("Enter \(label)", text: Binding(
                get: { self.value },
                set: { newValue in
                    self.value = newValue
                    self.updateUserProfileField(for: userSettings.username)
                    
                }
            ))
            .font(.subheadline)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }

    
    
    func updateUserProfileField(for username: String) {
        var update_data: [String: Any] = [
            "username": username,
            "height_cm": 185,
            "weight_kg": 78,
            "activity_level": "active",
            "goals": ["improve posture"],
            "fitness_level": "intermediate"
        ]
        
        switch field {
        case "gender":
            update_data["gender"] = value
        case "age":
            update_data["age"] = value
        case "height_cm":
            update_data["height_cm"] = value
        case "weight_kg":
            update_data["weight_kg"] = value
        case "activity_level":
            update_data["activity_level"] = value
        case "goals":
            update_data["goals"] = [value]
        case "fitness_level":
            update_data["fitness_level"] = value
        default:
            break
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: update_data) else {
            print("Error: Failed to serialize JSON data")
            return
        }
        
        guard let url = URL(string: "http://52.14.25.178:5000/update_profile") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                return
            }
            
            print("Response code: \(httpResponse.statusCode)")
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            // Handle response if needed
        }.resume()
    }

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



func calculateRecommendedExerciseTime(activityLevel: String) -> Int {
    var recommendedTime = 60 // Default value
    
    switch activityLevel {
    case "sedentary":
        recommendedTime = 30 // 30 minutes/day
    case "moderate":
        recommendedTime = 60 // 1 hour/day
    case "active":
        recommendedTime = 90 // 1.5 hours/day
    case "very active":
        recommendedTime = 120 // 2 hours/day
    default:
        return 99 // Default recommendation
    }
    
    recommendedExerciseTime = recommendedTime
    return recommendedTime
}


func calculateRecommendedSleepTime(age: Int) -> Double {
    var SleepTime: Double = 7.5
    if age < 18 {
        SleepTime = 8.0
    } else if age >= 65 {
        SleepTime = 7.0
    }
    recommendedSleepTime =  SleepTime
    return  SleepTime
}


func calculateRecommendedCalorieIntake(data: UserProfile) -> Int {
    let bmr = calculateBMR(data: data)
    var activityFactorDescription = ""
    var activityFactor: Double = 1.0
    switch data.activityLevel {
    case "sedentary":
        activityFactorDescription = "sedentary (1.2)"
        activityFactor = 1.2
    case "moderate":
        activityFactorDescription = "moderate (1.32)"
        activityFactor = 1.32
    case "active":
        activityFactorDescription = "active (1.43)"
        activityFactor = 1.42
    case "very active":
        activityFactorDescription = "very active (1.67)"
        activityFactor = 1.67
    default:
        activityFactorDescription = "default (1.32)"
        activityFactor = 1.32
    }
    
    var goalFactorDescription = ""
    var goalFactor: Double = 1.0
    switch data.goals {
    case "Weight Loss":
        goalFactorDescription = "Weight Loss (0.8)"
        goalFactor = 0.8
    case "Weight Gain":
        goalFactorDescription = "Weight Gain (1.2)"
        goalFactor = 1.2
    default:
        goalFactorDescription = "default (1.0)"
        goalFactor = 1.0
    }
    
    let recommendedCalories = Int(bmr * activityFactor * goalFactor)
    
    print("Basal Metabolic Rate (BMR): \(bmr)")
    print("Activity Level: \(activityFactorDescription)")
    print("Goal: \(goalFactorDescription)")
    print("Recommended Calories: \(recommendedCalories)")
    recommendedCalorieIntake = recommendedCalories
    return recommendedCalories
    
    
}




func calculateRecommendedCaloriesToBurn(data: UserProfile) -> Int {
    let intake = calculateRecommendedCalorieIntake(data: data)
    let bmr = Int(calculateBMR(data: data))
    
    recommendedCaloriesToBurn = (intake - bmr)/2
    return  (intake - bmr)/2
}

func calculateRecommendedDistanceToWalk(data: UserProfile) -> Int {
   
    let stepsPerKilometer = 1300
    

    var recommendedStepsPerDay = 10000
    
    let age = Int(data.age) ?? 0
    let gender = data.gender.lowercased()
    let fitnessLevel = data.fitnessLevel.lowercased()
    
  
    if age >= 65 {
        recommendedStepsPerDay += 2000
    }
    
    // Adjust recommended steps based on gender and fitness level
    if gender == "male" {
        if fitnessLevel == "beginner" {
            recommendedStepsPerDay -= 1000 // Decrease for beginner males
        } else if fitnessLevel == "advanced" {
            recommendedStepsPerDay += 1000 // Increase for advanced males
        }
    } else {
        if fitnessLevel == "beginner" {
            recommendedStepsPerDay -= 500 // Decrease for beginner females
        } else if fitnessLevel == "advanced" {
            recommendedStepsPerDay += 500 // Increase for advanced females
        }
    }
    
    // Calculate the recommended distance to walk in kilometers
    let recommendedDistanceInKilometers = Double(recommendedStepsPerDay) / Double(stepsPerKilometer)
    
    // Convert the distance to walk from kilometers to meters
    let recommendedDistanceInMeters = Int(recommendedDistanceInKilometers * 1000)
    recommendedDistanceToWalk = recommendedDistanceInMeters
    
    recommendedStepsToWalk = Int(1.2*Double(recommendedDistanceToWalk))
    return recommendedDistanceInMeters
}


func calculateAge(from dateString: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"

        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MM/dd/yy"
            let stringFormattedDate = dateFormatter.string(from: date)

            if let dateOfBirth = dateFormatter.date(from: stringFormattedDate) {
                let calendar = Calendar.current
                let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
                return ageComponents.year ?? 0
            } else {
                return 0
            }
        } else {
            return 0
        }
    }


