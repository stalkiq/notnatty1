//
//  AuthenticationView.swift
//  not natty
//
//  Created by Apple Id on 7/26/25.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var fullName = ""
    
    @State private var showForgotPassword = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange.opacity(0.8), Color.red.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // App Logo and Title
                        VStack(spacing: 20) {
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            
                            Text("Not Natty")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Track your cycle. Share your journey.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 50)
                        
                        // Authentication Form
                        VStack(spacing: 20) {
                            // Toggle between Login and Register
                            Picker("Authentication Mode", selection: $isLogin) {
                                Text("Login").tag(true)
                                Text("Register").tag(false)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                            
                            // Form Fields
                            VStack(spacing: 15) {
                                if !isLogin {
                                    // Full Name field (only for registration)
                                    TextField("Full Name (Optional)", text: $fullName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .autocapitalization(.words)
                                }
                                
                                if !isLogin {
                                    // Username field (only for registration)
                                    TextField("Username", text: $username)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .autocapitalization(.none)
                                }
                                
                                // Email field
                                TextField("Email", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                
                                // Password field
                                SecureField("Password", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            .padding(.horizontal)
                            
                            // Invite code removed

                            // Action Button
                            Button(action: {
                                Task {
                                    if isLogin {
                                        await authManager.signIn(email: email, password: password)
                                    } else {
                                        await authManager.signUp(email: email, username: username, password: password, fullName: fullName.isEmpty ? nil : fullName)
                                    }
                                }
                            }) {
                                HStack {
                                    if authManager.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text(isLogin ? "Login" : "Register")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white)
                                .foregroundColor(.orange)
                                .cornerRadius(25)
                            }
                            .disabled(authManager.isLoading || !isValidForm)
                            .opacity(isValidForm ? 1.0 : 0.6)
                            .padding(.horizontal)
                            
                            // Forgot Password (only for login)
                            if isLogin {
                                Button("Forgot Password?") {
                                    showForgotPassword = true
                                }
                                .foregroundColor(.white)
                                .font(.subheadline)
                            }
                            
                            // Error Message
                            if let errorMessage = authManager.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Footer
                        VStack(spacing: 10) {
                            Text("By continuing, you agree to our")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            HStack(spacing: 5) {
                                Button("Terms of Service") {
                                    // TODO: Show terms
                                }
                                .font(.caption)
                                .foregroundColor(.white)
                                
                                Text("and")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Button("Privacy Policy") {
                                    // TODO: Show privacy policy
                                }
                                .font(.caption)
                                .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .alert("Email Verification", isPresented: $authManager.showEmailVerificationAlert) {
            Button("OK") {
                authManager.showEmailVerificationAlert = false
            }
        } message: {
            Text(authManager.emailVerificationMessage)
        }
    }
    
    private var isValidForm: Bool {
        if isLogin {
            return !email.isEmpty && !password.isEmpty && authManager.validateEmail(email)
        } else {
            return !email.isEmpty && !password.isEmpty && !username.isEmpty && 
                   authManager.validateEmail(email) && 
                   authManager.validateUsername(username) && 
                   authManager.validatePassword(password)
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthManager())
} 