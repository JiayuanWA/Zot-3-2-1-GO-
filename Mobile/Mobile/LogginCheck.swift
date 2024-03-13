import Foundation

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false

    func loginUser(username: String, password: String) {
        // Create a URL object with the login endpoint
        guard let url = URL(string: "http://52.14.25.178:5000/login") else {
            print("Invalid URL")
            return
        }

        // Create a URLRequest with POST method
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create the login data to send
        let loginData: [String: String] = ["username": username, "password": password]

        // Convert loginData to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: loginData) else {
            print("Error creating JSON data")
            return
        }

        // Attach JSON data to the request
        request.httpBody = jsonData

        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Parse the response JSON
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    // Login successful
                    // Update isLoggedIn state
                    DispatchQueue.main.async {
                        self.isLoggedIn = true
                    }
                } else {
                    // Login failed
                    print("Login failed with status code: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }

    func logoutUser() {
        // Add logout logic here if needed
        isLoggedIn = false
    }
}
