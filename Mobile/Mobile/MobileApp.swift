

import SwiftUI
import SwiftData

@main
struct MobileApp: App {
    @StateObject var manager = HealthKit()
    @StateObject var authManager = AuthManager()
    
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
                ContentView()
                    .environmentObject(authManager)
                if authManager.isLoggedIn {
                    HomeView()
                        .environmentObject(manager)
                }
            }
            .modelContainer(sharedModelContainer)
        }
}
