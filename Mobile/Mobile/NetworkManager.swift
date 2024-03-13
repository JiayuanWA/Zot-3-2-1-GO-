import Foundation

class NetworkManager {
    func registerUser(username: String, password: String, firstName: String, lastName: String, gender: String, dateOfBirth: String, height: Int, weight: Int, activityLevel: String, goals: [String], fitnessLevel: String) {
        // Create URL
        guard let url = URL(string: "http://52.14.25.178:5000/register") else {
            print("Invalid URL")
            return
        }
        
        // Create URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create request body
        let parameters: [String: Any] = [
            "username": username,
            "password": password,
            "first_name": firstName,
            "last_name": lastName,
            "gender": gender,
            "date_of_birth": dateOfBirth,
            "height_cm": height,
            "weight_kg": weight,
            "activity_level": activityLevel,
            "goals": goals,
            "fitness_level": fitnessLevel
        ]
        
        
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error creating HTTP body: \(error.localizedDescription)")
            return
        }
        
        // Create URLSession
        let session = URLSession.shared
        
        // Create URLSessionDataTask
        let task = session.dataTask(with: request) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            // Check for response status code
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
                if (200...299).contains(httpResponse.statusCode) {
                    // Request was successful
                    // Handle the response data here
                    print("Account registered successfully")
                } else {
                    // Request failed
                    print("Request failed with status code: \(httpResponse.statusCode)")
                }
            }
            
            // Check for response data
            if let data = data {
                // Parse and process the data
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                    // Handle the response data here
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            }
        }
        
        // Start the URLSessionDataTask
        task.resume()
    }
}
