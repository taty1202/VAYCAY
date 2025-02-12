//
//  CategoryDetailViewModel.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 2/3/25.


import Foundation
import Combine

class CategoryDetailViewModel: ObservableObject {
    @Published var placesBackup: [GooglePlace] = [] // Backup to restore places
    @Published var places: [GooglePlace] = []
    @Published var errorMessage: String?

    private let googlePlacesAPI = GooglePlacesAPI()
    private let firestoreVM: FirestoreViewModel

    init(firestoreVM: FirestoreViewModel) {
        self.firestoreVM = firestoreVM
    }

    // Load places and update backup
    func loadPlaces(for category: String, location: String) {
        print("📡 Fetching places for \(category) in \(location)...")
        
        firestoreVM.getCoordinates(for: location) { [weak self] coordinates in
            guard let self = self, let coordinates = coordinates else {
                DispatchQueue.main.async {
                    self?.errorMessage = "❌ Unable to find location: \(location)"
                }
                return
            }

            self.googlePlacesAPI.fetchPopularLocations(
                category: category,
                latitude: coordinates.lat ?? 0.0,
                longitude: coordinates.lng ?? 0.0
            ) { fetchedPlaces in
                DispatchQueue.main.async {
                    if let fetchedPlaces = fetchedPlaces, !fetchedPlaces.isEmpty {
                        self.places = fetchedPlaces
                    } else {
                        self.errorMessage = "No results available for \(category)."
                    }
                }
            }
        }
    }

    // Refresh Places After Favoriting
    func refreshPlaces() {
        print("🔄 refreshPlaces() called - Current places count: \(places.count)")

        DispatchQueue.main.async {
            self.objectWillChange.send()
            self.places = []
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.places = self.placesBackup 
            }
        }
    }
}









