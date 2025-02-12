//
//  UserProfileView.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/21/25.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var firestoreVM: FirestoreViewModel
    @ObservedObject var authViewModel: AuthViewModel

    @State private var newPreference: String = ""
    @State private var isEditing: Bool = false
    @State private var editingIndex: Int?

    var body: some View {
        ScrollView { // Added ScrollView to prevent layout cut-off
            VStack {
                Text("User Profile")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                Divider()

                // Display user info
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                    Text("Name: \(firestoreVM.userName.isEmpty ? "Unknown" : firestoreVM.userName)")
                        .font(.headline)
                        .bold()
                }
                .padding(.top, 10)

                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.blue)
                    Text("Email: \(firestoreVM.userEmail)")
                        .font(.subheadline)
                }
                .padding(.bottom, 10)

                Divider()

                Text("Your Travel Preferences")
                    .font(.headline)
                    .padding(.top)

                if firestoreVM.favoriteCities.isEmpty {
                    Text("No preferences saved yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    preferenceList()
                }

                Divider()

                TextField("Enter a city or country", text: $newPreference)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)

                HStack {
                    Button("Cancel") {
                        resetInput()
                    }
                    .padding()
                    .foregroundColor(.red)

                    Button(action: {
                        if let index = editingIndex {
                            firestoreVM.updateFavoriteCity(at: index, with: newPreference)
                        } else {
                            firestoreVM.addFavoriteCity(city: newPreference)
                        }
                        resetInput()
                    }) {
                        Text(editingIndex == nil ? "Add" : "Update")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                    .disabled(newPreference.isEmpty)
                    .opacity(newPreference.isEmpty ? 0.5 : 1) // If empty, it dims slightly but stays blue
                }

                Divider()

                Button("Sign Out") {
                    authViewModel.signOut()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                .frame(width: 200)
                .padding(.top, 20)

            }
            .padding()
            .onAppear {
                firestoreVM.fetchUserProfile() // Ensure data loads
                firestoreVM.fetchUserPreferences()
            }
        }
    }

    private func preferenceList() -> some View {
        VStack {
            ForEach(firestoreVM.favoriteCities.indices, id: \.self) { index in
                preferenceRow(preference: firestoreVM.favoriteCities[index], index: index)
            }
        }
    }

    private func preferenceRow(preference: String, index: Int) -> some View {
        HStack {
            Text(preference)
                .font(.headline)
                .padding()

            Spacer()

            Button(action: {
                newPreference = preference
                editingIndex = index
                isEditing = true
            }) {
                Image(systemName: "pencil")
            }
            .padding()

            Button(action: {
                firestoreVM.removeFavoriteCity(city: preference)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .padding()
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
        .padding(.horizontal)
    }

    private func resetInput() {
        newPreference = ""
        isEditing = false
        editingIndex = nil
    }
}
