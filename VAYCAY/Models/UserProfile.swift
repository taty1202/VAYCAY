//
//  UserProfile.swift
//  VAYCAY
//
//  Created by Tatyana Araya on 1/30/25.
//

import Foundation

struct UserProfile: Identifiable, Codable {
    var id: String { userId }
    let userId: String
    let name: String
    let email: String
    var travelPreferences: [String]
    
    init(userId: String, name: String, email: String, travelPreferences: [String] = []) {
        self.userId = userId
        self.name = name
        self.email = email
        self.travelPreferences = travelPreferences
    }
}
