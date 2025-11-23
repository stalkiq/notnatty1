//
//  AuthManager.swift
//  Not Natty
//
//  Created by Apple Id on 7/26/25.
//  Copyright © 2025 Not Natty. All rights reserved.
//

/**
 * Authentication Manager
 * 
 * Handles user authentication, registration, profile management,
 * and session state. Manages user login/logout and profile data
 * in the Not Natty app.
 */

import Foundation
import SwiftUI

@MainActor
class AuthManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showEmailVerificationAlert = false
    @Published var emailVerificationMessage = ""
    // Invite-only removed – keep simple auth
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, username: String, password: String, fullName: String?) async {
        isLoading = true
        errorMessage = nil
        
        // For local testing without server
        let mockUser = User(
            id: UUID().uuidString,
            email: email,
            username: username,
            fullName: fullName,
            avatarURL: nil,
            bio: nil,
            heightCm: nil,
            weightKg: nil,
            dateOfBirth: nil,
            verificationStatus: .verified,
            emailVerified: true,
            profileData: [:],
            settings: User.UserSettings(
                privacy: .init(profileVisibility: "public", cycleVisibility: "followers", postVisibility: "public"),
                notifications: .init(newFollowers: true, likes: true, comments: true, cycleReminders: true),
                units: .init(weight: "kg", dosage: "mg", height: "cm")
            ),
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        currentUser = mockUser
        isAuthenticated = true
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // For local testing without server - accept any credentials
        let mockUser = User(
            id: UUID().uuidString,
            email: email,
            username: email.components(separatedBy: "@").first ?? "user",
            fullName: "Test User",
            avatarURL: nil,
            bio: "This is a test account for local development",
            heightCm: 180,
            weightKg: 85.0,
            dateOfBirth: nil,
            verificationStatus: .verified,
            emailVerified: true,
            profileData: [:],
            settings: User.UserSettings(
                privacy: .init(profileVisibility: "public", cycleVisibility: "followers", postVisibility: "public"),
                notifications: .init(newFollowers: true, likes: true, comments: true, cycleReminders: true),
                units: .init(weight: "kg", dosage: "mg", height: "cm")
            ),
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        currentUser = mockUser
        isAuthenticated = true
        
        isLoading = false
    }

    // Invites removed
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        errorMessage = nil
    }
    
    func verifyEmail(token: String) async {
        isLoading = true
        errorMessage = nil
        
        // For local testing - just authenticate
        if currentUser != nil {
            isAuthenticated = true
            showEmailVerificationAlert = false
        }
        
        isLoading = false
    }
    
    func resendVerification(email: String) async {
        isLoading = true
        errorMessage = nil
        
        emailVerificationMessage = "Verification email sent successfully! Please check your inbox."
        showEmailVerificationAlert = true
        
        isLoading = false
    }
    
    func forgotPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        emailVerificationMessage = "Password reset email sent successfully! Please check your inbox."
        showEmailVerificationAlert = true
        
        isLoading = false
    }
    
    func resetPassword(token: String, newPassword: String) async {
        isLoading = true
        errorMessage = nil
        
        emailVerificationMessage = "Password reset successfully! You can now log in with your new password."
        showEmailVerificationAlert = true
        
        isLoading = false
    }
    
    func updateProfile(_ user: User) async {
        isLoading = true
        errorMessage = nil
        
        // For local testing - just update the current user
        currentUser = user
        
        isLoading = false
    }
    
    // MARK: - Validation Methods
    
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validateUsername(_ username: String) -> Bool {
        return username.count >= 3 && username.count <= 20
    }
    
    func validatePassword(_ password: String) -> Bool {
        return password.count >= 8
    }
}