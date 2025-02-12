//
//  ImageCarouselView.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 2/10/25.
//

import SwiftUI

struct ImageCarouselView: View {
    let photos: [Photo]
    let apiKey: String

    var body: some View {
        TabView {
            ForEach(photos.prefix(5), id: \.photo_reference) { photo in
                if let urlString = getPlaceImageUrl(photoReference: photo.photo_reference), let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .frame(height: 150)
                                .clipped()
                                .cornerRadius(10)
                        case .failure(_):
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .foregroundColor(.gray)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                        case .empty:
                            ProgressView()
                                .frame(height: 150)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                        @unknown default:
                            Color.gray.opacity(0.3)
                                .frame(height: 150)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .frame(height: 150)
        .tabViewStyle(PageTabViewStyle())  // Swipeable carousel
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func getPlaceImageUrl(photoReference: String?) -> String? {
        guard let photoReference = photoReference else { return nil }
        return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(apiKey)"
    }
}

