import SwiftUI

struct TabView: View {
    @State var selectedTab = "Home"
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)

        
//        TabView(selection: $selectedTab) {
//            HomeView()
//                .tag("Home")
//                .tabItem {
//                    Image(systemName: "house")
//                    Text("Home")
//                }
//        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TabView()
    }
}
