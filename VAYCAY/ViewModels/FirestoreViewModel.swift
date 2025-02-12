//
//  FirestoreViewModel.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/30/25.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class FirestoreViewModel: ObservableObject {
    @Published var places: [GooglePlace] = []
    @Published var favorites: [FavoriteDestination] = []
    @Published var favoriteCities: [String] = []
    @Published var errorMessage: String?
    @Published var userName: String = ""
    @Published var userEmail: String = ""

    private let googlePlacesAPI = GooglePlacesAPI()
    private let db = Firestore.firestore()

    // ==============================
    // FETCH USER PROFILE
    // ==============================
    func fetchUserProfile() {
        guard let user = Auth.auth().currentUser else {
            print("❌ No authenticated user found.")
            return
        }

        let userRef = db.collection("users").document(user.uid)

        userRef.getDocument { [weak self] (document, error) in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let document = document, document.exists {
                    let data = document.data()
                    self.userName = data?["name"] as? String ?? "Unknown"
                    self.userEmail = user.email ?? "No Email"
                    print("✅ User Profile Loaded: \(self.userName), \(self.userEmail)")
                } else {
                    print("❌ Error fetching user profile: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }

    // ==============================
    // FETCH USER FAVORITES
    // ==============================
    func fetchFavorites() {
        guard let user = Auth.auth().currentUser else { return }

        let docRef = db.collection("users").document(user.uid)

        docRef.getDocument { [weak self] (document, error) in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let document = document, document.exists {
                    if let favoritesData = document.data()?["favorites"] as? [[String: Any]] {
                        self.favorites = favoritesData.compactMap { data in
                            guard let place_id = data["place_id"] as? String,
                                  let name = data["name"] as? String else {
                                return nil
                            }

                            return FavoriteDestination(
                                place_id: place_id,
                                name: name,
                                imageUrl: data["imageUrl"] as? String,
                                location: data["location"] as? String,
                                rating: data["rating"] as? Double ?? 0.0
                            )
                        }
                    } else {
                        self.favorites = []
                    }
                } else {
                    self.errorMessage = "❌ Error fetching favorites: \(error?.localizedDescription ?? "Unknown error")"
                }
            }
        }
    }

    // ADD A FAVORITE DESTINATION
    func addFavorite(destination: FavoriteDestination) {
        guard let user = Auth.auth().currentUser else { return }

        let userRef = db.collection("users").document(user.uid)
        userRef.updateData([
            "favorites": FieldValue.arrayUnion([destination.toDictionary()])
        ]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error saving favorite to Firestore: \(error.localizedDescription)")
                } else {
                    self.favorites.append(destination)
                    print("✅ Successfully saved \(destination.name) to Firestore.")
                }
            }
        }
    }

    // REMOVE A FAVORITE DESTINATION
    func removeFavorite(destination: FavoriteDestination) {
        guard let user = Auth.auth().currentUser else { return }

        let userRef = db.collection("users").document(user.uid)
        userRef.updateData([
            "favorites": FieldValue.arrayRemove([destination.toDictionary()])
        ]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error removing favorite: \(error.localizedDescription)")
                } else {
                    self.favorites.removeAll { $0.place_id == destination.place_id }
                    print("✅ Successfully removed \(destination.name) from Firestore.")
                }
            }
        }
    }

    // ==============================
    // FETCH USER PREFERENCES (FAVORITE CITIES)
    // ==============================
    func fetchUserPreferences() {
        guard let user = Auth.auth().currentUser else { return }

        let userRef = db.collection("users").document(user.uid)

        userRef.getDocument { [weak self] (document, error) in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let document = document, document.exists {
                    if let cities = document.data()?["favoriteCities"] as? [String] {
                        self.favoriteCities = cities
                    } else {
                        self.favoriteCities = []
                    }
                } else {
                    self.errorMessage = "❌ Error fetching user preferences: \(error?.localizedDescription ?? "Unknown error")"
                }
            }
        }
    }

    // ==============================
    // ADD/REMOVE USER PREFERENCES
    // ==============================
    func addFavoriteCity(city: String) {
        guard let user = Auth.auth().currentUser, !city.isEmpty else { return }

        favoriteCities.append(city)
        saveFavoriteCities(for: user.uid)
    }

    func updateFavoriteCity(at index: Int, with newCity: String) {
        guard let user = Auth.auth().currentUser, index < favoriteCities.count else { return }

        favoriteCities[index] = newCity
        saveFavoriteCities(for: user.uid)
    }

    func removeFavoriteCity(city: String) {
        guard let user = Auth.auth().currentUser else { return }

        favoriteCities.removeAll { $0 == city }
        saveFavoriteCities(for: user.uid)
    }

    private func saveFavoriteCities(for userId: String) {
        let userRef = db.collection("users").document(userId)

        userRef.setData(["favoriteCities": favoriteCities], merge: true) { error in
            if let error = error {
                print("❌ Error updating preferences: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    // ==============================
    // GEOCODING: Convert City Name to Coordinates
    // ==============================
    func getCoordinates(for location: String, completion: @escaping (Location?) -> Void) {
        let apiKey = googlePlacesAPI.apiKey
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
                let result = try JSONDecoder().decode(GeocodingResponse.self, from: data)
                let location = result.results.first?.geometry.location
                completion(location)
            } catch {
                print("❌ JSON Decoding Error: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }


    // ==============================
    // FETCH LOCATIONS BASED ON CATEGORY + CITY
    // ==============================
    func fetchPopularLocations(for category: String, in location: String, completion: @escaping () -> Void) {

        getCoordinates(for: location) { [weak self] coordinates in
            guard let self = self, let lat = coordinates?.lat, let lng = coordinates?.lng else {
                DispatchQueue.main.async {
                    self?.errorMessage = "❌ Unable to find location: \(location)"
                    print("❌ Unable to find coordinates for: \(location)")
                    completion()
                }
                return
            }

            self.googlePlacesAPI.fetchPopularLocations(category: category, latitude: lat, longitude: lng) { fetchedPlaces in
                DispatchQueue.main.async {
                    if let fetchedPlaces = fetchedPlaces, !fetchedPlaces.isEmpty {
                        self.places = fetchedPlaces
                        print("✅ Fetched \(fetchedPlaces.count) places for \(category) in \(location)")
                    } else {
                        self.errorMessage = "No results available for \(category) in \(location)."
                    }
                    completion()
                }
            }
        }
    }
}


    

