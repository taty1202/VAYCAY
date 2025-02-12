//
//  CategoryCardView.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 2/4/25.
//

import SwiftUI

struct CategoryCardView: View {
    let category: String
    let imageUrls: [String]  // Accept an array of images

    var body: some View {
        ZStack {
            if imageUrls.isEmpty {
                Color.gray.opacity(0.3)
                    .frame(height: 150)
            } else {
                TabView {
                    ForEach(imageUrls, id: \.self) { imageUrl in
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image.resizable()
                                .scaledToFill()
                                .frame(height: 150)
                                .clipped()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                                .frame(height: 150)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic)) // Enables swipeable images
            }

            Text(category)
                .font(.headline)
                .bold()
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}





