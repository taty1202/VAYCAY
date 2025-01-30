//
//  AmadeusAPI.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/21/25.
//

import Foundation

class GooglePlacesAPI {
    private let googlePlacesApiKey: String

    init() {
        if let key = Bundle.main.object(forInfoDictionaryKey: "GooglePlacesAPIKey") as? String, !key.isEmpty {
            self.googlePlacesApiKey = key
            
        } else {
            print("❌ Google Places API Key Not Found")
            fatalError("❌ Google Places API Key is missing. Ensure it's set in the Info.plist and User-Defined Settings.")
        }
    }


    var apiKey: String {
        return googlePlacesApiKey
    }

    // ✅ Fetch POIs function should be inside the class
    func fetchPointsOfInterest(latitude: Double, longitude: Double, completion: @escaping ([GooglePlace]?) -> Void) {
        let radius = 5000
        let type = "point_of_interest"

        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&type=\(type)&key=\(apiKey)" // ✅ Corrected reference

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            completion(nil)
            return
        }

        print("Requesting POI API: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching POIs: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ No data received")
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)
                DispatchQueue.main.async {
                    if result.results.isEmpty {
                        print("❌ No results found for POI request.")
                    }
                    completion(result.results)
                }
            } catch {
                print("❌ JSON Decoding Error: \(error.localizedDescription)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("❌ Received JSON: \(jsonString)")
                }
                completion(nil)
            }
        }.resume()
    }
}

// ✅ Models for JSON decoding remain unchanged
struct GooglePlacesResponse: Decodable {
    let results: [GooglePlace]
}

struct GooglePlace: Decodable, Identifiable {
    var id: String { UUID().uuidString }
    let name: String
    let vicinity: String?
    let rating: Double?
    let types: [String]?
    let user_ratings_total: Int?
    let geometry: Geometry
    let photos: [Photo]?
}

struct Geometry: Decodable {
    let location: Location
}

struct Location: Decodable {
    let lat: Double
    let lng: Double
}

struct Photo: Decodable {
    let photo_reference: String
}

