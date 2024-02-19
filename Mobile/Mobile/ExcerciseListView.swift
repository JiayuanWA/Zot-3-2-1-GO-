import SwiftUI

struct Exercise: Codable, Identifiable {
    var id: String
    var name: String
    
    // Add other properties as needed
}

struct ExerciseListView: View {
    @State private var exercises: [Exercise] = []
    @State private var searchText: String = ""

    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        VStack {
            SearchBar(text: $searchText)
                .padding(.horizontal)

            List(filteredExercises) { exercise in
                VStack(alignment: .leading) {
                    Text(exercise.name)
                        .font(.headline)
                }
            }
        }
        .onAppear {
            // Load exercises from JSON file
            if let path = Bundle.main.path(forResource: "exercises", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    let decoder = JSONDecoder()
                    exercises = try decoder.decode([Exercise].self, from: data)
                    print("Exercises loaded successfully: \(exercises)")
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else {
                print("JSON file not found.")
            }
        }
    }
}

struct ExerciseListView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseListView()
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color(.systemGray5))
                .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}
