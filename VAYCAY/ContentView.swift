//
//  ContentView.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/22/25.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var firestoreVM = FirestoreViewModel()
    @StateObject private var favoritesVM = FavoritesViewModel()
    @StateObject private var unsplashAPI = UnsplashAPI.shared

    var body: some View {
        if authVM.user == nil {
            SignInView(authViewModel: authVM)
                .environmentObject(authVM)
                .environmentObject(firestoreVM)
                .environmentObject(favoritesVM)
                .environmentObject(unsplashAPI)
        } else {
            TabView {
                ExploreView()
                    .environmentObject(authVM)
                    .environmentObject(firestoreVM)
                    .environmentObject(favoritesVM)
                    .environmentObject(unsplashAPI)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Explore")
                    }

                FavoritesView()
                    .environmentObject(authVM)
                    .environmentObject(firestoreVM)
                    .environmentObject(favoritesVM)
                    .environmentObject(unsplashAPI)
                    .tabItem {
                        Image(systemName: "heart")
                        Text("Favorites")
                    }

                UserProfileView(authViewModel: authVM)
                    .environmentObject(firestoreVM)
                    .environmentObject(favoritesVM)
                    .environmentObject(unsplashAPI)
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
            }
            .tint(.blue) // Fixes selected tab color
            .onAppear {
                firestoreVM.fetchUserPreferences()
                favoritesVM.fetchFavorites()
                firestoreVM.fetchUserProfile()
                authVM.checkAuthState()
            }
        }
    }
}
