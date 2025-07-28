//
//  APIService.swift
//  not natty
//
//  Created by Apple Id on 7/28/25.
//

import Foundation
import SwiftUI

class APIService: ObservableObject {
    static let shared = APIService()
    
    private let baseURL = "https://your-amplify-backend-url.execute-api.us-east-1.amazonaws.com/api"
    private var authToken: String?
    
    private init() {}
    
    // MARK: - Authentication
    
    func login(email: String, password: String) async throws -> (user: User, token: String) {
        let url = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        self.authToken = loginResponse.token
        
        return (loginResponse.user, loginResponse.token)
    }
    
                    func register(email: String, username: String, password: String, fullName: String) async throws -> (user: User, token: String) {
                    let url = URL(string: "\(baseURL)/auth/register")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let body: [String: Any] = [
                        "email": email,
                        "username": username,
                        "password": password,
                        "fullName": fullName
                    ]
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    
                    let (data, response) = try await URLSession.shared.data(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIError.invalidResponse
                    }
                    
                    if httpResponse.statusCode == 409 {
                        // User already exists
                        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        throw APIError.userAlreadyExists(errorResponse.message)
                    }
                    
                    guard httpResponse.statusCode == 201 else {
                        throw APIError.invalidResponse
                    }
                    
                    let registerResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    self.authToken = registerResponse.token
                    
                    return (registerResponse.user, registerResponse.token)
                }
                
                func verifyEmail(token: String) async throws -> User {
                    let url = URL(string: "\(baseURL)/auth/verify-email?token=\(token)")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    
                    let (data, response) = try await URLSession.shared.data(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw APIError.invalidResponse
                    }
                    
                    let verifyResponse = try JSONDecoder().decode(VerifyEmailResponse.self, from: data)
                    return verifyResponse.user
                }
                
                func resendVerification(email: String) async throws {
                    let url = URL(string: "\(baseURL)/auth/resend-verification")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let body: [String: Any] = ["email": email]
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    
                    let (_, response) = try await URLSession.shared.data(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw APIError.invalidResponse
                    }
                }
                
                func forgotPassword(email: String) async throws {
                    let url = URL(string: "\(baseURL)/auth/forgot-password")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let body: [String: Any] = ["email": email]
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    
                    let (_, response) = try await URLSession.shared.data(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw APIError.invalidResponse
                    }
                }
                
                func resetPassword(token: String, newPassword: String) async throws {
                    let url = URL(string: "\(baseURL)/auth/reset-password")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let body: [String: Any] = [
                        "token": token,
                        "newPassword": newPassword
                    ]
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)
                    
                    let (_, response) = try await URLSession.shared.data(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw APIError.invalidResponse
                    }
                }
    
    // MARK: - Posts
    
    func getPosts() async throws -> [Post] {
        let url = URL(string: "\(baseURL)/posts")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode([Post].self, from: data)
    }
    
    func createPost(content: String, postType: String, privacyLevel: String, compoundTags: [String] = []) async throws -> Post {
        let url = URL(string: "\(baseURL)/posts")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        // Map iOS post types to backend post types
        let backendPostType: String
        switch postType {
        case "general":
            backendPostType = "progress"
        case "injection":
            backendPostType = "cycle"
        case "progress":
            backendPostType = "progress"
        case "meal":
            backendPostType = "achievement"
        case "workout":
            backendPostType = "achievement"
        case "side_effect":
            backendPostType = "cycle"
        default:
            backendPostType = "progress"
        }
        
        let body: [String: Any] = [
            "content": content,
            "postType": backendPostType,
            "privacyLevel": privacyLevel,
            "compoundTags": compoundTags
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(Post.self, from: data)
    }
    
    func likePost(postId: String) async throws -> (liked: Bool, likesCount: Int) {
        let url = URL(string: "\(baseURL)/posts/\(postId)/like")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let likeResponse = try JSONDecoder().decode(LikeResponse.self, from: data)
        return (likeResponse.liked, likeResponse.likesCount)
    }
    
    // MARK: - Comments
    
    func getComments(postId: String) async throws -> [Comment] {
        let url = URL(string: "\(baseURL)/posts/\(postId)/comments")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode([Comment].self, from: data)
    }
    
    func addComment(postId: String, content: String) async throws -> Comment {
        let url = URL(string: "\(baseURL)/posts/\(postId)/comments")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let body = ["content": content]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(Comment.self, from: data)
    }
    
    // MARK: - Cycles
    
    func getCycles() async throws -> [Cycle] {
        let url = URL(string: "\(baseURL)/cycles")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode([Cycle].self, from: data)
    }
    
    func createCycle(name: String, description: String?, startDate: Date, endDate: Date?, goals: [String], notes: String?) async throws -> Cycle {
        let url = URL(string: "\(baseURL)/cycles")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let dateFormatter = ISO8601DateFormatter()
        var body: [String: Any] = [
            "name": name,
            "startDate": dateFormatter.string(from: startDate),
            "goals": goals
        ]
        
        if let description = description {
            body["description"] = description
        }
        if let endDate = endDate {
            body["endDate"] = dateFormatter.string(from: endDate)
        }
        if let notes = notes {
            body["notes"] = notes
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(Cycle.self, from: data)
    }
    
    // MARK: - Injections
    
    func getInjections() async throws -> [Injection] {
        let url = URL(string: "\(baseURL)/injections")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode([Injection].self, from: data)
    }
    
    func createInjection(compoundId: String, dosage: Double, injectionSite: String, injectedAt: Date, cycleId: String?, notes: String?) async throws -> Injection {
        let url = URL(string: "\(baseURL)/injections")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let dateFormatter = ISO8601DateFormatter()
        var body: [String: Any] = [
            "compoundId": compoundId,
            "dosage": dosage,
            "injectionSite": injectionSite,
            "injectedAt": dateFormatter.string(from: injectedAt)
        ]
        
        if let cycleId = cycleId {
            body["cycleId"] = cycleId
        }
        if let notes = notes {
            body["notes"] = notes
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(Injection.self, from: data)
    }
    
    // MARK: - Side Effects
    
    func getSideEffects() async throws -> [SideEffect] {
        let url = URL(string: "\(baseURL)/side-effects")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode([SideEffect].self, from: data)
    }
    
    func createSideEffect(symptoms: [String], severity: Int, recordedAt: Date, cycleId: String?, bloodPressureSystolic: Int?, bloodPressureDiastolic: Int?, moodRating: Int?, libidoRating: Int?, acneSeverity: Int?, notes: String?) async throws -> SideEffect {
        let url = URL(string: "\(baseURL)/side-effects")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let dateFormatter = ISO8601DateFormatter()
        var body: [String: Any] = [
            "symptoms": symptoms,
            "severity": severity,
            "recordedAt": dateFormatter.string(from: recordedAt)
        ]
        
        if let cycleId = cycleId {
            body["cycleId"] = cycleId
        }
        if let bloodPressureSystolic = bloodPressureSystolic {
            body["bloodPressureSystolic"] = bloodPressureSystolic
        }
        if let bloodPressureDiastolic = bloodPressureDiastolic {
            body["bloodPressureDiastolic"] = bloodPressureDiastolic
        }
        if let moodRating = moodRating {
            body["moodRating"] = moodRating
        }
        if let libidoRating = libidoRating {
            body["libidoRating"] = libidoRating
        }
        if let acneSeverity = acneSeverity {
            body["acneSeverity"] = acneSeverity
        }
        if let notes = notes {
            body["notes"] = notes
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(SideEffect.self, from: data)
    }
    
    // MARK: - Users
    
    func getVerifiedUsers() async throws -> [VerifiedProfile] {
        let url = URL(string: "\(baseURL)/users/verified/list")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode([VerifiedProfile].self, from: data)
    }
    
    func updateProfile(fullName: String?, bio: String?, heightCm: Int?, weightKg: Double?, dateOfBirth: Date?) async throws -> User {
        let url = URL(string: "\(baseURL)/users/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        
        var body: [String: Any] = [:]
        
        if let fullName = fullName {
            body["fullName"] = fullName
        }
        if let bio = bio {
            body["bio"] = bio
        }
        if let heightCm = heightCm {
            body["heightCm"] = heightCm
        }
        if let weightKg = weightKg {
            body["weightKg"] = weightKg
        }
        if let dateOfBirth = dateOfBirth {
            let dateFormatter = ISO8601DateFormatter()
            body["dateOfBirth"] = dateFormatter.string(from: dateOfBirth)
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(User.self, from: data)
    }
    
    // MARK: - Helper Methods
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    func clearAuthToken() {
        self.authToken = nil
    }
}

// MARK: - Response Models

struct LoginResponse: Codable {
    let message: String
    let user: User
    let token: String
}

struct LikeResponse: Codable {
    let liked: Bool
    let likesCount: Int
}

struct VerifyEmailResponse: Codable {
    let message: String
    let user: User
}

struct ErrorResponse: Codable {
    let error: String
    let message: String
}

// MARK: - Error Types

enum APIError: Error, LocalizedError {
    case invalidResponse
    case networkError
    case decodingError
    case userAlreadyExists(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError:
            return "Network error occurred"
        case .decodingError:
            return "Failed to decode response"
        case .userAlreadyExists(let message):
            return message
        }
    }
} 