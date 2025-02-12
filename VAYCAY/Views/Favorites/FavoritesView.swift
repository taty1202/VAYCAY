//
//  FavoritesView.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/21/25.

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    @State private var unsplashImageURLs: [String: URL] = [:]
    private let unsplashAPI = UnsplashAPI.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    if favoritesVM.favorites.isEmpty {
                        Text("No saved destinations yet.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                    } else {
                        favoritesList()
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Favorites")
                        .foregroundColor(.black)
                        .bold()
                }
            }
            .onAppear {
                favoritesVM.fetchFavorites()
            }
        }
    }

    private func favoritesList() -> some View {
        VStack(spacing: 20) {
            ForEach(favoritesVM.favorites) { favorite in
                NavigationLink(destination: PlaceDetailsView(place: favorite.toGooglePlace(), isFavoriteView: true)) {
                    favoriteCard(favorite: favorite)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func favoriteCard(favorite: FavoriteDestination) -> some View {
        VStack {
            placeImage(for: favorite)
                .frame(height: 200)
                .cornerRadius(10)
                .clipped()

            Text(favorite.name)
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity, minHeight: 40)
                .padding(.horizontal, 5)
                .padding(.top, 5)

            Button(action: {
                favoritesVM.removeFavorite(destination: favorite)
            }) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
            }
            .padding(.top, 5)
        }
        .frame(width: 350, height: 280)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }

    private func placeImage(for favorite: FavoriteDestination) -> AnyView {
        if let urlString = favorite.imageUrl, let url = URL(string: urlString), url.scheme != nil {
            return AnyView(
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        return AnyView(
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 350, height: 200)
                                .cornerRadius(10)
                                .clipped()
                        )
                    case .failure(_):
                        print("❌ Failed to load Google Place image, using Unsplash.")
                        return AnyView(unsplashFallback(for: favorite.name))
                    case .empty:
                        return AnyView(
                            ProgressView()
                                .frame(width: 350, height: 200)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                        )
                    @unknown default:
                        return AnyView(defaultPlaceholder())
                    }
                }
            )
        } else {
            return AnyView(unsplashFallback(for: favorite.name))
        }
    }

    private func unsplashFallback(for query: String) -> AnyView {
        if let cachedURL = unsplashImageURLs[query] {
            return AnyView(
                AsyncImage(url: cachedURL) { phase in
                    switch phase {
                    case .success(let image):
                        return AnyView(
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 350, height: 200)
                                .cornerRadius(10)
                                .clipped()
                        )
                    default:
                        return AnyView(defaultPlaceholder())
                    }
                }
            )
        } else {
            fetchUnsplashImage(for: query) // Fetch Unsplash image
            return AnyView(defaultPlaceholder()) // Placeholder until image loads
        }
    }


    private func fetchUnsplashImage(for query: String) {
        UnsplashAPI.shared.getImageURL(for: query) { urlString in
            DispatchQueue.main.async {
                if let urlString = urlString, let url = URL(string: urlString) {
                    self.unsplashImageURLs[query] = url
                } else {
                    print("❌ Failed Unsplash image for: \(query), using default travel image.")
                    self.unsplashImageURLs[query] = URL(string: "https://source.unsplash.com/400x300/?travel")
                }
            }
        }
    }

    private func defaultPlaceholder() -> some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: 350, height: 200)
            .foregroundColor(.gray)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(10)
    }
}





