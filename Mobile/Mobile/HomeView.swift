//
//  HomeView.swift
//  Mobile
//
//  Created by Wang on 2/5/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var manager: HealthKit
    
      
    var body: some View {
       
      
        
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count:2)) {
                
                ForEach(manager.activities.sorted(by: { $0.value.id < $1.value.id}), id: \.key) {
                    item in Activity(activity: item.value)
                }
                
                
                
            }
            .padding(.horizontal)
        }
        .onAppear{
            manager.fetchSteps()
            manager.fetchWalkingRunningDistance()
            manager.fetchSleepData()
            manager.fetchYesterdaySleepData()
            manager.fetchHeight()
            manager.fetchWeight()
        }
        

    }
}



struct  HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
