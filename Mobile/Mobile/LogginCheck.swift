import Foundation

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var showAlert = false
        @Published var alertMessage = ""
    
    func loginUser(username: String, password: String) {
        // Create a URL object with the login endpoint
        guard let loginURL = URL(string: "http://52.14.25.178:5000/login") else {
            print("Invalid URL")
            return
        }

        // Create a URLRequest with POST method
        var loginRequest = URLRequest(url: loginURL)
        loginRequest.httpMethod = "POST"
        loginRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginData: [String: String] = ["username": username, "password": password]

        // Convert loginData to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: loginData) else {
            print("Error creating JSON data")
            return
        }


        loginRequest.httpBody = jsonData

        // Perform the login request
        URLSession.shared.dataTask(with: loginRequest) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Parse the response JSON
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    print("login success ")
                 
                    DispatchQueue.main.async {
                        self.isLoggedIn = true
                    
                        self.initializeDailyLog(username: username)
                    }
                } else {
                    self.alertMessage = "Login failed with status code: \(httpResponse.statusCode)"
                                       self.showAlert = true
                    print("Login failed with status code: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }

    func initializeDailyLog(username: String) {
        guard let initializeURL = URL(string: "http://52.14.25.178:5000/initialize_daily_log") else {
            print("Invalid URL for initialize_daily_log")
            return
        }


        var initializeRequest = URLRequest(url: initializeURL)
        initializeRequest.httpMethod = "POST"
        initializeRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")


        let initializeData: [String: String] = ["username": username]


        guard let jsonData = try? JSONSerialization.data(withJSONObject: initializeData) else {
            print("Error creating JSON data for initialize_daily_log")
            return
        }


        initializeRequest.httpBody = jsonData


        URLSession.shared.dataTask(with: initializeRequest) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }


            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
               
                    print("Daily log initialized successfully")
                } else {
                    // Initialization failed
                    print("Initialization failed with status code: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }

    func logoutUser() {
        // Add logout logic here if needed
        isLoggedIn = false
    }
}
