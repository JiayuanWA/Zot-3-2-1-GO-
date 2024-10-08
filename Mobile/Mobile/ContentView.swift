import SwiftUI


class UserSettings: ObservableObject {
    @Published var username: String = ""
}
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var manager = HealthKit()
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userSettings: UserSettings
    
    @State private var password: String = ""
    @State public var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            if authManager.isLoggedIn {
                EmptyView()
            } else {
                loginView
                    .background(
                        Image("Wallpaper")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                    )
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Error"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
            }
        }
        .onAppear {
            UIFont.loadFontIfNeeded("UhBee Se_hyun", type: "ttf")
        }
    }

    private var loginView: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Zot 3 2 1 Go!")
                .font(.custom("UhBee Se_hyun", size: 24))
                .foregroundColor(.gray)

            TextField("Username", text: $userSettings.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            NavigationLink(destination: CreateAccount().navigationBarHidden(true)) {
                HStack {
                    Text("Create your Workout Buddy")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .underline()

                    Image(systemName: "person.crop.circle.fill")
                        .foregroundColor(.gray)
                }
            }

            Button(action: {
                if userSettings.username.isEmpty {
                    
                } else {
                    authManager.loginUser(username: userSettings.username, password: password)
                }
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .font(.custom("UhBee Se_hyun", size: 14))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(8)
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}


extension UIFont {
    static func loadFontIfNeeded(_ fontName: String, type: String) {
        if UIFont.fontNames(forFamilyName: fontName).isEmpty {
            guard let fontPath = Bundle.main.path(forResource: fontName, ofType: type),
                  let fontData = NSData(contentsOfFile: fontPath),
                  let dataProvider = CGDataProvider(data: fontData),
                  let fontRef = CGFont(dataProvider)
            else {
                return
            }
            var error: Unmanaged<CFError>?
            if CTFontManagerRegisterGraphicsFont(fontRef, &error) {
                print("Font loaded successfully")
            }
        }
    }
}
