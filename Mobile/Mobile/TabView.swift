import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userSettings: UserSettings
    var body: some View {
        TabView {
            RecordHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .environmentObject(userSettings)
                .background(
                    Image("Wallpaper")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                )
                .font(.custom("UhBee Se_hyun", size: 14))
                

            HomeView()
                .tabItem {
                    Image(systemName: "list.bullet.clipboard")
                    Text("Log")
                }
                .environmentObject(userSettings)
                .background(
                    Image("Wallpaper")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                )
                .font(.custom("UhBee Se_hyun", size: 14))

            NavigationView {
                ExerciseListView()
                    .navigationBarTitleDisplayMode(.inline)
                    .font(.custom("UhBee Se_hyun", size: 14)) 


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
                            

                            .environmentObject(userSettings)
                            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .environmentObject(userSettings)
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



