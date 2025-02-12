//
//  PlaceDetailsResponse.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 2/5/25.
//

import Foundation

struct PlaceDetailsResponse: Decodable {
    let result: PlaceDetails
}

struct PlaceDetails: Decodable {
    let name: String?
    let rating: Double?
    let vicinity: String?
    let photos: [Photo]?
    let reviews: [Review]?
    let user_ratings_total: Int?
}

// Ensure `Review` is `Decodable`
struct Review: Decodable, Identifiable {
    let id = UUID() // Unique ID for SwiftUI lists
    let author_name: String?
    let rating: Double?
    let text: String?

    private enum CodingKeys: String, CodingKey {
        case author_name, rating, text
    }
}






