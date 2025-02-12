//
//  CategoryDetailView.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 2/3/25.


import SwiftUI

struct CategoryDetailView: View {
    let category: String
    @ObservedObject var viewModel: CategoryDetailViewModel
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    @State private var selectedLocation: String = "Seattle"
    @State private var selectedPlace: GooglePlace?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 15) { // Adjusted spacing
                    // Sticky Header
                    GeometryReader { geometry in
                        let offset = geometry.frame(in: .global).minY
                        Text(category)
                            .font(.system(size: max(22, 36 - offset / 10)))
                            .bold()
                            .padding(.top, max(10, 20 - offset / 10))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .animation(.easeInOut(duration: 0.3), value: offset)
                    }
                    .frame(height: 50)
                    .zIndex(1)

                    // Search Bar for Location
                    VStack {
                        TextField("Enter a location", text: $selectedLocation, onCommit: {
                            viewModel.loadPlaces(for: category, location: selectedLocation)
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 50)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .contentShape(Rectangle())
                    }
                    .padding(.top, 20)

                    // Places List
                    LazyVStack(spacing: 25) {
                        if viewModel.places.isEmpty {
                            Text(viewModel.errorMessage ?? "No results found.")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(viewModel.places) { place in
                                Button(action: {
                                    selectedPlace = place
                                }) {
                                    PlaceCardView(place: place)
                                        .frame(height: 180)
                                        .padding(.horizontal, 16)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if viewModel.places.isEmpty {
                    viewModel.loadPlaces(for: category, location: selectedLocation)
                }
            }
            .navigationDestination(item: $selectedPlace) { place in
                PlaceDetailsView(place: place, isFavoriteView: false)
            }
        }
    }
}

