//
//  GooglePlacesAPI.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/21/25.

import Foundation

class GooglePlacesAPI {
    private let googlePlacesApiKey: String

    init() {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GooglePlacesAPIKey") as? String, !key.isEmpty else {
            fatalError("❌ Google Places API Key is missing. Ensure it's set in the Info.plist and User-Defined Settings.")
        }
        self.googlePlacesApiKey = key
    }

    var apiKey: String {
        return googlePlacesApiKey
    }

    // Fetch Full Place Details (including reviews)
    func fetchPlaceDetails(placeID: String, completion: @escaping (PlaceDetails?) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&fields=name,rating,vicinity,photos,reviews,user_ratings_total&key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            completion(nil)
            return
        }

        print("📡 Fetching place details from: \(urlString)")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Error fetching place details: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ No data received from Place Details API")
                completion(nil)
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📡 Raw API Response (Place Details): \(jsonString)")
            }

            do {
                let response = try JSONDecoder().decode(PlaceDetailsResponse.self, from: data)
                DispatchQueue.main.async {
                    print("✅ Successfully fetched place details for: \(response.result.name ?? "Unknown")")
                    completion(response.result)
                }
            } catch {
                print("❌ JSON Decoding Error (Place Details): \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    // Fetch Popular Locations by Category
    func fetchPopularLocations(category: String, latitude: Double, longitude: Double, completion: @escaping ([GooglePlace]?) -> Void) {
        let typeFilter: String

        switch category.lowercased() {
            case "beaches": typeFilter = "beach"
            case "cities": typeFilter = "tourist_attraction"
            case "mountains": typeFilter = "natural_feature"
            case "cuisine": typeFilter = "restaurant"
            case "hotels": typeFilter = "lodging"
            default: typeFilter = "point_of_interest"
        }

        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=4000&type=\(typeFilter)&key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            print("❌ Invalid Places API URL: \(urlString)")
            completion(nil)
            return
        }

        print("📡 Fetching places from: \(urlString)")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Error fetching places: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ No data received from Places API")
                completion(nil)
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📡 Raw API Response (Popular Locations): \(jsonString)")
            }

            do {
                let result = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)
                DispatchQueue.main.async {
                    print("✅ Successfully fetched \(result.results.count) places for category: \(category)")
                    completion(result.results)
                }
            } catch {
                print("❌ JSON Decoding Error (Popular Locations): \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    // Fetch Reviews for a Place
    func fetchReviews(placeID: String, completion: @escaping ([Review]?) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&fields=reviews&key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            completion(nil)
            return
        }

        print("📡 Fetching reviews from: \(urlString)")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Error fetching reviews: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("❌ No data received from Reviews API")
                completion(nil)
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📡 Raw API Response (Reviews): \(jsonString)")
            }

            do {
                let result = try JSONDecoder().decode(PlaceDetailsResponse.self, from: data)
                DispatchQueue.main.async {
                    print("✅ Successfully fetched \(result.result.reviews?.count ?? 0) reviews")
                    completion(result.result.reviews ?? [])
                }
            } catch {
                print("❌ JSON Decoding Error (Reviews): \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    // Generate Google Place Image URL
    func getPlaceImageUrl(photoReference: String) -> String {
        return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(apiKey)"
    }
}









