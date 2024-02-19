import SwiftUI
struct ProfileView: View {
    @State private var firstName: String = ""

    var body: some View {
        VStack {
            Text("Hi, \(firstName)")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            // Your profile content goes here
            Text("Profile Content Goes Here")
        }
        .onAppear {
            // Retrieve first name from user preferences
            if let savedPreferences = UserDefaults.standard.dictionary(forKey: "userPreferences") as? [String: Any] {
                self.firstName = savedPreferences["firstName"] as? String ?? ""
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
