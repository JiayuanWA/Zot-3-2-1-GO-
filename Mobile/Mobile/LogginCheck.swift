import SwiftUI

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false

    func loginUser(username: String, password: String) {
        // Perform login logic here
        // For simplicity, let's assume login is successful
        isLoggedIn = true
    }

    func logoutUser() {
        // Perform logout logic here
        // For simplicity, let's assume logout is successful
        isLoggedIn = false
    }
}

