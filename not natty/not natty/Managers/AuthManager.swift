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
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, username: String, password: String, fullName: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let (user, token) = try await APIService.shared.register(
                email: email,
                username: username,
                password: password,
                fullName: fullName ?? ""
            )
            
            // Store user but don't authenticate yet (email not verified)
            currentUser = user
            APIService.shared.setAuthToken(token)
            
            // Show email verification message
            emailVerificationMessage = "Registration successful! Please check your email to verify your account before logging in."
            showEmailVerificationAlert = true
            
        } catch {
            errorMessage = "Registration failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let (user, token) = try await APIService.shared.login(
                email: email,
                password: password
            )
            
            currentUser = user
            isAuthenticated = true
            APIService.shared.setAuthToken(token)
            
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        errorMessage = nil
        APIService.shared.clearAuthToken()
    }
    
    func verifyEmail(token: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let verifiedUser = try await APIService.shared.verifyEmail(token: token)
            currentUser = verifiedUser
            isAuthenticated = true
            showEmailVerificationAlert = false
        } catch {
            errorMessage = "Email verification failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func resendVerification(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await APIService.shared.resendVerification(email: email)
            emailVerificationMessage = "Verification email sent successfully! Please check your inbox."
            showEmailVerificationAlert = true
        } catch {
            errorMessage = "Failed to resend verification: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func forgotPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await APIService.shared.forgotPassword(email: email)
            emailVerificationMessage = "Password reset email sent successfully! Please check your inbox."
            showEmailVerificationAlert = true
        } catch {
            errorMessage = "Password reset failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func resetPassword(token: String, newPassword: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await APIService.shared.resetPassword(token: token, newPassword: newPassword)
            emailVerificationMessage = "Password reset successfully! You can now log in with your new password."
            showEmailVerificationAlert = true
        } catch {
            errorMessage = "Password reset failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateProfile(_ user: User) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedUser = try await APIService.shared.updateProfile(
                fullName: user.fullName,
                bio: user.bio,
                heightCm: user.heightCm,
                weightKg: user.weightKg,
                dateOfBirth: user.dateOfBirth
            )
            
            currentUser = updatedUser
        } catch {
            errorMessage = "Profile update failed: \(error.localizedDescription)"
        }
        
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