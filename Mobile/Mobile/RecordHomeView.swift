import SwiftUI

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

            Section(header: Text("Daily Goals")) {
                VStack(alignment: .leading, spacing: 8) {
                    ProgressItem(title: "Steps Walked", value: stepsCount, goal: 10000)
                    ProgressItem(title: "Calories Burned", value: 1, goal: 500)
                    ProgressItem(title: "Time Slept", value: 2, goal: 8)
                    ProgressItem(title: "Workout Logged", value: 3, goal: 10)
                }
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                ForEach(manager.activities.sorted(by: { $0.value.id < $1.value.id }), id: \.key) { item in
                    Activity(activity: item.value)
                }
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            if let savedPreferences = UserDefaults.standard.dictionary(forKey: "userPreferences") as? [String: Any] {
                self.firstName = savedPreferences["firstName"] as? String ?? ""
            }
            manager.fetchSteps { stepsCount in
                self.stepsCount = stepsCount
            }
            
            manager.fetchWalkingRunningDistance()
            manager.fetchSleepData()
            manager.fetchYesterdaySleepData()
//            manager.fetchHeight()
//            manager.fetchWeight()
            manager.fetchWeeklyRunning()
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
