//
//  APIService.swift
//  Not Natty
//
//  Created by Apple Id on 7/26/25.
//  Copyright © 2025 Not Natty. All rights reserved.
//

/**
 * API Service
 * 
 * Handles all backend API communication for the Not Natty app.
 * Provides methods for authentication, posts, cycles, and user management.
 */

import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://api.notnatty.com" // unused in offline mode
    private var authToken: String?
    var offlineMode: Bool = true
    
    private init() {}
    
    // MARK: - Authentication
    
    func setAuthToken(_ token: String) {
        authToken = token
    }
    
    func clearAuthToken() {
        authToken = nil
    }
    
    private func getAuthHeaders() -> [String: String] {
        var headers = ["Content-Type": "application/json"]
        if let token = authToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
    
    // MARK: - Authentication Endpoints
    
    func register(email: String, username: String, password: String, fullName: String) async throws -> (User, String) {
        let url = URL(string: "\(baseURL)/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        let body = [
            "email": email,
            "username": username,
            "password": password,
            "full_name": fullName
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.invalidResponse
        }
        
        let responseData = try JSONDecoder().decode(AuthResponse.self, from: data)
        return (responseData.user, responseData.token)
    }
    
    func login(email: String, password: String) async throws -> (User, String) {
        let url = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        let body = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let responseData = try JSONDecoder().decode(AuthResponse.self, from: data)
        return (responseData.user, responseData.token)
    }
    
    func verifyEmail(token: String) async throws -> User {
        let url = URL(string: "\(baseURL)/auth/verify-email")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        let body = ["token": token]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let user = try JSONDecoder().decode(User.self, from: data)
        return user
    }
    
    func resendVerification(email: String) async throws {
        let url = URL(string: "\(baseURL)/auth/resend-verification")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        let body = ["email": email]
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
        request.allHTTPHeaderFields = getAuthHeaders()
        
        let body = ["email": email]
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
        request.allHTTPHeaderFields = getAuthHeaders()
        
        let body = [
            "token": token,
            "new_password": newPassword
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
    }
    
    // MARK: - User Management
    
    func updateProfile(fullName: String?, bio: String?, heightCm: Int?, weightKg: Double?, dateOfBirth: Date?) async throws -> User {
        let url = URL(string: "\(baseURL)/users/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        var body: [String: Any] = [:]
        if let fullName = fullName { body["full_name"] = fullName }
        if let bio = bio { body["bio"] = bio }
        if let heightCm = heightCm { body["height_cm"] = heightCm }
        if let weightKg = weightKg { body["weight_kg"] = weightKg }
        if let dateOfBirth = dateOfBirth { body["date_of_birth"] = ISO8601DateFormatter().string(from: dateOfBirth) }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let user = try JSONDecoder().decode(User.self, from: data)
        return user
    }
    
    // MARK: - Posts
    
    func getPosts() async throws -> [Post] {
        if offlineMode {
            return []
        }
        let url = URL(string: "\(baseURL)/posts")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let posts = try JSONDecoder().decode([Post].self, from: data)
        return posts
    }
    
    func createPost(content: String, mediaURLs: [String], compoundTags: [String], privacyLevel: Post.PrivacyLevel, postType: Post.PostType) async throws -> Post {
        if offlineMode {
            return Post(
                id: UUID().uuidString,
                userId: "local-user",
                content: content,
                mediaURLs: mediaURLs,
                compoundTags: compoundTags,
                privacyLevel: .private,
                postType: postType,
                relatedInjectionId: nil,
                relatedCycleId: nil,
                engagementMetrics: .init(likes: 0, comments: 0, reposts: 0),
                isDeleted: false,
                createdAt: Date(),
                updatedAt: Date(),
                user: nil,
                comments: [],
                isLiked: false
            )
        }
        let url = URL(string: "\(baseURL)/posts")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        let body: [String: Any] = [
            "content": content,
            "media_urls": mediaURLs,
            "compound_tags": compoundTags,
            "privacy_level": privacyLevel.rawValue,
            "post_type": postType.rawValue
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.invalidResponse
        }
        
        let post = try JSONDecoder().decode(Post.self, from: data)
        return post
    }
    
    func likePost(_ post: Post) async throws -> (Bool, Int) {
        let url = URL(string: "\(baseURL)/posts/\(post.id)/like")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        // Parse the response to get the new like status and count
        let responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        let liked = responseDict["liked"] as? Bool ?? true
        let likesCount = responseDict["likes_count"] as? Int ?? (post.engagementMetrics.likes + 1)
        
        return (liked, likesCount)
    }
    
    func unlikePost(_ post: Post) async throws {
        let url = URL(string: "\(baseURL)/posts/\(post.id)/like")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
    }
    
    // MARK: - Comments
    
    func getComments(postId: String) async throws -> [Comment] {
        let url = URL(string: "\(baseURL)/posts/\(postId)/comments")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let comments = try JSONDecoder().decode([Comment].self, from: data)
        return comments
    }
    
    func addComment(postId: String, content: String) async throws -> Comment {
        let url = URL(string: "\(baseURL)/posts/\(postId)/comments")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        let body = ["content": content]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.invalidResponse
        }
        
        let comment = try JSONDecoder().decode(Comment.self, from: data)
        return comment
    }
    
    // MARK: - Cycles
    
    func getCycles() async throws -> [Cycle] {
        if offlineMode {
            return []
        }
        let url = URL(string: "\(baseURL)/cycles")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let cycles = try JSONDecoder().decode([Cycle].self, from: data)
        return cycles
    }
    
    func createCycle(name: String, startDate: Date, goals: [String], compounds: [CycleCompound]) async throws -> Cycle {
        if offlineMode {
            return Cycle(
                id: UUID().uuidString,
                userId: "local-user",
                name: name,
                startDate: startDate,
                endDate: nil,
                goals: goals,
                compounds: compounds,
                notes: nil,
                status: .active,
                createdAt: Date(),
                updatedAt: Date()
            )
        }
        let url = URL(string: "\(baseURL)/cycles")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        let body: [String: Any] = [
            "name": name,
            "start_date": ISO8601DateFormatter().string(from: startDate),
            "goals": goals,
            "compounds": compounds.map { compound in
                [
                    "compound_id": compound.compoundId,
                    "dosage_mg": compound.dosageMg as Any,
                    "frequency_days": compound.frequencyDays as Any
                ]
            }
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.invalidResponse
        }
        
        let cycle = try JSONDecoder().decode(Cycle.self, from: data)
        return cycle
    }
    
    // MARK: - Injections
    
    func getInjections() async throws -> [Injection] {
        if offlineMode {
            return []
        }
        let url = URL(string: "\(baseURL)/injections")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let injections = try JSONDecoder().decode([Injection].self, from: data)
        return injections
    }
    
    func logInjection(cycleId: String?, compoundName: String, dosageMg: Double, injectionSite: Injection.InjectionSite?, injectionMethod: Injection.InjectionMethod?, notes: String?) async throws -> Injection {
        if offlineMode {
            return Injection(
                id: UUID().uuidString,
                userId: "local-user",
                cycleId: cycleId,
                compoundId: nil,
                compoundName: compoundName,
                dosageMg: dosageMg,
                injectionSite: injectionSite,
                injectionMethod: injectionMethod,
                needleGauge: nil,
                needleLengthMm: nil,
                notes: notes,
                injectedAt: Date(),
                createdAt: Date()
            )
        }
        let url = URL(string: "\(baseURL)/injections")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        var body: [String: Any] = [
            "compound_name": compoundName,
            "dosage_mg": dosageMg
        ]
        
        if let cycleId = cycleId { body["cycle_id"] = cycleId }
        if let injectionSite = injectionSite { body["injection_site"] = injectionSite.rawValue }
        if let injectionMethod = injectionMethod { body["injection_method"] = injectionMethod.rawValue }
        if let notes = notes { body["notes"] = notes }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.invalidResponse
        }
        
        let injection = try JSONDecoder().decode(Injection.self, from: data)
        return injection
    }
    
    // MARK: - Side Effects
    
    func getSideEffects() async throws -> [SideEffect] {
        if offlineMode {
            return []
        }
        let url = URL(string: "\(baseURL)/side-effects")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let sideEffects = try JSONDecoder().decode([SideEffect].self, from: data)
        return sideEffects
    }
    
    func logSideEffect(cycleId: String?, symptoms: [String], severity: Int, notes: String?) async throws -> SideEffect {
        if offlineMode {
            return SideEffect(
                id: UUID().uuidString,
                userId: "local-user",
                cycleId: cycleId,
                symptoms: symptoms,
                severity: severity,
                bloodPressureSystolic: nil,
                bloodPressureDiastolic: nil,
                moodRating: nil,
                libidoRating: nil,
                acneSeverity: nil,
                notes: notes,
                recordedAt: Date(),
                createdAt: Date()
            )
        }
        let url = URL(string: "\(baseURL)/side-effects")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = getAuthHeaders()
        
        var body: [String: Any] = [
            "symptoms": symptoms,
            "severity": severity
        ]
        
        if let cycleId = cycleId { body["cycle_id"] = cycleId }
        if let notes = notes { body["notes"] = notes }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw APIError.invalidResponse
        }
        
        let sideEffect = try JSONDecoder().decode(SideEffect.self, from: data)
        return sideEffect
    }
}

// MARK: - Supporting Types

struct AuthResponse: Codable {
    let user: User
    let token: String
}

enum APIError: Error, LocalizedError {
    case invalidResponse
    case networkError
    case decodingError
    case unauthorized
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError:
            return "Network connection error"
        case .decodingError:
            return "Failed to decode response"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError:
            return "Server error"
        }
    }
} 