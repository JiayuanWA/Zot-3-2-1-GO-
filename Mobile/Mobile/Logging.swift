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
                    // Handle the submission of food intake log
                    print("Food intake logged for \(selectedDate ?? Date())")
                    print("Food Item: \(foodItem)")
                    print("Meal Type: \(mealType)")
                    print("Calories Consumed: \(caloriesConsumed) calories")
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
    @State private var weight: Double = 0.0
    @State private var height: Double = 0.0
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
