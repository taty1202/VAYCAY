//
//  UserProfileViewModel.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/21/25.
//

import FirebaseFirestore
import FirebaseAuth  
import SwiftUI

class UserProfileViewModel: ObservableObject {
    @Published var travelPreferences: [String] = []
    private let db = Firestore.firestore()

    // Fetch travel preferences from Firestore
    func fetchTravelPreferences() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user found.")
            return
        }
        
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                if let preferences = document.data()?["travelPreferences"] as? [String] {
                    DispatchQueue.main.async {
                        self.travelPreferences = preferences
                    }
                }
            } else {
                print("❌ Error fetching preferences: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    // **Save preferences to Firestore**
    func saveTravelPreferences(_ preferences: [String]) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user found.")
            return
        }

        let userRef = db.collection("users").document(userId)
        
        userRef.setData(["travelPreferences": preferences], merge: true) { error in
            if let error = error {
                print("❌ Error saving travel preferences: \(error.localizedDescription)")
            } else {
                print("✅ Travel preferences saved successfully to Firestore: \(preferences)")
            }
        }
    }

    // **Function to add a new preference**
    func addPreference(_ preference: String) {
        guard !preference.isEmpty, !travelPreferences.contains(preference) else { return }
        travelPreferences.append(preference)
        saveTravelPreferences(travelPreferences) // Save after updating
    }
}





