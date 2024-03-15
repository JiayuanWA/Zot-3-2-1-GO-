import SwiftUI





struct workout_view: View {
    @EnvironmentObject var manager: HealthKit
    @State private var firstName: String = ""
    @State private var username: String = "Alice"
    @State private var selectedDate: Date?
    @State private var showAlert = false
    @State private var isSurveyActive: Bool = false
    @State private var hasUserTakenSurveyToday = false
    @State private var exerciseDuration: Double = 0
    @State private var isLoggingWorkoutActive = false
    @State private var isLoggingFoodActive = false
    @State private var isLoggingBodyMetricsActive = false
    
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Welcome, \(firstName)")
                .font(.custom("UhBee Se_hyun", size: 24))
                .fontWeight(.bold)
            
            
            
            
            
            
            
            Button(action: {
                isSurveyActive.toggle()
            }) {
                Text("How are you feeling today?")
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
