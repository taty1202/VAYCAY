//
//  GooglePlacesAutocompleteResponse.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 2/6/25.
//

// Google Places Autocomplete Response Model
struct GooglePlacesAutocompleteResponse: Codable {
    let predictions: [Prediction]
}

struct Prediction: Codable {
    let description: String
}
