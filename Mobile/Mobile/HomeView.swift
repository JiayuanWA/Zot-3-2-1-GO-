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
                
                Activity()
                Activity()
                
                
            }
            .padding(.horizontal)
        }
    }
}



struct  HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
