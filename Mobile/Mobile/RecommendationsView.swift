import SwiftUI

struct RecommendationModel: Decodable {
    let title: String
    let description: String
}


class RecommendationsEngine {
    func generateRecommendations() -> [RecommendationModel] {
        return [
           
            RecommendationModel(title: "Today Workout Recommendations", description: "...Give us some time to retrieve your personalized exercise recommendations"),
//            RecommendationModel(title: "Mindful Meditation", description: "Try a 10-minute mindfulness meditation."),
//            RecommendationModel(title: "Strength Training", description: "Incorporate strength exercises into your routine.")
        ]
    }
}

struct RecommendationsView: View {
    let recommendationsEngine = RecommendationsEngine()
    @EnvironmentObject var userSettings: UserSettings
    @State private var recommendations: [RecommendationModel] = []
    let brownColor = Color(red: 0.6, green: 0.4, blue: 0.2)
    @StateObject var userPreferences = UserPreferences()
    
    var body: some View {
        VStack {
            Text("Personalized Recommendations")
                .font(.custom("UhBee Se_hyun", size: 18))
                .fontWeight(.bold)
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
        
            fetchPersonalizedRecommendations()
        }
    }
    

    private func fetchPersonalizedRecommendations() {
        guard let url = URL(string: "http://52.14.25.178:5000/get_recommendation") else {
            print("Invalid URL")
            return
        }
        
        let requestBody: [String: Any] = [
            "username": userSettings.username,
            "date": userPreferences.selectedDate
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Failed to serialize HTTP body")
            return
        }
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 201 {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let exerciseList = json["exercise_list"] as? [[String: Any]] {
                            var recommendations: [RecommendationModel] = []
                            
                            print("look here: \(json)")
                            for item in exerciseList {
                                if let duration = item["duration"] as? String,
                                   let name = item["name"] as? String {
                                    let recommendation = RecommendationModel(title: name, description: "Recommended duration: \(duration)")
                                    recommendations.append(recommendation)
                                }
                            }
                            DispatchQueue.main.async {
                                self.recommendations = recommendations
                            }
                        } else {
                            print("Invalid response format")
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                }
            }
        }.resume()
    }
}

