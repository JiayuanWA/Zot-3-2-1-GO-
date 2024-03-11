import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            RecordHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .background(
                    Image("Wallpaper")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                )
                .font(.custom("UhBee Se_hyun", size: 14))
                

            

            NavigationView {
                    ExerciseListView()
                        .navigationBarTitle("Exercise List", displayMode: .inline)
                }
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Workout Catalogue")
                }
                .background(
                    Image("Wallpaper")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                )


            RecommendationsView()
                            .tabItem {
                                Image(systemName: "heart.fill")
                                Text("Recommendations")
                            }
                            .background(
                                Image("Wallpaper")
                                    .resizable()
                                    .scaledToFill()
                                    .edgesIgnoringSafeArea(.all)
                            )

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .background(
                    Image("Wallpaper")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                )
            
        }
        .accentColor(.blue) 
    }
}



