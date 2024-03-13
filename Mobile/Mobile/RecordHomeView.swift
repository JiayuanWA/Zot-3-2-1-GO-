import SwiftUI

extension Date {
    
    static func startOfWeekDates() -> [Date] {
        let startOfWeek = Date.startOfWeek
        let calendar = Calendar.current

        return (0..<7).map { day in
            calendar.date(byAdding: .day, value: day, to: startOfWeek)!
        }
    }
}




struct RecordHomeView: View {
    @EnvironmentObject var manager: HealthKit
    @State private var firstName: String = ""
    @State private var username: String = ""
    @State private var selectedDate: Date?
    @State private var showAlert = false
    @State private var isSurveyActive: Bool = false
    @State private var hasUserTakenSurveyToday = false
    
    @State private var isLoggingWorkoutActive = false
    @State private var isLoggingFoodActive = false
    @State private var isLoggingBodyMetricsActive = false
    

    var body: some View {
        VStack(alignment: .center) {
            Text("Welcome, \(firstName)")
                .font(.custom("UhBee Se_hyun", size: 24))
                .fontWeight(.bold)
            
                .padding()
      
            Button(action: {
                isSurveyActive.toggle()
            }) {
                Text("How are you feeling today?")
            }
            .padding()
            .sheet(isPresented: $isSurveyActive) {
                DailyDecisionSurveyView(selectedDate: $selectedDate)
            }
            .padding(.top, 20)
            .padding(.horizontal)

            WeekProgressView(selectedDate: $selectedDate, startOfWeekDates: Date.startOfWeekDates())
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 10)

            if let stepData = manager.activities["today Steps"] {
                let stepCount = Double(stepData.amount) ?? 0
                let goal = 2000.0
                

                if let selectedDate = selectedDate {
                    Text("\(selectedDate, style: .date)")
                        .font(.custom("UhBee Se_hyun", size: 12))
                        .padding(.top, 10)
                        .padding(.horizontal)
                }

                ProgressItem(title: "Steps Walked", value: stepCount, goal: goal)
                    .padding(.top, 20)
                    .foregroundColor(.blue)
                    .padding(.horizontal)
            }


            if let distanceData = manager.activities["today Distance"] {
                let distanceCount = Double(distanceData.amount) ?? 3
                let distanceGoal = 2.0

                ProgressItem(title: "Distance Walked", value: distanceCount, goal: distanceGoal)
                    .foregroundColor(.green)
                    .padding(.top, 20)
                    .padding(.horizontal)
            }

            if let sleepData = manager.activities["today Sleep"] {
                let Count = Double(sleepData.amount) ?? 0
                let Goal = 8.0

                ProgressItem(title: "Sleep Duration", value: Count, goal: Goal)
                    .foregroundColor(.orange)
                           .padding(.top, 20)
                           .padding(.horizontal)
                   }
           


            Button(action: {
                        isLoggingWorkoutActive.toggle()
                    }) {
                        HStack {
                            Text("Workout")
                                .font(.custom("UhBee Se_hyun", size: 18))
                                .foregroundColor(.white)
                            Image(systemName: "figure.run")
                                .font(.custom("UhBee Se_hyun", size: 18))
                                .foregroundColor(.white)
                                .padding(.trailing, 10)
                        }
                    }
                    .frame(maxWidth: 300, maxHeight: 20)
                    .padding()
                    .background(.gray)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .sheet(isPresented: $isLoggingWorkoutActive) {
                        Logging(selectedDate: $selectedDate)
                    }
            
            Button(action: {
                isLoggingFoodActive.toggle()
            }) {
                HStack {
                    Text("Food Consumption")
                        .font(.custom("UhBee Se_hyun", size: 18))
                        .foregroundColor(.white)
                    Image(systemName: "fork.knife")
                        .font(.custom("UhBee Se_hyun", size: 18))
                        .foregroundColor(.white)
                        .padding(.trailing, 10)
                }

            }
            .frame(maxWidth: 300, maxHeight:20)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.gray, Color.black]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(15)
            .shadow(radius: 5)
            .sheet(isPresented: $isLoggingFoodActive) {
                FoodLogging(selectedDate: $selectedDate)
            }
            
            Button(action: {
                isLoggingBodyMetricsActive.toggle()
            }) {
                HStack {
                    Text("Body Metrics")
                        .font(.custom("UhBee Se_hyun", size: 18))
                        .foregroundColor(.white)
                    Image(systemName: "waveform.path.ecg")
                        .font(.custom("UhBee Se_hyun", size: 18))
                        .foregroundColor(.white)
                        .padding(.trailing, 10)
                }

            }
            .frame(maxWidth: 300, maxHeight:20)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.gray, Color.black]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(15)
            .shadow(radius: 5)
            .sheet(isPresented: $isLoggingBodyMetricsActive) {
                BodyMetricLogging(selectedDate: $selectedDate)
            }

            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            showAlert = true
            
            if let savedPreferences = UserDefaults.standard.dictionary(forKey: "userPreferences") as? [String: Any] {
                self.firstName = savedPreferences["firstName"] as? String ?? ""
            }
            selectedDate = Date() 
            let startOfDay = Calendar.current.startOfDay(for: Date())
                   let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!

            manager.fetchSleepData(startDate: startOfDay, endDate: endOfDay)


        }
        
        .onReceive(manager.$activities) { _ in
            print("Activities changed. Updating UI.")

        }
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
