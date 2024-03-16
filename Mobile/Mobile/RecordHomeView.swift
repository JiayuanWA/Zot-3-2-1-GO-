import SwiftUI
var exerciseRecords: [(id: Int, formattedDate: String, exerciseType: String, duration: Double, calories: Double)] = []



extension Date {
    
    static func startOfWeekDates() -> [Date] {
        let startOfWeek = Date.startOfWeek
        let calendar = Calendar.current

        return (0..<7).map { day in
            calendar.date(byAdding: .day, value: day, to: startOfWeek)!
        }
    }
}

class UserPreferences: ObservableObject {
    @Published var selectedDate: Date?
}


struct RecordHomeView: View {
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var userProfileData: UserProfileData
    @State private var profileData: UserProfile?
    
    @EnvironmentObject var manager: HealthKit
    @State private var firstName: String = ""

    @StateObject var userPreferences = UserPreferences()
    @State private var showAlert = false
    @State private var isSurveyActive: Bool = false
    @State private var hasUserTakenSurveyToday = false
    @State private var exerciseDuration: Double = 0
    @State private var isLoggingWorkoutActive = false
    @State private var isLoggingFoodActive = false
    @State private var isLoggingBodyMetricsActive = false

    @State private var totalCaloriesBurned: Double = 0

    var body: some View {
        VStack(alignment: .center) {
            
            
            Text("Welcome, \(userSettings.username)")
                .font(.custom("UhBee Se_hyun", size: 24))
                .fontWeight(.bold)
            
            
            
            if let selectedDate = userPreferences.selectedDate {
                Text("Selected Date: \(selectedDate, style: .date)")
                    .font(.custom("UhBee Se_hyun", size: 14))
                    .padding(.top,1 )
                
            }
            
            
            if let userProfile = profileData{

                WeekProgressView(selectedDate: $userPreferences.selectedDate, startOfWeekDates: Date.startOfWeekDates())
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                if let stepData = manager.activities["today Steps"] {
                    let stepCount = Double(stepData.amount) ?? 0
                    let goal = 2000.0
                    
                    
                    
                    
                    ProgressItem(title: "Recommended Steps: \(Int(1.2 * Double(calculateRecommendedDistanceToWalk(data: userProfile)))) steps/day", value: stepCount, goal: Double(recommendedStepsToWalk))
                        .padding(.top, 20)
                        .foregroundColor(.blue)
                        .padding(.horizontal)
                }
                
                
                if let distanceData = manager.activities["today Distance"] {
                    let distanceCount = Double(distanceData.amount) ?? 3
                    
                    ProgressItem(title: "Distance Walked", value: distanceCount, goal: Double(recommendedDistanceToWalk))
                        .foregroundColor(.green)
                    
                    
                        .padding(.horizontal)
                }
                
                
                ProgressItem(title: "Recommended Exercise Time: \(calculateRecommendedExerciseTime(activityLevel: userProfile.activityLevel)) minutes/day", value: exerciseDuration, goal: Double(recommendedExerciseTime))
                    .foregroundColor(.purple)
                    .padding(.horizontal)
                ProgressItem(title: "Recommended Calories to Burn: \(calculateRecommendedCaloriesToBurn(data: userProfile)) Kcal/day", value: totalCaloriesBurned, goal: Double(recommendedCaloriesToBurn))
                    .foregroundColor(.red)
                    .padding(.horizontal)
                if let sleepData = manager.activities["today Sleep"] {
                    let Count = Double(sleepData.amount) ?? 0
                    
                    ProgressItem(title: "Recommended Sleep Time: \(calculateRecommendedSleepTime(age: calculateAge(from: userProfile.age))) hours/day", value: Count, goal:  recommendedSleepTime)
                        .foregroundColor(.orange)
                    
                        .padding(.horizontal)
                }
                
            }
            
            
            
            
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            showAlert = true
            fetchData(for: userSettings.username)
            fetchExerciseDuration(for: userSettings.username)
            
            
            
            if let savedPreferences = UserDefaults.standard.dictionary(forKey: "userPreferences") as? [String: Any] {
                self.firstName = savedPreferences["firstName"] as? String ?? ""
            }
            userPreferences.selectedDate = Date()
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
            
            manager.fetchSleepData(startDate: startOfDay, endDate: endOfDay)
            exerciseDuration = calculateExerciseDuration()
            totalCaloriesBurned = calculateTotalCaloriesBurned()

        }
        
        .onReceive(manager.$activities) { _ in
            print("Activities changed. Updating UI.")
            exerciseDuration = calculateExerciseDuration()
            totalCaloriesBurned = calculateTotalCaloriesBurned()
            
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
    func calculateTotalCaloriesBurned() -> Double {
        guard let selectedDate = userPreferences.selectedDate else { return 0 }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy" // Adjust the format according to your needs

        let selectedDateString = dateFormatter.string(from: selectedDate)

        let totalCaloriesBurned = exerciseRecords.reduce(0.0) { (result, record) in
            if record.formattedDate == selectedDateString {
                return result + record.calories
            } else {
                return result
            }
        }

        return totalCaloriesBurned
    }


    func calculateExerciseDuration() -> Double {
        guard let selectedDate = userPreferences.selectedDate else { return 0 }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        let selectedDateString = dateFormatter.string(from: selectedDate)

        let totalDuration = exerciseRecords.reduce(0.0) { (result, record) in
            print("Record Formatted Date: \(record.formattedDate)")
            if record.formattedDate == selectedDateString {
                return result + record.duration
            } else {
                return result
            }
        }


        print("Selected Date String: \(selectedDateString)")
        print("i got total \(totalDuration)")

        return totalDuration
    }

    func fetchExerciseDuration(for username: String) {
        exerciseRecords.removeAll() 

        let urlString = "http://52.14.25.178:5000/get_exercise_records/\(username)"
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

            print("Retrieved data: \(String(data: data, encoding: .utf8) ?? "Unknown")")

            print("Retrieved JSON: \(data)")

            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[Any]] {
                    var recordID = 0

                    for record in jsonArray {
                        if record.count >= 4,
                            let dateString = record[0] as? String,
                            let duration = record[2] as? Double,
                            let calories = record[3] as? Double,
                            let exerciseType = record[1] as? String {
                                recordID += 1

                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
                                if let date = dateFormatter.date(from: dateString) {
                                    dateFormatter.dateFormat = "MM/dd/yy"
                                    let stringFormattedDate = dateFormatter.string(from: date)

                                    let recordData = (id: recordID, formattedDate: stringFormattedDate, exerciseType: exerciseType, duration: duration, calories: calories)
                                    exerciseRecords.append(recordData)
                                } else {
                                    print("Error parsing date: \(dateString)")
                                }
                        }
                    }
                    print("exerciseRecords: \(exerciseRecords)")
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }


}
struct RecordListView: View {
    let records: [(id: Int, formattedDate: String, exerciseType: String, duration: Double, calories: Double)]


    var body: some View {
        List(records, id: \.id) { record in
            RecordView(formattedDate: record.formattedDate,
                        exerciseType: record.exerciseType,
                        duration: record.duration,
                        calories: record.calories)
        }
    }
}

struct RecordView: View {
    

    let formattedDate: String
    let exerciseType: String
    let duration: Double
    let calories: Double

    var body: some View {
        VStack(alignment: .leading) {
            Text("Date: \(formattedDate)")
            Text("Exercise Type: \(exerciseType)")
            Text("Duration: \(duration)")
            Text("Calories: \(calories)")
        }
        .padding()
    }
}

struct ProgressItem: View {
    var title: String
    var value: Double
    var goal: Double

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.custom("UhBee Se_hyun", size: 12))
                    .padding(.bottom, 4)

                Spacer()
            }

            HStack {
                ZStack(alignment: .leading) {
                    ProgressView(value: value, total: goal)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(height: 10)
                }

                Spacer()

                Text(String(format: "%.2f", value) + "/" + String(format: "%.2f", goal))
                    .font(.custom("UhBee Se_hyun", size: 12))
                                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}



struct WeekProgressView: View {
    @Binding var selectedDate: Date?
    @EnvironmentObject var manager: HealthKit
    let startOfWeekDates: [Date]

    var body: some View {
        LazyHGrid(rows: [GridItem()], spacing: 10) {
            ForEach(0..<7) { day in
  
                DayProgressView(
                    startDate: startOfWeekDates[day],
                    selectedDate: $selectedDate,
                    caloriesBurnedPercentage: 0.8,
                    stepsWalkedPercentage: 0.5,
                    minutesExercisedPercentage: 0.4
                )
                .onTapGesture {
                    selectedDate = startOfWeekDates[day]
                    print("Selected Date Updated: \(selectedDate ?? Date())")
                }

            }
        }
        .onChange(of: selectedDate) { newDate in
        
            print("Selected Date: \(newDate ?? Date())")


            if let date = newDate {
                let calendar = Calendar.current
                let startDate = calendar.startOfDay(for: date)
                print("Start Date: \(startDate)")

                if let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startDate) {
                            print("Start Date: \(startDate), End Date: \(endDate)")
                            manager.fetchSteps(startDate: startDate, endDate: endDate)
                            manager.fetchWalkingRunningDistance(startDate: startDate, endDate: endDate)
                    manager.fetchSleepData(startDate: startDate, endDate: endDate)
                    print("Activities Dictionary: \(manager.activities)")
                               
                           
                        }
            }
        }

    }
}

struct DayProgressView: View {
    let startDate: Date
    let selectedDate: Binding<Date?>
    let caloriesBurnedPercentage: Double
    let stepsWalkedPercentage: Double
    let minutesExercisedPercentage: Double

    var isSelected: Bool {
        if let selectedDate = selectedDate.wrappedValue {
            return Calendar.current.isDate(startDate, inSameDayAs: selectedDate)
        } else {
            return false
        }
    }

    var body: some View {
        VStack {
            Text(dayOfWeekString(startDate))
                .font(.custom("UhBee Se_hyun", size: 12))
                .foregroundColor(.secondary)

            ZStack {
                Circle()
                    .trim(from: 0.0, to: CGFloat(caloriesBurnedPercentage))
                    .stroke(isSelected ? Color.orange : Color.gray, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 30, height: 30)
                    .rotationEffect(.degrees(-90))

                Circle()
                    .trim(from: 0.0, to: CGFloat(stepsWalkedPercentage))
                    .stroke(isSelected ? Color.green : Color.gray, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))

                Circle()
                    .trim(from: 0.0, to: CGFloat(minutesExercisedPercentage))
                    .stroke(isSelected ? Color.blue : Color.gray, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
            }
            .onTapGesture {
                selectedDate.wrappedValue = isSelected ? nil : startDate
            }

            Text(dateString(startDate))
                .font(.custom("UhBee Se_hyun", size: 12))
                .foregroundColor(.secondary)
        }
    }

    private func dayOfWeekString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: date)
    }

    private func dateString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        return dateFormatter.string(from: date)
    }
}
