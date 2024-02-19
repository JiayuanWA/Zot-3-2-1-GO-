import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // Tab 1
            RecordHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            // Tab 2 (Placeholder for other views, replace with your own)
            NavigationView {
                    ExerciseListView()
                        .navigationBarTitle("Exercise List", displayMode: .inline)
                }
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Exercises")
                }


            // Tab 3 (Placeholder for other views, replace with your own)
            RecordHomeView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Tab 3")
                }

            // Tab 4 (Profile)
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.blue) // Set the color for the selected tab
    }
}



