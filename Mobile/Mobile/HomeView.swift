
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var manager: HealthKit
    
      
    var body: some View {
       
        Text("Record Home")
            .font(.largeTitle)
            .padding()
        
        VStack(alignment: .leading) {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count:2)) {
                
                ForEach(manager.activities.sorted(by: { $0.value.id < $1.value.id}), id: \.key) {
                    item in Activity(activity: item.value)
                }
                
                
                
            }
            .padding(.horizontal)
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .top)
        
        .onAppear{
            manager.fetchSteps()
            manager.fetchWalkingRunningDistance()
            manager.fetchSleepData()
            manager.fetchYesterdaySleepData()
            manager.fetchHeight()
            manager.fetchWeight()
            manager.fetchWeeklyRunning() 
        }
        

    }
}



struct  HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
