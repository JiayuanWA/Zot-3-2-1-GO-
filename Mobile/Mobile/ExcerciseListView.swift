import SwiftUI

struct Exercise: Identifiable, Equatable {
    var id = UUID()
    var activity: String

    init(from stringArray: [String]) {

        let activityName = stringArray[0].replacingOccurrences(of: "\"", with: "")
        self.activity = activityName

    }

  
    static func ==(lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ExerciseListView: View {
    @State private var exercises: [Exercise] = []
    @State private var selectedExercise: Exercise?
    @State private var searchText: String = ""
    @State private var duration: String = ""
    @State private var caloriesBurned: Double?
    @State private var isCaloriesCalculated: Bool = false // New state variable

    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter {
                $0.activity.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack {
            SearchBar(text: $searchText)
                .padding(.horizontal)
            List(filteredExercises) { exercise in
                VStack(alignment: .leading) {
                    Text("\(exercise.activity)") // Use the combined activity
                        .font(.headline)
                        .onTapGesture {
                            if selectedExercise == exercise {
                                duration = ""
                                selectedExercise = nil
                                caloriesBurned = nil
                            } else {
                                duration = ""
                                selectedExercise = exercise
                                caloriesBurned = nil
                            }
                        }

                    if selectedExercise == exercise {
                        TextField("Enter duration (minutes)", text: $duration)
                            .keyboardType(.numberPad)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                            .padding(.top, 8)

                        Button(action: {
                            if let duration = Double(duration) {
                                // Make a POST request to the backend
                                let data = ["username": "Test",
                                            "exercise_name": exercise.activity,
                                            "duration_minutes": duration]
                                print("you did \( exercise.activity)")

                                guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
                                    print("Error serializing JSON data")
                                    return
                                }

                                let url = URL(string: "http://52.14.25.178:5000/calculate_calories")!
                                var request = URLRequest(url: url)
                                request.httpMethod = "POST"
                                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                request.httpBody = jsonData

                                URLSession.shared.dataTask(with: request) { data, response, error in
                                    guard let httpResponse = response as? HTTPURLResponse else {
                                        print("Invalid response")
                                        return
                                    }

                                    guard let data = data else {
                                        print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                                        return
                                    }

                                    if httpResponse.statusCode == 200 {
                                        print("HTTP status code: \(httpResponse.statusCode)")
                                        print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
                                        do {
                                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                                               let caloriesBurned = json["calories_burned"] as? Double {
                                                DispatchQueue.main.async {
                                                    self.caloriesBurned = caloriesBurned
                                                    self.isCaloriesCalculated = true // Update isCaloriesCalculated
                                                }
                                            } else {
                                                print("Calories burned not found in response")
                                            }
                                        } catch {
                                            print("Error parsing JSON: \(error)")
                                        }
                                    } else {
                        
                                        print("HTTP status code: \(httpResponse.statusCode)")
                                        print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
                                    }
                                }.resume()
                           }
                        }) {
                            Text("Calculate Calories Burned")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }

                        if let caloriesBurned = caloriesBurned {
                            Text("Estimated Calories Burned: \(caloriesBurned, specifier: "%.2f")")
                                .foregroundColor(.black)
                                .padding(.vertical, 4)
                        }


                        Button(action: {
                            guard self.isCaloriesCalculated else {
                                print("Please calculate calories first.")
                                return
                            }
                            
                            let data: [String: Any] = [
                                                                 "username": "Test",
                                                                 "date_logged": "2024-03-15",
                                                                  "exercises": [[
                                                                         "type":  exercise.activity,
                                                                         "duration": duration,
                                                                         "calories_burned":caloriesBurned
                                                                     ]
                                                                 ]
                                                             ]
                            
     
                                        
                                         guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
                                             print("Error encoding data")
                                             return
                                         }
                                         
                                         guard let url = URL(string: "http://52.14.25.178:5000/log/exercise") else {
                                             print("Invalid URL")
                                             return
                                         }
                                         
                                         var request = URLRequest(url: url)
                                         request.httpMethod = "POST"
                                         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                         request.httpBody = jsonData
                                         
                                         URLSession.shared.dataTask(with: request) { data, response, error in
                                             if let error = error {
                                                 print("Error:", error.localizedDescription)
                                                 return
                                             }
                                             
                                             if let response = response as? HTTPURLResponse {
                                                 print("Response status code:", response.statusCode)
                                             }
                                             
                                             if let data = data {
                                                 if let responseString = String(data: data, encoding: .utf8) {
                                                     print("Response:", responseString)
                                                 }
                                             }
                                         }.resume()

                        }) {
                            Text("Log Exercise")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(8)
                        }

                    }
                }
            }
        }
        .onAppear {
      
            if let path = Bundle.main.path(forResource: "exercise_dataset (1)", ofType: "csv") {
                do {
                    let data = try String(contentsOfFile: path)
                    let lines = data.components(separatedBy: .newlines)
                    for value in lines {
                        
                        guard !value.isEmpty else { continue }
                        exercises.append(Exercise(from: [value]))
                    }
                    print("Exercises loaded successfully")
                } catch {
                    print("Error loading CSV file: \(error)")
                }
            } else {
                print("CSV file not found.")
            }
        }

    }
}

struct ExerciseListView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseListView()
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color(.systemGray5))
                .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}
