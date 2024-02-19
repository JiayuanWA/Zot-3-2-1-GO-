import SwiftUI

struct HomeView: View {
    @EnvironmentObject var manager: HealthKit
    
    var body: some View {
        MainTabView()
            .environmentObject(manager)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(HealthKit()) // Provide a dummy HealthKit object for preview
    }
}
