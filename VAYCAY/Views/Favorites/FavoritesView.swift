//
//  FavoritesView.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/21/25.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel() // Add the ViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Saved Destinations")
                        .font(.largeTitle)
                        .bold()
                        .padding(.leading)
                    
                    // Add Sample Favorite Button
                    Button("Add Sample Favorite") {
                        let sampleFavorite = FavoriteDestination(
                            id: UUID().uuidString,
                            name: "Eiffel Tower",
                            description: "An iconic landmark in Paris, France",
                            imageUrl: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1544609424-5265b9ea8f78",
                            timestamp: Date()
                        )
                        viewModel.addFavorite(destination: sampleFavorite)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)

                    if viewModel.favorites.isEmpty {
                        Text("No saved destinations yet.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                            ForEach(viewModel.favorites) { favorite in
                                VStack(alignment: .leading) {
                                    AsyncImage(url: URL(string: favorite.imageUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(height: 150)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    
                                    Text(favorite.name)
                                        .font(.headline)
                                        .padding(.top, 5)
                                    
                                    Text(favorite.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favorites")
            .onAppear {
                viewModel.fetchFavorites() // Fetch data when the view appears
            }
        }
    }
}
