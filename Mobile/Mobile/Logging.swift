//
//  DailyDecisionSurveyView.swift
//  Mobile
//
//  Created by Wang on 2/23/24.
//

import SwiftUI

struct Logging: View {
        @Binding var selectedDate: Date?
        @State private var exerciseType: String = ""
      
        @State private var workoutDuration: Int = 30
        @State private var caloriesBurned: Double = 0.0
        @State private var isCardio: Bool = false
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            Form {
                Section(header: Text("Exercise Type")) {
                    TextField("E.g., Running, Weightlifting", text: $exerciseType)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Workout Duration")) {
                    Stepper(value: $workoutDuration, in: 15...120, step: 5) {
                        Text("\(workoutDuration) min")
                    }
                }
                
                Section(header: Text("Calories Burned")) {
                    Slider(value: $caloriesBurned, in: 0...500, step: 10)
                    Text("\(Int(caloriesBurned)) calories")
                }
                
                Section(header: Text("Is it Cardio?")) {
                    Toggle("Cardio", isOn: $isCardio)
                }
                
                Section {
                    Button("Log Exercise") {
                        // Handle the submission of exercise log
                        print("Exercise logged for \(selectedDate ?? Date())")
                        print("Exercise Type: \(exerciseType)")
                        print("Duration: \(workoutDuration) min")
                        print("Calories Burned: \(caloriesBurned) calories")
                        print("Is Cardio: \(isCardio)")
                        dismissSheet()
                    }
                    .padding()
                }
            }
        }
        
        private func dismissSheet() {
            presentationMode.wrappedValue.dismiss()
        }
    }



struct FoodLogging: View {
    @Binding var selectedDate: Date?
    @State private var dateString: String = ""
    
    @State private var foodItem: String = ""
    @State private var mealType: String = ""
    @State private var caloriesConsumed: Double = 0.0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("Food Item")) {
                TextField("E.g., Chicken Salad, Pasta, etc.", text: $foodItem)
                    .disableAutocorrection(true)
            }
            
            Section(header: Text("Meal Type")) {
                Picker("Select Meal Type", selection: $mealType) {
                    Text("Breakfast").tag("breakfast")
                    Text("Lunch").tag("lunch")
                    Text("Dinner").tag("dinner")
                    Text("Snack").tag("snack")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Calories Consumed")) {
                Slider(value: $caloriesConsumed, in: 0...1000, step: 10)
                Text("\(Int(caloriesConsumed)) calories")
            }
           
            Section {
                            Button("Log Food Intake") {
                                print("your date data: \(selectedDate)")
                                
                                if let selectedDate = selectedDate {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    dateString = dateFormatter.string(from: selectedDate)
                                    print("Selected date string: \(dateString)")}
                                // Create the request body
                    
                                let requestBody: [String: Any] = [
                                                        "username": "",
                                                        "date_logged": dateString,
                                                        "meals": [
                                                            [
                                                                //"food_item": foodItem,
                                                                "meal_type": mealType,
                                                                "calories":caloriesConsumed
                                                            ]
                                                        ]
                                                    ]
                                
                                // Send POST request
                                guard let url = URL(string: "http://52.14.25.178:5000/log/calorie_intake") else {
                                    print("Invalid URL")
                                    return
                                }
                                var request = URLRequest(url: url)
                                request.httpMethod = "POST"
                                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
                                    print("Failed to serialize HTTP body")
                                    return
                                }
                                request.httpBody = httpBody
                                
                                URLSession.shared.dataTask(with: request) { data, response, error in
                                    guard let data = data, error == nil else {
                                        print("Error: \(error?.localizedDescription ?? "Unknown error")")
                                        return
                                    }
                                    if let httpResponse = response as? HTTPURLResponse {
                                                            print("Response status code: \(httpResponse.statusCode)")
                                                            
                                                            if httpResponse.statusCode == 201 {
                                                                // Log intake successful, show alert
                                                                DispatchQueue.main.async {
                                                                                                   let alertController = UIAlertController(title: "Success", message: "Logged calorie intake for \(dateString)", preferredStyle: .alert)
                                                                                                   alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                                                                                   UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
                                                                                               }
                                                            }
                                                        }
                                }.resume()
                                
                                dismissSheet()
                            }
                            .padding()
                        }
                    }
                }
                
                private func dismissSheet() {
                    presentationMode.wrappedValue.dismiss()
                }
            }


struct BodyMetricLogging: View {
    @Binding var selectedDate: Date?
    @State private var dateString: String = ""
    @State private var weight: Int = 0
    @State private var height: Int = 0
    @State private var bodyFatPercentage: Double = 0.0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("Weight (in kg)")) {
                TextField("Enter your weight", value: $weight, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
            }
            
            Section(header: Text("Height (in cm)")) {
                TextField("Enter your height", value: $height, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
            }
            
            Section(header: Text("Body Fat Percentage")) {
                Slider(value: $bodyFatPercentage, in: 0...100, step: 1)
                Text("\(Int(bodyFatPercentage))%")
            }
            
            Section {
                Button("Log Body Metrics") {
                    // Handle the submission of body metric log
                    print("Body metrics logged for \(selectedDate ?? Date())")
                    print("Weight: \(weight) kg")
                    print("Height: \(height) cm")
                    print("Body Fat Percentage: \(bodyFatPercentage)%")
                    
                    if let selectedDate = selectedDate {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        dateString = dateFormatter.string(from: selectedDate)
                        print("Selected date string: \(dateString)")}
                    // Create the request body
        
                    let requestb: [String: Any] = [
                                            "username": "Yes",
                                            "date_logged": "2022-03-02",
                                            "metrics": [
                                                [
                                                    "weight_kg": 77,
                                                    "height_cm": 177
                                                ]
                                            ]
                                        ]
                    
                    // Send POST request
                    guard let url = URL(string: "http://52.14.25.178:5000/log/body_metrics") else {
                        print("Invalid URL")
                        return
                    }
                  
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    guard let httpBody = try? JSONSerialization.data(withJSONObject: requestb, options: []) else {
                        print("Failed to serialize HTTP body")
                        return
                    }
                    request.httpBody = httpBody
                    
                    URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            print("Error: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        if let httpResponse = response as? HTTPURLResponse {
                                                print("Response status code: \(httpResponse.statusCode)")
                                                
                                                if httpResponse.statusCode == 201 {
                                                    // Log intake successful, show alert
                                                    DispatchQueue.main.async {
                                                                                       let alertController = UIAlertController(title: "Success", message: "Logged body metrics for \(dateString)", preferredStyle: .alert)
                                                                                       alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                                                                       UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
                                                                                   }
                                                }
                                            }
                    }.resume()
                    
                    dismissSheet()
                }
                .padding()
            }
        }
    }
    
    private func dismissSheet() {
        presentationMode.wrappedValue.dismiss()
    }
}
