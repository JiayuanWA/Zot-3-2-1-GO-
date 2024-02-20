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
    @State private var stepsCount: Double = 0

    var body: some View {
        VStack(alignment: .leading) {
            Text("Welcome, \(firstName)")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            WeekProgressView(startOfWeekDates: Date.startOfWeekDates())
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 10)

            // Progress bar for steps walked
            if let stepData = manager.activities["today Steps"] {
                let stepCount = Double(stepData.amount) ?? 0
                let goal = 10000.0 // Set your goal here

                ProgressItem(title: "Steps Walked", value: stepCount, goal: goal)
                    .padding(.top, 20)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            if let savedPreferences = UserDefaults.standard.dictionary(forKey: "userPreferences") as? [String: Any] {
                self.firstName = savedPreferences["firstName"] as? String ?? ""
            }

//            // Fetch initial data
//            manager.fetchWalkingRunningDistance()
//            manager.fetchSleepData()
//            manager.fetchYesterdaySleepData()
//            manager.fetchWeeklyRunning()
        }
        .onReceive(manager.$activities) { _ in
            print("Activities changed. Updating UI.")
            // Update any other UI elements here if needed
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
                    .font(.headline)
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

                Text("\(Int(value))/\(Int(goal))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

struct WeekProgressView: View {
    @State private var selectedDate: Date?
    @EnvironmentObject var manager: HealthKit
    let startOfWeekDates: [Date]

    var body: some View {
        LazyHGrid(rows: [GridItem()], spacing: 10) {
            ForEach(0..<7) { day in
                DayProgressView(
                    startDate: startOfWeekDates[day],
                    caloriesBurnedPercentage: 0.5,
                    stepsWalkedPercentage: 0.8,
                    minutesExercisedPercentage: 0.3
                )
                .onTapGesture {
                    // Update the selected date when a circle is tapped
                    selectedDate = startOfWeekDates[day]
                    print("Selected Date Updated: \(selectedDate ?? Date())")
                }
            }
        }
        .onChange(of: selectedDate) { newDate in
            // Print the selected date for debugging
            print("Selected Date: \(newDate ?? Date())")

            // Fetch data for the selected date
            if let date = newDate {
                let calendar = Calendar.current
                let startDate = calendar.startOfDay(for: date)
                print("Start Date: \(startDate)")
                // Unwrap the optional endDate
                if let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startDate) {
                            print("Start Date: \(startDate), End Date: \(endDate)")
                            manager.fetchSteps(startDate: startDate, endDate: endDate)
                    //activity dictionary will then has changed
                    //show to new step count in the box
                    
                               
                           
                        }
            }
        }

    }
}


struct DayProgressView: View {
    let startDate: Date
    let caloriesBurnedPercentage: Double
    let stepsWalkedPercentage: Double
    let minutesExercisedPercentage: Double

    var body: some View {
        VStack {
            Text(dayOfWeekString(startDate))
                .font(.caption)
                .foregroundColor(.secondary)

            ZStack {
                            Circle()
                                .trim(from: 0.0, to: CGFloat(caloriesBurnedPercentage))
                                .stroke(Color.red, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 30, height: 30)
                                .rotationEffect(.degrees(-90))

                            Circle()
                                .trim(from: 0.0, to: CGFloat(stepsWalkedPercentage))
                                .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(-90))

                            Circle()
                                .trim(from: 0.0, to: CGFloat(minutesExercisedPercentage))
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(-90))
                        }

            Text(dateString(startDate))
                .font(.caption)
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
