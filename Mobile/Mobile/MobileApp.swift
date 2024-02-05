//
//  MobileApp.swift
//  Mobile
//
//  Created by Wang on 2/3/24.

//

import SwiftUI
import SwiftData

@main
struct MobileApp: App {
    @StateObject var manager = HealthKit()
    
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
            
            HomeView()
                .environmentObject(manager)
        }
        .modelContainer(sharedModelContainer)
    }
}
