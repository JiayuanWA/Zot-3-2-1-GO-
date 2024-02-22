import SwiftUI

struct RecommendationModel {
    let title: String
    let description: String
}


class RecommendationsEngine {
    func generateRecommendations() -> [RecommendationModel] {

        return [
            RecommendationModel(title: "Daily Walk", description: "Take a 30-minute walk in the evening."),
            RecommendationModel(title: "Mindful Meditation", description: "Try a 10-minute mindfulness meditation."),
            RecommendationModel(title: "Strength Training", description: "Incorporate strength exercises into your routine.")
        ]
    }
}

struct RecommendationsView: View {

    let recommendationsEngine = RecommendationsEngine()
    

    @State private var recommendations: [RecommendationModel] = []

    var body: some View {
        VStack {
            Text("Personalized Recommendations")
                .font(.title)
                .padding()

            List(recommendations, id: \.title) { recommendation in
                VStack(alignment: .leading) {
                    Text(recommendation.title)
                        .font(.headline)
                    Text(recommendation.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
            }
        }
        .onAppear {

            recommendations = recommendationsEngine.generateRecommendations()
        }
    }
}

struct RecommendationsView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendationsView()
    }
}
