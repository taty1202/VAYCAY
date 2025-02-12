//
// GooglePlacesResponse.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/30/25.


import Foundation

// Google Places API Response
struct GooglePlacesResponse: Codable {
    let results: [GooglePlace]
}

struct GooglePlace: Codable, Identifiable, Hashable {
    var id: String { place_id }
    let place_id: String
    let name: String
    let rating: Double?
    let vicinity: String?
    let types: [String]?
    let user_ratings_total: Int?
    let business_status: String?
    let price_level: Int?
    let geometry: Geometry
    let photos: [Photo]?
    let plus_code: PlusCode?

    // First photo reference
    var photoReference: String? {
        return photos?.first?.photo_reference
    }

    // Implement Hashable protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(place_id)
    }

    static func == (lhs: GooglePlace, rhs: GooglePlace) -> Bool {
        return lhs.place_id == rhs.place_id
    }
}

// Define Geometry, Location, Photo, PlusCode
struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct Photo: Codable {
    let photo_reference: String
}

struct PlusCode: Codable {
    let compound_code: String?
    let global_code: String?
}


// Geocoding API Response Model (For `getCoordinates`)
struct GeocodingResponse: Codable {
    let results: [GeocodingResult]
}

struct GeocodingResult: Codable {
    let geometry: Geometry
}






