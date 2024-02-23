//
//  DailyDecisionSurveyView.swift
//  Mobile
//
//  Created by Wang on 2/23/24.
//

import SwiftUI

struct DailyDecisionSurveyView: View {
    @Binding var selectedDate: Date?
    @State private var feelingSelection: String = ""
    @State private var focusSelection: String = ""
    @State private var workoutDuration: Int = 30
    @State private var selectedEquipment: [String] = []
    @Environment(\.presentationMode) var presentationMode
    
    var availableEquipment = ["Weights", "Yoga Mat", "Bike", "Stationary Bike", "Stepmill/Stairmaster", "Stairs"]
    private func dismissSheet() {
            presentationMode.wrappedValue.dismiss()
        }
    
    var body: some View {
        Form {


            Section(header: Text("Pick a mode: ")) {
                Picker(selection: $feelingSelection, label: Text("")) {
                    Text("EASY?").tag("light")
                    Text("WORK IT!").tag("moderate")
                    Text("SWEAT!").tag("vigorous")
                    Text("HARDERRRR!").tag("extreme")
                    Text("WILD CARD :)").tag("fun")
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxHeight: 90, alignment: .center)
            }
            Section(header: Text("Focus Area Today?")) {
                Toggle("Lower Body", isOn: Binding(get: { focusSelection == "lower" }, set: { _ in focusSelection = "lower" }))

                Toggle("Upper Body", isOn: Binding(get: { focusSelection == "upper" }, set: { _ in focusSelection = "upper" }))

                Toggle("Whole Body", isOn: Binding(get: { focusSelection == "whole" }, set: { _ in focusSelection = "whole" }))

                Toggle("Abdominals", isOn: Binding(get: { focusSelection == "abdominals" }, set: { _ in focusSelection = "abdominals" }))
            }

            Section(header: Text("Select your available equipment:")) {
                ForEach(availableEquipment, id: \.self) { equipment in
                    Toggle(equipment, isOn: Binding(
                        get: { selectedEquipment.contains(equipment) },
                        set: { newValue in
                            if newValue {
                                selectedEquipment.append(equipment)
                            } else {
                                selectedEquipment.removeAll { $0 == equipment }
                            }
                        }
                    ))
                }
            }
            Section(header: Text("Let's aim for: ")) {
                Picker(" ", selection: $workoutDuration) {
                    ForEach(15...60, id: \.self) { minutes in
                        Text("\(minutes) min")
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxHeight: 90, alignment: .center)
                .padding()
            }

            Section {
                Button("Submit Survey") {
                    // Handle the submission of the survey
                    print("Survey submitted for \(selectedDate ?? Date())")
                    print("Feeling: \(feelingSelection)")
                    print("Focus: \(focusSelection)")
                    dismissSheet()
                }
                .padding()
                .frame(maxHeight: 90, alignment: .center)
            }
            
        }
        
    }
}
