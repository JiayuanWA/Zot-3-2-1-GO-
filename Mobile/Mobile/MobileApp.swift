

import SwiftUI
import SwiftData

@main
struct MobileApp: App {
    @StateObject var manager = HealthKit()
    @StateObject var authManager = AuthManager()
    let userSettings = UserSettings()
    @State public var showAlert = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                MainTabView()
                    .environmentObject(manager)
                    .environmentObject(userSettings)
                    .background(
                        Image("Wallpaper")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                    )
                    .onAppear {
                        showAlert = true
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Success"),
                            message: Text("Loggin Success! Have you filled out your daily survey?"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
            } else {
                ContentView()
                    .environmentObject(authManager)
                    .environmentObject(userSettings)
                    .background(
                        Image("Wallpaper")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                    )
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
