//
//  VAYCAYApp.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/30/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck

// AppDelegate for Firebase Initialization
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()  // Ensure Firebase initializes at launch

        // Enable Debug Mode for Firebase App Check (Remove in production)
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())

        return true
    }
}

@main
struct VAYCAYApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authViewModel = AuthViewModel() // Ensure AuthViewModel is available
    @StateObject private var firestoreVM = FirestoreViewModel() // Ensure Firestore is available
    @StateObject private var favoritesVM = FavoritesViewModel() // Ensure FavoritesViewModel is available

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel) // Provide AuthViewModel globally
                .environmentObject(firestoreVM) // Provide FirestoreViewModel globally
                .environmentObject(favoritesVM) // Provide FavoritesViewModel globally
        }
    }
}





