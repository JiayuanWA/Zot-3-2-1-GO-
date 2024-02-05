//
//  Activity.swift
//  Mobile
//
//  Created by Wang on 2/5/24.
//

import SwiftUI

struct Activity: View {
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
                .cornerRadius(15)
            VStack{
                HStack(alignment: .top){
                    VStack(alignment: .leading, spacing: 5){
                        Text("Steps")
                        Text("Today")
                            .font(.caption)
                    }
                    Spacer()
                    Image(systemName: "figure.walk")
                        .foregroundColor(.blue)
                    
                }
                .padding()
                
                Text("10,000")
                    .font(.system(size:24))
            }

        .cornerRadius(15)
        }
    }
}

#Preview {
    Activity()
}
