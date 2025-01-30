//
//  UserPreferences.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/28/25.

import SwiftUI

struct UserPreferencesView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var newPreference: String = ""
    @State private var suggestions: [String] = []
    
    var body: some View {
        VStack {
            Text("Update Travel Preferences")
                .font(.title)
                .bold()
                .padding()
            
            // Autocomplete Search Box
            TextField("Start typing...", text: $newPreference)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: newPreference) {
                    fetchAutocompleteSuggestions()
                }
            
            // Display autocomplete suggestions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button(action: {
                            viewModel.addPreference(suggestion)
                            newPreference = "" // Clear input
                        }) {
                            Text(suggestion)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding()
            
            // Show selected preferences
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.travelPreferences, id: \.self) { preference in
                        Text(preference)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            
            Button("Save") {
                viewModel.saveTravelPreferences(viewModel.travelPreferences)
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onAppear {
            viewModel.fetchTravelPreferences()
        }
    }
    
    // Add selected city to preferences and update Firestore
    private func fetchAutocompleteSuggestions() {
        guard !newPreference.isEmpty else {
            suggestions = []
            return
        }
        
        let apiKey = GooglePlacesAPI().apiKey
        let input = newPreference.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(input)&types=(regions)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        print("🚀 Requesting autocomplete API: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Error fetching autocomplete: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(GooglePlacesAutocompleteResponse.self, from: data)
                DispatchQueue.main.async {
                    self.suggestions = response.predictions.map { $0.description }
                    print("✅ Autocomplete suggestions: \(self.suggestions)")
                }
            } catch {
                print("❌ Error decoding autocomplete response: \(error.localizedDescription)")
            }
        }.resume()
    }
}

// Google Places Autocomplete Models
struct GooglePlacesAutocompleteResponse: Codable {
    let predictions: [Prediction]
}

struct Prediction: Codable {
    let description: String
}


