import SwiftUI

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false

    func loginUser(username: String, password: String) {

        isLoggedIn = true
    }

    func logoutUser() {

        isLoggedIn = false
    }
}

