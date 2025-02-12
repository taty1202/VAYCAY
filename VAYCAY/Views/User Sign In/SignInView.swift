//
//  SignInView.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/30/25.
//

import SwiftUI

struct SignInView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var name = "" // Name field
    @State private var isSigningUp = false // Tracks if user is in "Sign Up" mode

    var body: some View {
        VStack {
            Text("VAYCAY")
                .font(.system(size: 40, weight: .bold, design: .serif))
                .foregroundColor(.blue)
                .shadow(color: .gray, radius: 3, x: 2, y: 2)
                .padding()

            if isSigningUp {
                TextField("Enter your full name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                    .padding()
            }

            TextField("Enter email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()

            SecureField("Enter password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()

            HStack {
                Button("Sign In") {
                    authViewModel.signInWithEmail(email: email, password: password)
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button(isSigningUp ? "Confirm Sign Up" : "Sign Up") {
                    if isSigningUp {
                        authViewModel.signUpWithEmail(email: email, password: password, name: name)
                    } else {
                        isSigningUp = true // Show name field when signing up
                    }
                }
                .padding()
                .background(isSigningUp ? Color.blue : Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()

            Button("Sign in with Google") {
                authViewModel.signInWithGoogle()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Text(authViewModel.authMessage)
                .foregroundColor(authViewModel.authMessage.contains("✅") ? .green : .red)
                .padding()
        }
        .padding()
    }
}
