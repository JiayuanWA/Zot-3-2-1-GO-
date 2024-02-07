

import SwiftUI


struct ActivityData {
    let id: Int
    let title: String
    let subtitle: String
    let image: String
    let amount: String
}
struct Activity: View {
    @State var activity: ActivityData
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
                .cornerRadius(15)
            VStack{
                HStack(alignment: .top){
                    VStack(alignment: .leading, spacing: 5){
                        Text(activity.title)
                        Text(activity.subtitle)
                            .font(.caption)
                    }
                    Spacer()
                    Image(systemName: activity.image)
                        .foregroundColor(.blue)
                    
                }
                .padding()
                
                Text(activity.amount)
                    .font(.system(size:20))
            }

        .cornerRadius(15)
        }
    }
}

#Preview {
    Activity(activity: ActivityData(id:0, title: "Daily Steps", subtitle: "Goal: 10,0000", image: "figure.walk", amount: "2222"))
}
