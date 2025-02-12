//
//  PlaceCardView.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 2/7/25.

import SwiftUI

struct PlaceCardView: View {
    let place: GooglePlace

    var body: some View {
        VStack(alignment: .leading, spacing: 6) { // Added spacing between image & text
            placeImage(for: place)
                .frame(width: 340, height: 160) // Adjusted height
                .cornerRadius(10)
                .clipped()

            Text(place.name)
                .font(.headline)
                .multilineTextAlignment(.leading)
                .lineLimit(2) // Prevents text from being hidden
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
        }
        .frame(width: 340, height: 220)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }

    // Image Handling
    private func placeImage(for place: GooglePlace) -> some View {
        if let photoReference = place.photos?.first?.photo_reference,
           let imageURL = URL(string: GooglePlacesAPI().getPlaceImageUrl(photoReference: photoReference)) {
            return AnyView(
                AsyncImage(url: imageURL) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 340, height: 160) // Ensures correct scaling
                        .clipped()
                } placeholder: {
                    Color.gray.opacity(0.3)
                        .frame(width: 340, height: 160)
                }
            )
        } else {
            return AnyView(
                Color.gray.opacity(0.3)
                    .frame(width: 340, height: 160)
            )
        }
    }
}
