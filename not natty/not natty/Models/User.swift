//
//  User.swift
//  not natty
//
//  Created by Apple Id on 7/26/25.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let email: String
    let username: String
    let fullName: String?
    let avatarURL: String?
    let bio: String?
    let heightCm: Int?
    let weightKg: Double?
    let dateOfBirth: Date?
    let verificationStatus: VerificationStatus
    let emailVerified: Bool
    let profileData: [String: String]
    let settings: UserSettings
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum VerificationStatus: String, Codable, CaseIterable {
        case unverified = "unverified"
        case pending = "pending"
        case verified = "verified"
        case rejected = "rejected"
        
        var displayName: String {
            switch self {
            case .unverified: return "Unverified"
            case .pending: return "Pending"
            case .verified: return "Verified"
            case .rejected: return "Rejected"
            }
        }
        
        var icon: String {
            switch self {
            case .unverified: return "person"
            case .pending: return "clock"
            case .verified: return "checkmark.seal.fill"
            case .rejected: return "xmark.circle"
            }
        }
    }
    
    struct UserSettings: Codable {
        let privacy: PrivacySettings
        let notifications: NotificationSettings
        let units: UnitSettings
        
        struct PrivacySettings: Codable {
            let profileVisibility: String
            let cycleVisibility: String
            let postVisibility: String
        }
        
        struct NotificationSettings: Codable {
            let newFollowers: Bool
            let likes: Bool
            let comments: Bool
            let cycleReminders: Bool
        }
        
        struct UnitSettings: Codable {
            let weight: String
            let dosage: String
            let height: String
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email, username
        case fullName = "full_name"
        case avatarURL = "avatar_url"
        case bio, heightCm, weightKg, dateOfBirth
        case verificationStatus = "verification_status"
        case emailVerified = "email_verified"
        case profileData = "profile_data"
        case settings, isActive
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 