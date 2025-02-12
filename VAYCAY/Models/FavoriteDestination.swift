//
//  FavoriteDestination.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/30/25.

import Foundation

struct FavoriteDestination: Identifiable, Codable {
    var id: UUID = UUID()
    let place_id: String
    let name: String
    let imageUrl: String?
    let location: String?
    let rating: Double?
    let user_ratings_total: Int?  

    init(place_id: String, name: String, imageUrl: String? = nil, location: String? = nil, rating: Double? = nil, user_ratings_total: Int? = nil) {
        self.place_id = place_id
        self.name = name
        self.imageUrl = imageUrl
        self.location = location
        self.rating = rating ?? 0.0
        self.user_ratings_total = user_ratings_total ?? 0
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "place_id": place_id,
            "name": name,
            "imageUrl": imageUrl ?? "",
            "location": location ?? "",
            "rating": rating ?? 0.0,
            "user_ratings_total": user_ratings_total ?? 0
        ]
    }
}

//  Convert `GooglePlace` to `FavoriteDestination`
extension GooglePlace {
    func toFavoriteDestination() -> FavoriteDestination {
        return FavoriteDestination(
            place_id: self.place_id,
            name: self.name,
            imageUrl: self.photos?.first?.photo_reference,
            location: self.vicinity,
            rating: self.rating,
            user_ratings_total: self.user_ratings_total
        )
    }
}

// Convert `FavoriteDestination` to `GooglePlace`
extension FavoriteDestination {
    func toGooglePlace() -> GooglePlace {
        return GooglePlace(
            place_id: self.place_id,
            name: self.name,
            rating: self.rating ?? 0.0,
            vicinity: self.location ?? "Unknown location",
            types: [],
            user_ratings_total: self.user_ratings_total ?? 0,
            business_status: nil,
            price_level: nil,
            geometry: Geometry(location: Location(lat: 0.0, lng: 0.0)),
            photos: self.imageUrl != nil ? [Photo(photo_reference: self.imageUrl!)] : [],
            plus_code: nil
        )
    }
}

















