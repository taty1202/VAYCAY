//
//  ExploreView.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 2/3/25.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var firestoreVM: FirestoreViewModel
    @EnvironmentObject var favoritesVM: FavoritesViewModel

    @State private var categoryImages: [String: String] = [:]
    private let unsplashAPI = UnsplashAPI.shared

    let categories = ["Beaches", "Cities", "Mountains", "Deserts", "Cuisine", "Hotels"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink(destination: CategoryDetailView(category: category, viewModel: CategoryDetailViewModel(firestoreVM: firestoreVM))
                            .environmentObject(favoritesVM)
                        ) {
                            categoryCard(for: category)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .tint(.blue)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Explore")
                        .foregroundColor(.black)
                        .bold()
                }
            }
            .onAppear {
                loadImages()
            }
        }
    }

    private func loadImages() {
        for category in categories {
            if categoryImages[category] == nil {
                unsplashAPI.fetchImages(for: category) { urls in
                    if let firstImage = urls?.first {
                        DispatchQueue.main.async {
                            categoryImages[category] = firstImage
                        }
                    } else {
                        DispatchQueue.main.async {
                            categoryImages[category] = "https://source.unsplash.com/random/400x300/?\(category)"
                        }
                    }
                }
            }
        }
    }

    private func categoryCard(for category: String) -> some View {
        ZStack {
            AsyncImage(url: categoryImages[category].flatMap { URL(string: $0) }) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                case .failure(_):
                    fallbackImage(for: category)
                case .empty:
                    ProgressView()
                        .frame(height: 200)
                @unknown default:
                    fallbackImage(for: category)
                }
            }

            Text(category)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.6))
                .cornerRadius(10)
                .padding(10)
        }
        .frame(height: 200)
        .padding(.horizontal)
    }

    private func fallbackImage(for category: String) -> some View {
        AsyncImage(url: URL(string: "https://source.unsplash.com/random/400x300/?\(category)")) { phase in
            switch phase {
            case .success(let image):
                image.resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .cornerRadius(15)
                    .shadow(radius: 3)
            default:
                Color.gray.opacity(0.3)
                    .frame(height: 200)
                    .cornerRadius(15)
                    .shadow(radius: 3)
            }
        }
    }
}

