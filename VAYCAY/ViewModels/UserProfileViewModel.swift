//
//  UserProfileViewModel.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/21/25.


import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class UserProfileViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var userEmail: String = Auth.auth().currentUser?.email ?? "Unknown Email"
    @Published var travelPreferences: [String] = []
    
    private var db = Firestore.firestore()
    
    init() {
        fetchUserProfile()
    }

    // Fetch User Profile Data (Name, Email, Preferences)
    func fetchUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("⚠️ No user logged in.")
            return
        }

        let docRef = db.collection("users").document(userId)
        docRef.getDocument { document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists, let data = document.data() {
                    self.userName = data["name"] as? String ?? "Guest"
                    self.userEmail = data["email"] as? String ?? "Unknown Email"
                    self.travelPreferences = data["travelPreferences"] as? [String] ?? []
                } else {
                    print("❌ Error fetching user profile: \(error?.localizedDescription ?? "No data")")
                }
            }
        }
    }
    
    // Add Travel Preference
    func addPreference(_ preference: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let docRef = db.collection("users").document(userId)
        docRef.updateData([
            "travelPreferences": FieldValue.arrayUnion([preference])
        ]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error adding preference: \(error.localizedDescription)")
                } else {
                    self.travelPreferences.append(preference)
                }
            }
        }
    }

    // Remove Travel Preference
    func removePreference(at index: Int) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard index >= 0 && index < travelPreferences.count else { return }

        let preferenceToRemove = travelPreferences[index]
        let docRef = db.collection("users").document(userId)

        docRef.updateData([
            "travelPreferences": FieldValue.arrayRemove([preferenceToRemove])
        ]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error removing preference: \(error.localizedDescription)")
                } else {
                    self.travelPreferences.remove(at: index)
                }
            }
        }
    }

    // Update Travel Preference
    func updatePreference(at index: Int, with newPreference: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard index >= 0 && index < travelPreferences.count else { return }

        var updatedPreferences = travelPreferences
        updatedPreferences[index] = newPreference

        let docRef = db.collection("users").document(userId)
        docRef.updateData(["travelPreferences": updatedPreferences]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error updating preference: \(error.localizedDescription)")
                } else {
                    self.travelPreferences = updatedPreferences
                }
            }
        }
    }

    // Sign Out and Clear Data
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.userName = ""
                self.userEmail = "Unknown Email"
                self.travelPreferences = []
            }
            print("✅ User signed out.")
        } catch {
            print("❌ Error signing out: \(error.localizedDescription)")
        }
    }
}


