//
//  UserProfileView.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/21/25.
//

import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @ObservedObject var authViewModel: AuthViewModel
    
    init(viewModel: UserProfileViewModel, authViewModel: AuthViewModel) {
        self.viewModel = viewModel
        self.authViewModel = authViewModel
    }

    var body: some View {
        VStack {
            Text("Profile")
                .font(.largeTitle)
                .bold()
                .padding()

            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
                .padding()

            // Display User's Name and Email Dynamically
            Text(authViewModel.user?.displayName ?? "No Name")
                .font(.title)
                .bold()

            Text(authViewModel.user?.email ?? "No Email")
                .font(.subheadline)
                .foregroundColor(.gray)

            Divider()

            Text("Travel Preferences")
                .font(.headline)
                .padding(.top)

            if viewModel.travelPreferences.isEmpty {
                Text("No preferences saved.")
                    .foregroundColor(.gray)
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(viewModel.travelPreferences, id: \.self) { preference in
                            Text(preference)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                        }
                    }
                }
            }

            NavigationLink(destination: UserPreferencesView(viewModel: viewModel)) {
                Text("Edit Preferences")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            // Sign Out Button
            Button("Sign Out") {
                authViewModel.signOut()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top, 20)
        }
        .onAppear {
            viewModel.fetchTravelPreferences()
        }
    }
}
