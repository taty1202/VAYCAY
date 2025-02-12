//
//  GooglePlacesViewModel.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/31/25.


import Foundation
import Combine
import FirebaseFirestore

class GooglePlacesViewModel: ObservableObject {
    @Published var places: [GooglePlace] = []
    private let placesAPI = GooglePlacesAPI()

    // Fetch POIs based on category and user-specified location
    func fetchPOIs(category: String, location: String) {
        fetchCoordinates(for: location) { [weak self] coordinates in
            guard let coordinates = coordinates else {
                DispatchQueue.main.async {
                    self?.places.removeAll()
                }
                print("❌ Unable to fetch coordinates for location: \(location)")
                return
            }

            self?.placesAPI.fetchPopularLocations(category: category, latitude: coordinates.latitude, longitude: coordinates.longitude) { results in
                DispatchQueue.main.async {
                    if let results = results {
                        self?.places = results
                    } else {
                        self?.places = []  // Display "No results found" correctly
                    }
                }
            }
        }
    }


    // Convert location name to coordinates using Google Geocoding API
    private func fetchCoordinates(for location: String, completion: @escaping (GeoLocation?) -> Void) {
        let apiKey = placesAPI.apiKey
        let formattedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(formattedLocation)&key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            print("❌ Invalid Geocoding URL")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Error fetching coordinates: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ No data received")
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(GeoCodingResponse.self, from: data)
                let location = result.results.first?.geoGeometry.geoLocation
                completion(location)
            } catch {
                print("❌ JSON Decoding Error: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}


struct GeoCodingResponse: Decodable {
    let results: [GeoCodingResult]
}

struct GeoCodingResult: Decodable {
    let geoGeometry: GeoGeometry
}

struct GeoGeometry: Decodable {
    let geoLocation: GeoLocation
}

struct GeoLocation: Decodable {
    let latitude: Double
    let longitude: Double

    // Custom CodingKeys to match Google's API response
    private enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}




