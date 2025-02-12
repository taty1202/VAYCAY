//
//  AuthViewModel.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/30/25.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var authMessage: String = ""
    @Published var userName: String = ""

    private var authStateListener: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()

    init() {
        authStateListener = Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.user = user
                if let uid = user?.uid {
                    self.fetchUserName(uid: uid)
                }
            }
        }
    }

    // Cleanup listener
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    func checkAuthState() {
        self.user = Auth.auth().currentUser
        if let uid = user?.uid {
            fetchUserName(uid: uid) 
        }
    }

    // Fetch User's Name from Firestore
    private func fetchUserName(uid: String) {
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists, let data = document.data(), let name = data["name"] as? String {
                DispatchQueue.main.async {
                    self.userName = name
                }
            } else {
                self.authMessage = "⚠️ No name found."
            }
        }
    }

    // Sign Up with Email and Store Name in Firestore
    func signUpWithEmail(email: String, password: String, name: String) {
        guard !name.isEmpty else {
            authMessage = "❌ Please enter your full name."
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.authMessage = "❌ Error: \(error.localizedDescription)"
                } else if let user = authResult?.user {
                    self.user = user
                    self.userName = name

                    // Store user data in Firestore
                    let userData: [String: Any] = ["uid": user.uid, "email": email, "name": name]
                    self.db.collection("users").document(user.uid).setData(userData) { error in
                        if let error = error {
                            self.authMessage = "❌ Failed to save user data: \(error.localizedDescription)"
                        } else {
                            self.authMessage = "✅ Account created successfully!"
                        }
                    }
                }
            }
        }
    }

    // Sign In with Email
    func signInWithEmail(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.authMessage = "❌ Error: \(error.localizedDescription)"
                } else if let user = authResult?.user {
                    self.user = user
                    self.authMessage = "✅ Signed in as \(self.user?.email ?? "unknown")"
                    self.fetchUserName(uid: user.uid)
                }
            }
        }
    }
    
    // Google Sign-In
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.authMessage = "❌ Google sign-in failed: \(error.localizedDescription)"
                    }
                    return
                }

                guard let authentication = result?.user, let idToken = authentication.idToken else {
                    return
                }

                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                               accessToken: authentication.accessToken.tokenString)
                Auth.auth().signIn(with: credential) { authResult, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.authMessage = "❌ Google sign-in failed: \(error.localizedDescription)"
                        } else if let user = authResult?.user {
                            self.user = user
                            self.authMessage = "✅ Google sign-in successful!"

                            // Extract name if available from Google
                            let fullName = result?.user.profile?.name ?? "Unknown User"
                            self.userName = fullName

                            // Store Google sign-in user in Firestore
                            let userData: [String: Any] = ["uid": user.uid, "email": user.email ?? "", "name": fullName]
                            self.db.collection("users").document(user.uid).setData(userData, merge: true)
                        }
                    }
                }
            }
        } else {
            self.authMessage = "❌ Unable to find root view controller."
        }
    }

    // Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.user = nil
                self.userName = ""
                self.authMessage = "✅ Signed out successfully!"
            }
        } catch {
            self.authMessage = "❌ Error signing out: \(error.localizedDescription)"
        }
    }
}

