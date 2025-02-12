//
//  FavoritesViewModel.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/30/25.
//

import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [FavoriteDestination] = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var userId: String? { Auth.auth().currentUser?.uid }

    init() {
        // Listen for authentication state changes
        Auth.auth().addStateDidChangeListener { _, user in
            if let user = user {
                self.fetchFavorites(for: user.uid)
            } else {
                self.clearFavorites()
            }
        }
    }

    // Fetch Favorites for Logged-In User
    func fetchFavorites(for userId: String? = nil) {
        guard let userId = userId ?? self.userId else {
            print("⚠️ No user ID found.")
            return
        }

        listener?.remove() // ✅ Remove previous listener

        listener = db.collection("users").document(userId).collection("favorites").addSnapshotListener { snapshot, error in
            if let error = error {
                print("❌ Error fetching favorites: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                self.favorites = snapshot?.documents.compactMap { document in
                    try? document.data(as: FavoriteDestination.self)
                } ?? []
                print("✅ Loaded \(self.favorites.count) favorites for \(userId)")
            }
        }
    }

    // Add Favorite to Firestore
    func addFavorite(destination: FavoriteDestination) {
        // Check if the favorite already exists
        if favorites.contains(where: { $0.place_id == destination.place_id }) {
            print("⚠️ \(destination.name) is already in favorites.")
            return
        }

        // Append to local favorites list
        favorites.append(destination)

        // Ensure user is logged in
        guard let userId = userId else {
            print("❌ No user ID found. Cannot save favorite.")
            return
        }

        // Save to Firestore
        let docRef = db.collection("users").document(userId).collection("favorites").document(destination.place_id)

        do {
            try docRef.setData(from: destination) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Error adding favorite to Firestore: \(error.localizedDescription)")
                    } else {
                        print("❤️ Successfully added \(destination.name) to Firestore!")
                    }
                }
            }
        } catch {
            print("❌ Firestore data encoding error: \(error.localizedDescription)")
        }
    }

    // Remove Favorite from Firestore
    func removeFavorite(destination: FavoriteDestination) {
        guard let userId = userId else { return }

        db.collection("users").document(userId).collection("favorites").document(destination.place_id).delete { error in
            if let error = error {
                print("❌ Error removing favorite: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.favorites.removeAll { $0.place_id == destination.place_id }
                    print("💔 Removed favorite: \(destination.name)")
                }
            }
        }
    }

    // Clear Favorites When Signing Out
    func clearFavorites() {
        DispatchQueue.main.async {
            self.favorites = []
            self.listener?.remove()
            self.listener = nil
            print("🚫 Cleared all favorites")
        }
    }
}




