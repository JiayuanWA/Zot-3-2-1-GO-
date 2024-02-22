import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            RecordHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            NavigationView {
                    ExerciseListView()
                        .navigationBarTitle("Exercise List", displayMode: .inline)
                }
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Exercises")
                }


            RecommendationsView()
                            .tabItem {
                                Image(systemName: "heart.fill")
                                Text("Recommendations")
                            }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.blue) 
    }
}



