//
//  PlaceDetailsView.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 2/3/25.


import SwiftUI
import Foundation

struct PlaceDetailsView: View {
    let place: GooglePlace
    let isFavoriteView: Bool
    @State private var detailedPlace: PlaceDetails?
    @State private var reviews: [Review] = []
    @State private var unsplashImageURL: URL? = nil // Store Unsplash image
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    @EnvironmentObject var unsplashAPI: UnsplashAPI // UnsplashAPI
    @State private var showFavoriteAlert = false
    private let googlePlacesAPI = GooglePlacesAPI()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    if let photos = detailedPlace?.photos, !photos.isEmpty {
                        TabView {
                            ForEach(photos, id: \.photo_reference) { photo in
                                let imageUrlString = googlePlacesAPI.getPlaceImageUrl(photoReference: photo.photo_reference)
                                if let imageURL = URL(string: imageUrlString) {
                                    AsyncImage(url: imageURL) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(height: 250)
                                                .clipped()
                                        default:
                                            defaultPlaceholder()
                                        }
                                    }
                                }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                        .frame(height: 250)
                    } else if let unsplashURL = unsplashImageURL { // ✅ If Unsplash image is available
                        AsyncImage(url: unsplashURL) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                                    .scaledToFill()
                                    .frame(height: 250)
                                    .clipped()
                            default:
                                defaultPlaceholder()
                            }
                        }
                        .frame(height: 250)
                    } else {
                        defaultPlaceholder()
                            .frame(height: 250)
                    }

                    // Favorite Button in Top Right Corner
                    Button(action: {
                        toggleFavorite()
                    }) {
                        Image(systemName: favoritesVM.favorites.contains(where: { $0.place_id == place.place_id }) ? "heart.fill" : "heart")
                            .foregroundColor(favoritesVM.favorites.contains(where: { $0.place_id == place.place_id }) ? .red : .gray)
                            .padding(8)
                            .background(Color.white.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .padding(10)
                }

                // Place Name
                Text(place.name)
                    .font(.largeTitle)
                    .bold()

                if !isFavoriteView {
                    if let rating = place.rating, let totalRatings = place.user_ratings_total {
                        Text("⭐ \(rating, specifier: "%.1f") (\(totalRatings) reviews)")
                            .font(.headline)
                            .foregroundColor(.gray)
                    } else {
                        Text("⭐ \(place.rating ?? 0.0, specifier: "%.1f") (No reviews yet)")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }

                if let vicinity = place.vicinity {
                    Text("📍 \(vicinity)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Divider()

                if !isFavoriteView {
                    Text("Traveler Reviews")
                        .font(.title2)
                        .bold()
                        .padding(.top)

                    if reviews.isEmpty {
                        Text("No reviews available.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(reviews) { review in
                            VStack(alignment: .leading, spacing: 5) {
                                if let rating = review.rating, let author = review.author_name {
                                    Text("⭐ \(rating, specifier: "%.1f") - \(author)")
                                        .font(.headline)
                                        .bold()
                                }
                                if let text = review.text {
                                    Text(text)
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 5)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            fetchPlaceDetails()
            fetchReviews()
            fetchUnsplashImage(for: place.name) // Unsplash Image
        }
        .alert(isPresented: $showFavoriteAlert) {
            Alert(title: Text("Added to Favorites"), message: Text("\(place.name) has been saved!"), dismissButton: .default(Text("OK")))
        }
//        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false) // Only keeps system back button
    }

    private func fetchPlaceDetails() {
        googlePlacesAPI.fetchPlaceDetails(placeID: place.place_id) { details in
            DispatchQueue.main.async {
                self.detailedPlace = details
            }
        }
    }

    private func fetchReviews() {
        googlePlacesAPI.fetchReviews(placeID: place.place_id) { fetchedReviews in
            DispatchQueue.main.async {
                self.reviews = fetchedReviews ?? []
            }
        }
    }
    private func fetchUnsplashImage(for query: String) {
        unsplashAPI.getImageURL(for: query) { urlString in
            DispatchQueue.main.async {
                if let urlString = urlString, let url = URL(string: urlString) {
                    self.unsplashImageURL = url
                } else {
                    print("❌ Failed to get valid Unsplash image for: \(query), using default travel image.")
                    self.unsplashImageURL = URL(string: "https://source.unsplash.com/400x300/?travel") // Default image
                }
            }
        }
    }


    private func toggleFavorite() {
        if let existingFavorite = favoritesVM.favorites.first(where: { $0.place_id == place.place_id }) {
            favoritesVM.removeFavorite(destination: existingFavorite)
        } else {
            let favorite = FavoriteDestination(
                place_id: place.place_id,
                name: place.name,
                imageUrl: place.photos?.first?.photo_reference,
                location: place.vicinity,
                rating: place.rating
            )
            favoritesVM.addFavorite(destination: favorite)
            showFavoriteAlert = true
        }
    }

    private func defaultPlaceholder() -> some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
            .foregroundColor(.gray)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(10)
    }
}
