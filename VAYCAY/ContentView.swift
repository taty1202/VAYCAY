//
//  ContentView.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/22/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userProfileVM = UserProfileViewModel()
    @StateObject private var authVM = AuthViewModel() // Added AuthViewModel

    var body: some View {
        Group {
            if authVM.user == nil {
                SignInView(authViewModel: authVM) // Show Sign-In if user is not logged in
            } else {
                TabView {
                    SearchView()
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                            Text("Search")
                        }
                    
                    FavoritesView()
                        .tabItem {
                            Image(systemName: "heart")
                            Text("Favorites")
                        }

                    UserProfileView(viewModel: userProfileVM, authViewModel: authVM) // Pass authVM to profile
                        .tabItem {
                            Image(systemName: "person")
                            Text("Profile")
                        }
                }
            }
        }
        .onAppear {
            authVM.checkAuthState() // Check sign-in state on app launch
        }
    }
}
