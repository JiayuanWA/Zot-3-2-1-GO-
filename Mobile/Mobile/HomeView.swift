import SwiftUI
import CoreLocation

struct HomeView: View {
    class UserPreferences: ObservableObject {
        @Published var selectedDate: Date?
    }

    @State private var showAlert = false
    @State private var isSurveyActive: Bool = false
    @State private var hasUserTakenSurveyToday = false
    @State private var exerciseDuration: Double = 0
    @State private var isLoggingWorkoutActive = false
    @State private var isLoggingFoodActive = false
    @State private var isLoggingBodyMetricsActive = false
    @StateObject var userPreferences = UserPreferences()

    @StateObject private var weatherAPIClient = WeatherAPIClient()
        
        var body: some View {
            
            VStack(alignment: .center, spacing: 15) {
       
                Text("Log your progress!")
                    .font(.custom("UhBee Se_hyun", size: 24))
                    .fontWeight(.bold)
                
                .sheet(isPresented: $isSurveyActive) {
                    DailyDecisionSurveyView(selectedDate: $userPreferences.selectedDate)
                }
                .padding(.horizontal)
                if let currentWeather = weatherAPIClient.currentWeather  {
                    HStack(alignment: .center, spacing: 16) {
                        currentWeather.weatherCode.image
                         
                        Text("\(currentWeather.temperature)º")
                            .font(.largeTitle)
                    }
                    Text(currentWeather.weatherCode.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                } else {
                    Text("No weather info available yet.\nTap on refresh to fetch new data.\nMake sure you have enabled location permissions for the app.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                    Button("Refresh", action: {
                        Task {
                            await weatherAPIClient.fetchWeather()
                        }
                    })
                }
                
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
                    Logging(selectedDate: $userPreferences.selectedDate)
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
                    FoodLogging(selectedDate: $userPreferences.selectedDate)
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
                    BodyMetricLogging(selectedDate: $userPreferences.selectedDate)
                }
                Spacer()
            }
            .onAppear {
                Task {
                    await weatherAPIClient.fetchWeather()
                }
            }
        }
    }


